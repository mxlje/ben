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

# Listen for Asana deeplinks
module.exports = (robot) ->
  robot.hear /app\.asana\.com\/\d{1}\/[inbox\/]*\d+\/(\d+)/i, (msg) ->
    id = msg.match[1]

    # Check for a task first
    get_task id, robot, msg, (task) ->
      if task.statusCode == 403
        # on 403 status check for project
        get_project id, robot, msg, (project) ->
          msg.send project_template(project)

      else
        msg.send task_template(task)



# Helpers for Asana endpoint URLs
asana_task_endpoint = (task_id) ->
  "https://app.asana.com/api/1.0/tasks/#{task_id}"

asana_project_endpoint = (project_id) ->
  "https://app.asana.com/api/1.0/projects/#{project_id}"

report_error = (msg, err) ->
  msg.send "Something went wrong: #{err}"

report_invalid_request = (msg, res, body) ->
  msg.send "Asana returned HTTP #{res.statusCode}: #{JSON.parse(body).errors[0].message}"



# (Markdown) templates for responses for a task ir project
task_template = (task) ->
  t =
    code:     task.statusCode
    title:    task.name
    status:   if task.completed then "[&#10003;]" else "[ ]"
    assignee: if task.assignee then "#{task.assignee.name}" else "unassigned"

  if task.notes.length > 0
    split = task.notes.split("\n")
    t.notes = if split.length > 1 then "#{split[0]} …" else task.notes
  else
    t.notes = "(no description)"

  """
  > **#{t.status} #{t.title} (#{t.assignee})**
  > #{t.notes}
  """

project_template = (project) ->
  p =
    name:      project.name
    workspace: project.workspace.name

  if project.notes.length > 0
    split = project.notes.split("\n")
    p.notes = if split.length > 1 then "#{split[0]} …" else project.notes
  else
    p.notes = "(no description)"

  """
  > **#{p.name} (#{p.workspace})**
  > #{p.notes}
  """



get_task = (task_id, robot, msg, cb) ->
  robot.http(asana_task_endpoint task_id)
    .header("Authorization", asana_auth_header)
    .get() (err, res, body) ->

      # Check for general networking errors
      if err
        report_error msg, err
        return

      # If Asana returns 403 Forbidden it is possible that the URL belongs to
      # a project instead of a task. We call back with a task object containing
      # the 403 status so the callback can start a new query
      task = {}
      if res.statusCode == 403
        task.statusCode = 403
        cb task
        return

      if res.statusCode != 200
        report_invalid_request msg, res, body
        return

      # parse the response body
      task = JSON.parse(body).data
      cb task

get_project = (project_id, robot, msg, cb) ->
  robot.http(asana_project_endpoint project_id)
    .header("Authorization", asana_auth_header)
    .get() (err, res, body) ->

      if err
        report_error msg, err
        return

      if res.statusCode != 200
        report_invalid_request msg, res, body
        return

      project = JSON.parse(body).data
      cb project
