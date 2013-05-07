# Description:
#   Responds with the time and date from Palm Beach & Munich.
#
# Commands:
#   hubot timeshift - Respond with date & time
time = require 'time'

module.exports = (robot) ->
  robot.respond /timeshift/i, (msg) ->
    florida = new time.Date
    florida.setTimezone 'US/Eastern'
    munich  = new time.Date
    munich.setTimezone 'Europe/Berlin'

    reply = """
    It's #{florida.toLocaleTimeString()} in Palm Beach.
    It's #{munich.toLocaleTimeString()} in Munich.
    """
    msg.send reply