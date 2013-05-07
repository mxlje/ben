# Description:
#   Responds with the time and date from Palm Beach & Munich.
#
# Commands:
#   hubot timeshift - Respond with date & time
time = require 'time'

module.exports = (robot) ->
  robot.respond /timeshift/i, (msg) ->
    germany  = new time.Date
    germany.setTimezone 'Europe/Berlin'
    thailand  = new time.Date
    thailand.setTimezone 'Asia/Bangkok'

    reply = """
    It's #{germany.toLocaleTimeString()} in Germany.
    It's #{thailand.toLocaleTimeString()} in Thailand and Vietnam.
    """
    msg.send reply