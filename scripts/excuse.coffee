# Description:
#   Get a random developer or designer excuse
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot developer excuse me - Get a random developer excuse
#   hubot developer excuse - Get a random developer excuse
#
# Author:
#   ianmurrays, hopkinschris
#
# Notes:
#   removed designer excuses, 2014-10-12 @mxlje

module.exports = (robot) ->
  robot.respond /dev excuse|excuse(?: me)?/i, (msg) ->
    robot.http("http://developerexcuses.com")
      .get() (err, res, body) ->
        matches = body.match /<a [^>]+>(.+)<\/a>/i

        if matches and matches[1]
          msg.send matches[1]
