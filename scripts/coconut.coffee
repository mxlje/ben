# Description:
#   Coconut icon, based on
#   Applause from Orson Welles and others
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   coconut - Get applause
#
# Author:
#   maxlielje

images = [
  "http://i.imgur.com/wyGu3R4.jpg"
  ]


module.exports = (robot) ->
  robot.hear /coconut/i, (msg) ->
    msg.send msg.random images