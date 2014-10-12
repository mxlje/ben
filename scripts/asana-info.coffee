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
#   post Asana task URL - get info about task
#
# Author:
#   mxlje

asana_api_key = process.env.HUBOT_ASANA_API_KEY

# template for response
response = (task) ->
  """
  > **#{task.status} #{task.title} (#{task.assignee})**
  > #{task.notes}
  """

module.exports = (robot) ->
  robot.hear /app\.asana\.com\/\d{1}\/\d+\/(\d+)/i, (msg) ->

    # extract task ID from URL
    task_id = msg.match[1]
    req_uri = "https://app.asana.com/api/1.0/tasks/#{task_id}"
    auth    = 'Basic ' + new Buffer("#{asana_api_key}:").toString('base64')

    robot.http(req_uri)
      .header("Authorization", auth)
      .get() (err, res, body) ->

        # basic error handling
        if err
          msg.send "Something went wrong: #{err}"
          return

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
        msg.send response(task)
