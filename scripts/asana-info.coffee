# Description:
#   Listens for Asana URLs and provides info about the task.
#   The message is a markdown formatted string.
#   The format looks like this:
# 
#   > [ ] Task Title (Assignee)
#   > Lorem ipsum dolor sit amet, I am the description …
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_ASANA_API_KEY - find this in Account Settings -> API
# 
# Commands:
#   <Asana task URL> - get info about task
#
# Author:
#   mxlje

asana_api_key     = process.env.HUBOT_ASANA_API_KEY
asana_auth_header = 'Basic ' + new Buffer("#{asana_api_key}:").toString('base64')

asana_task_endpoint = (task_id) ->
  "https://app.asana.com/api/1.0/tasks/#{task_id}"

asana_project_endpoint = (project_id) ->
  "https://app.asana.com/api/1.0/projects/#{project_id}"

# templates for task response
task_template = (task) ->
  """
  > **#{task.status} #{task.title} (#{task.assignee})**
  > #{task.notes}
  """

# template for project response
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
      # a project instead of a task. We can check that here
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


get_project = (project_id, robot, msg) ->
  robot.http(asana_project_endpoint project_id)
    .header("Authorization", asana_auth_header)
    .get() (err, res, body) ->

      # Check for general networking errors
      if err
       msg.send "Something went wrong: #{err}"
       return

      # The request made to Asana was invalid
      if res.statusCode != 200
       msg.send "Asana returned HTTP #{res.statusCode}: #{JSON.parse(body).errors[0].message}"
       return

      # parse the response body
      data = JSON.parse(body).data

      # extract and reformat data from response
      project =
       name:      data.name
       workspace: data.workspace.name

      # clip notes at first paragraph
      if data.notes.length > 0
       split = data.notes.split("\n")
       project.notes = if split.length > 1 then "#{split[0]} …" else data.notes
      else
       project.notes = "(no description)"

      # send the finished markdown down the pipe
      msg.send project_template(project)


# listen for Asana deeplinks
module.exports = (robot) ->
  robot.hear /app\.asana\.com\/\d{1}\/\d+\/(\d+)/i, (msg) ->

    # extract task ID from URL
    task_id = msg.match[1]
    req_uri = asana_task_endpoint task_id

    get_task task_id, robot, msg
