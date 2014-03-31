# Description:
#   Responds with the time and date from Palm Beach & Munich.
#
# Dependencies:
#
#   "time": "*"
#
# Commands:
#   hubot timeshift - Respond with date & time
time = require 'time'

module.exports = (robot) ->
  robot.respond /timeshift/i, (msg) ->
    germany  = new time.Date
    germany.setTimezone 'Europe/Berlin'

    hcm = new time.Date
    hcm.setTimezone 'Asia/Ho_Chi_Minh'

    manila = new time.Date
    manila.setTimezone 'Asia/Manila'

    reply = """
    It's #{germany.toLocaleTimeString()} in Germany.
    It's #{hcm.toLocaleTimeString()} in Thailand and Vietnam.
    It's #{manila.toLocaleTimeString()} in Manila.
    """

    msg.send reply