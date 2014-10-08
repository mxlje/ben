# Description:
#   Listens for Asana URLs and provides info about the task.
#   The message is a markdown formatted string.
#   The format looks something like this:
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
#   Simply post an Asana URL that points to a task, eg.
#   https://app.asana.com/0/12345678901234/12345678901234
#
# Author:
#   mxlje

api_key = process.env.HUBOT_ASANA_API_KEY

module.exports = (robot) ->
  robot.hear /app\.asana\.com\/\d{1}\/\d+\/(\d+)/i, (msg) ->

    # extract task ID from URL
    task_id = msg.match[1]
    req_uri = "https://app.asana.com/api/1.0/tasks/#{task_id}"
    auth    = 'Basic ' + new Buffer("#{api_key}:").toString('base64')

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

        # prepare some data points based on their existence
        completed = if data.completed then "[&#10003;]" else "[ ]"
        assignee  = if data.assignee then "#{data.assignee.name}" else "unassigned"

        response = "> #{completed} **#{data.name}** (#{assignee})"

        # clip notes at first paragraph
        if data.notes.length > 0
          split = data.notes.split("\n")
          notes = if split.length > 1 then "#{split[0]} …" else data.notes
          
          response = response + "\n> #{notes}"
        
        # send the finished markdown down the pipe
        msg.send response
