# Description:
#   Coconut pictures, based on
#   Applause from Orson Welles and others
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   coconut - Get coconut image
#
# Author:
#   mxlje

images = [
  "http://i.imgur.com/wyGu3R4.jpg",
  "http://i.imgur.com/eDVVKXZ.jpg",
  "http://i.imgur.com/1rbE6Gt.jpg",
  "http://i.imgur.com/HuQyy1O.jpg"
  ]


module.exports = (robot) ->
  robot.hear /coconut/i, (msg) ->
    msg.send msg.random images