# Description:
#   Control Spot from campfire. https://github.com/minton/spot
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_SPOT_URL
#
# Commands:
#   hubot play! - Plays current playlist or song.
#   hubot pause - Pause the music.
#   hubot play next - Plays the next song.
#   hubot play back - Plays the previous song.
#   hubot playing? - Returns the currently-played song.
#   hubot play <song> - Play a particular song. This plays the first most popular result.
#   hubot query <song> - Searches Spotify for a particular song, shows what "Play <song>" would play.
#   hubot volume? - Returns the current volume level.
#   hubot volume [0-100] - Sets the volume.
#   hubot volume+ - Bumps the volume.
#   hubot volume- - Bumps the volume down.
#   hubot mute - Sets the volume to 0.
#   hubot [name here] says turn it down - Sets the volume to 15 and blames [name here].
#   hubot say <message> - Tells hubot to read a message aloud.
#
# Author:
#   mcminton
VERSION = '1.2.1'

URL = "#{process.env.HUBOT_SPOT_URL}"

spotRequest = (message, path, action, options, callback) ->
  message.http("#{URL}#{path}")
    .query(options)[action]() (err, res, body) ->
      callback(err,res,body)

recordUserQueryResults = (message, results) ->
  uQ = message.robot.brain.get('userQueries') || {}
  uD = uQ[message.message.user.id] = uQ[message.message.user.id] || {}
  uD.queries = uD.queries || []
  uD.queries.push(
    text: message.message.text
    time: now()
    results: results
  )
  message.robot.brain.set('userQueries', uQ)

getLastResultsRelevantToUser = (robot, user) ->
  uQ = robot.brain.get('userQueries') || {}
  uD = uQ[user.id] = uQ[user.id] || {}
  uD.queries = uD.queries || []
  lastUQTime = 0
  if (uD.queries.length)
    lastUQTime = uD.queries[uD.queries.length - 1].time
  lqT = robot.brain.get('lastQueryTime')
  if (lqT && lqT > lastUQTime && lqT - lastUQTime > 60)
    return robot.brain.get('lastQueryResults')
  if (uD.queries.length)
    return uD.queries[uD.queries.length - 1].results
  return null

explain = (data) ->
  if not data.artists
    return 'nothin\''
  artists = []
  artists.push(a.name) for a in data.artists
  album = data.album.name
  if data.album.released
    album += ' [' + data.album.released + ']'
  return [
    'Track: ' + data.name,
    'Album: ' + album,
    'Artist: ' + artists.join(', '),
    'Length: ' + calcLength(data.length)
    ].join("\n")

now = () ->
  return ~~(Date.now() / 1000)

render = (explanations) ->
  str = "I found:\n"
  for exp, i in explanations
    str += '#' + (i + 1) + "\n" + exp + "\n"
  return str

showResults = (robot, message, results) ->
  explanations = (explain track for track in results)
  return message.send(render(explanations))

calcLength = (seconds) ->
  iSeconds = parseInt(seconds, 10)
  if (iSeconds < 60)
    return (Math.round(iSeconds * 10) / 10) + ' seconds'
  rSeconds = iSeconds % 60
  if (rSeconds < 10)
    rSeconds = '0' + rSeconds
  return Math.floor(iSeconds / 60) + ':' + rSeconds

playTrack = (track, message) ->
  if not track or not track.uri
    message.send(":flushed:")
    return
  message.send(":small_blue_diamond: Switching to: " + track.name)
  spotRequest message, '/play-uri', 'post', {'uri' : track.uri}, (err, res, body) ->
    if (err)
      message.send(":flushed: " + err)

