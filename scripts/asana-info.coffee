# Description:
#   Listens for Asana URLs and provides info about the task or project.
#   The message is a markdown formatted string.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_ASANA_API_KEY - find this in Account Settings -> API
# 
# Commands:
#   <Asana (task|project) URL> - get info
#
# Author:
#   mxlje

asana_api_key     = process.env.HUBOT_ASANA_API_KEY
asana_auth_header = 'Basic ' + new Buffer("#{asana_api_key}:").toString('base64')

# Helpers for Asana endpoint URLs
asana_task_endpoint = (task_id) ->
  "https://app.asana.com/api/1.0/tasks/#{task_id}"

asana_project_endpoint = (project_id) ->
  "https://app.asana.com/api/1.0/projects/#{project_id}"

# (Markdown) templates for responses based on response type
task_template = (task) ->
  """
  > **#{task.status} #{task.title} (#{task.assignee})**
  > #{task.notes}
  """

project_template = (project) ->
  """
  > **#{project.name} (#{project.workspace})**
  > #{project.notes}
  """


get_task = (task_id, robot, msg) ->
  robot.http(asana_task_endpoint task_id)
    .header("Authorization", asana_auth_header)
    .get() (err, res, body) ->

      # Check for general networking errors
      if err
        msg.send "Something went wrong: #{err}"
        return

      # If Asana returns 403 Forbidden it is possible that the URL belongs to
      # a project instead of a task. We’ll ask Asana again and return
      if res.statusCode == 403
        get_project task_id, robot, msg
        return

      # The request made to Asana was invalid
      if res.statusCode != 200
        msg.send "Asana returned HTTP #{res.statusCode}: #{JSON.parse(body).errors[0].message}"
        return

      # parse the response body
      data = JSON.parse(body).data

      # extract and reformat data from response
      task =
        title:    data.name
        status:   if data.completed then "[&#10003;]" else "[ ]"
        assignee: if data.assignee then "#{data.assignee.name}" else "unassigned"

      # clip notes at first paragraph
      if data.notes.length > 0
        split = data.notes.split("\n")
        task.notes = if split.length > 1 then "#{split[0]} …" else data.notes
      else
        task.notes = "(no description)"

      # send the finished markdown down the pipe
      msg.send task_template(task)


# This is pretty much the exact same code as for tasks but with a
# different endpoint and a different response template
get_project = (project_id, robot, msg) ->
  robot.http(asana_project_endpoint project_id)
    .header("Authorization", asana_auth_header)
    .get() (err, res, body) ->

      if err
        msg.send "Something went wrong: #{err}"
        return

      if res.statusCode != 200
        msg.send "Asana returned HTTP #{res.statusCode}: #{JSON.parse(body).errors[0].message}"
        return

      data = JSON.parse(body).data

      project =
        name:      data.name
        workspace: data.workspace.name

      if data.notes.length > 0
        split = data.notes.split("\n")
        project.notes = if split.length > 1 then "#{split[0]} …" else data.notes
      else
        project.notes = "(no description)"

      msg.send project_template(project)


# Listen for Asana deeplinks
module.exports = (robot) ->
  robot.hear /app\.asana\.com\/\d{1}\/\d+\/(\d+)/i, (msg) ->

    # extract task ID from URL
    task_id = msg.match[1]
    req_uri = asana_task_endpoint task_id

    # Query Asana API
    get_task task_id, robot, msg
