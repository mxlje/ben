# Description:
#   Responds with the time and date from Palm Beach & Munich.
#
# Commands:
#   hubot timeshift - Respond with date & time
time = require 'time'

module.exports = (robot) ->
  robot.respond /timeshift/i, (msg) ->
    asia = new time.Date
    asia.setTimezone 'Asia/Ho_Chi_Minh'
    germany  = new time.Date
    germany.setTimezone 'Europe/Berlin'

    reply = """
    It's #{asia.toLocaleTimeString()} in Thailand and Ho Chi Minh.
    It's #{germany.toLocaleTimeString()} in Germany.
    """
    msg.send reply