module.exports = (robot) ->

  robot.respond /play!/i, (message) ->
    message.finish()
    spotRequest message, '/play', 'put', {}, (err, res, body) ->
      message.send(":notes:  #{body}")
  
  robot.respond /pause/i, (message) ->
    params = {volume: 0}
    spotRequest message, '/pause', 'put', params, (err, res, body) ->
      message.send("#{body} :cry:")
  
  robot.respond /next/i, (message) ->
    spotRequest message, '/next', 'put', {}, (err, res, body) ->
      message.send("#{body} :fast_forward:")
  
  robot.respond /back/i, (message) ->
    spotRequest message, '/back', 'put', {}, (err, res, body) ->
      message.send("#{body} :rewind:")

  robot.respond /playing\?/i, (message) ->
    spotRequest message, '/playing', 'get', {}, (err, res, body) ->
      message.send("#{URL}/playing.png")
      message.send(":notes:  #{body}")

  robot.respond /volume\?/i, (message) ->
    spotRequest message, '/volume', 'get', {}, (err, res, body) ->
      message.send("Spot volume is #{body}. :mega:")

  robot.respond /volume\+/i, (message) ->
    spotRequest message, '/bumpup', 'put', {}, (err, res, body) ->
      message.send("Spot volume bumped to #{body}. :mega:")

  robot.respond /volume\-/i, (message) ->
    spotRequest message, '/bumpdown', 'put', {}, (err, res, body) ->
      message.send("Spot volume bumped down to #{body}. :mega:")

  robot.respond /mute/i, (message) ->
    spotRequest message, '/mute', 'put', {}, (err, res, body) ->
      message.send("#{body} :mute:")

  robot.respond /volume (.*)/i, (message) ->
    params = {volume: message.match[1]}
    spotRequest message, '/volume', 'put', params, (err, res, body) ->
      message.send("Spot volume set to #{body}. :mega:")

  robot.respond /play (.*)/i, (message) ->
    playNum = message.match[1].match(/#(\d+)\s*$/)
    if (playNum)
      r = getLastResultsRelevantToUser(robot, message.message.user)
      i = parseInt(playNum[1], 10) - 1
      if (r && r[i])
        playTrack(r[i], message)
        return
    if (message.match[1].match(/^that$/i))
      lastSingle = robot.brain.get('lastSingleQuery')
      if (lastSingle)
        playTrack(lastSingle, message)
        return
      lR = robot.brain.get('lastQueryResults')
      if (lR && lR.length)
        playTrack(lR[0], message)
        return
    params = {q: message.match[1]}
    spotRequest message, '/find', 'post', params, (err, res, body) ->
      message.send(":small_blue_diamond: #{body}")

  robot.respond /(how much longer|(time )?remaining)\?$/i, (message) ->
    spotRequest message, '/how-much-longer', 'get', {}, (err, res, body) ->
      message.send(":small_blue_diamond: #{body}")

  robot.respond /query (.*)/i, (message) ->
    params = {q: message.match[1]}
    spotRequest message, '/single-query', 'get', params, (err, res, body) ->
      track = JSON.parse(body)
      robot.brain.set('lastSingleQuery', track)
      message.send("I found:\n" + explain track)

  robot.respond /find ?(\d+)? music (.*)/i, (message) ->
    limit = message.match[1] || 3
    params = {q: message.match[2]}
    spotRequest message, '/query', 'get', params, (err, res, body) ->
      try
        data = JSON.parse(body)
        if (data.length > limit)
          data = data.slice(0, limit)
        robot.brain.set('lastQueryResults', data)
        robot.brain.set('lastQueryTime', now())
        recordUserQueryResults(message, data)
        showResults(robot, message, data)
      catch error
        message.send(":small_blue_diamond: :flushed: " + error.message)

  robot.respond /last find\??/i, (message) ->
    data = robot.brain.get 'lastQueryResults'
    if (!data || data.length == 0)
      message.send(":small_blue_diamond: I got nothin'")
      return
    showResults(robot, message, data)

  robot.respond /say (.*)/i, (message) ->
    what = message.match[1]
    params = {what: what}
    spotRequest message, '/say', 'put', params, (err, res, body) ->
      message.send(what)

  robot.respond /say me/i, (message) ->
    message.send('no way ' + message.message.user.name);

  robot.respond /(.*) says.*turn.*down.*/i, (message) ->
    name = message.match[1]
    message.send("#{name} says, 'Turn down the music and get off my lawn!' :bowtie:")
    params = {volume: 15}
    spotRequest message, '/volume', 'put', params, (err, res, body) ->
      message.send("Spot volume set to #{body}. :mega:")

  robot.respond /spot version\??/i, (message) ->
    message.send(':small_blue_diamond: Well, ' + message.message.user.name + ', my Spot version is presently ' + VERSION)


