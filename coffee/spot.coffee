# Description:
#   Control Spot from campfire. https://github.com/minton/spot
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_SPOT_URL
#   HUBOT_SPOT_MENTION_ROOM
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
#   hubot how much longer? - Hubot tells you how much is left on the current track
#   hubot find x music <search> - Searches and pulls up x (or 3) most popular matches
#   hubot play #n - Play the nth track from the last search results
#   hubot album #n - Pull up album info for the nth track in the last search results
#   hubot last find - Pulls up the most recent find query
#   hubot airplay <Apple TV> - Tell Spot to broadcast to the specified Apple TV.
#   hubot spot - Start or restart the Spotify client.
#   hubot queue #n - Queues a song to play up when the current song is done
#   hubot queue list - Shows current song titles in the queue
#
# Authors:
#   mcminton, <Shad Downey> github:andromedado, Eric Stiens - @mutualarising

VERSION = '1.4'

URL = process.env.HUBOT_SPOT_URL || "http://localhost:5051"
MENTION_ROOM = process.env.HUBOT_SPOT_MENTION_ROOM || "#general"

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
  A = []
  if data.album
    album = data.album.name
    if data.album.released
      album += ' [' + data.album.released + ']'
    A = ['Album: ' + album]
  return ['Track: ' + data.name].concat(A).concat([
    'Artist: ' + artists.join(', '),
    'Length: ' + calcLength(data.length)
    ]).join("\n")

now = () ->
  return ~~(Date.now() / 1000)

render = (explanations) ->
  str = ""
  for exp, i in explanations
    str += '#' + (i + 1) + "\n" + exp + "\n"
  return str

renderAlbum = (album) ->
  artists = []
  if not album.artists
    artists.push('No one...?')
  else
    artists.push(a.name) for a in album.artists
  pt1 = [
    '#ALBUM#',
    'Name: ' + album.name,
    'Artist: ' + artists.join(', '),
    'Released: ' + album.released,
    'Tracks:'
    ].join("\n") + "\n"
  explanations = (explain track for track in album.tracks)
  return pt1 + render(explanations)

showResults = (robot, message, results) ->
  if not results or not results.length
    return message.send(':small_blue_diamond: I found nothin\'')
  explanations = (explain track for track in results)
  message.send(':small_blue_diamond: I found:')
  message.send(render(explanations))

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

queueTrack = (track, qL, message) ->
  unless track && track.uri
    message.send("Sorry, couldn't add that to the queue")
    return
  qL.push track
  message.send(":small_blue_diamond: I'm adding " + track.name + " to the queue")
  message.send "Current queue: #{qL.length} songs"

playNextTrackInQueue = (robot) ->
  track = robot.brain.data.ql.shift()
  robot.messageRoom(MENTION_ROOM, "Switching to " + track.name)
  robot.http(URL+'/play-uri')
    .query({'uri' : track.uri})['post']() (err,res,body) ->
      if (err)
        console.log "Error playing Queued Track" + err
      sleep(4000) # hacky but otherwise sometimes it plays two tracks in a row

sleep = (ms) ->
  start = new Date().getTime()
  continue while new Date().getTime() - start < ms

module.exports = (robot) ->

  playQueue = (robot) ->
    if robot.brain.data.ql && robot.brain.data.ql.length > 0
      robot.http(URL+'/seconds-left')
        .get() (err, res, body) ->
          seconds_left = parseFloat(body)
          if seconds_left < 3
            playNextTrackInQueue(robot)
    setTimeout (->
      playQueue(robot)
    ), 1000

  playQueue(robot)

  robot.respond /queue list/i, (message) ->
    queue_list = []
    if robot.brain.data.ql.length > 0
      for track in robot.brain.data.ql
        queue_list.push(track.name)
      message.send "Current Queue: #{queue_list.join(', ')}"
    else
      message.send "Nothing queued up."

  robot.respond /clear queue/i, (message) ->
    robot.brain.data.ql = []
    message.send "Queue cleared"

  robot.respond /queue (.*)/i, (message) ->
    robot.brain.data.ql ?= []
    qL = robot.brain.data.ql
    playNum = message.match[1].match(/#(\d+)\s*$/)
    if (playNum)
      r = getLastResultsRelevantToUser(robot, message.message.user)
      i = parseInt(playNum[1], 10) - 1
      if (r && r[i])
        queueTrack(r[i], qL, message)
        return

  robot.respond /play!/i, (message) ->
    message.finish()
    spotRequest message, '/play', 'put', {}, (err, res, body) ->
      message.send(":notes:  #{body}")

  robot.respond /pause/i, (message) ->
    params = {volume: 0}
    spotRequest message, '/pause', 'put', params, (err, res, body) ->
      message.send("#{body} :cry:")

  robot.respond /next/i, (message) ->
    if robot.brain.data.ql and robot.brain.data.ql.length > 0
      playNextTrackInQueue(robot)
    else
      spotRequest message, '/next', 'put', {}, (err, res, body) ->
        message.send("#{body} :fast_forward:")

  robot.respond /back/i, (message) ->
    spotRequest message, '/back', 'put', {}, (err, res, body) ->
      message.send("#{body} :rewind:")

  robot.respond /playing\?/i, (message) ->
    spotRequest message, '/playing', 'get', {}, (err, res, body) ->
      message.send("#{URL}/playing.png")
      message.send(":notes:  #{body}")

  robot.respond /album art\??/i, (message) ->
    spotRequest message, '/playing', 'get', {}, (err, res, body) ->
      message.send("#{URL}/playing.png")

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

  robot.respond /album .(\d+)/i, (message) ->
    r = getLastResultsRelevantToUser(robot, message.message.user)
    n = parseInt(message.match[1], 10) - 1
    if (!r || !r[n])
      message.send(":small_blue_diamon: out of bounds...")
      return
    spotRequest message, '/album-info', 'get', {'uri' : r[n].album.uri}, (err, res, body) ->
      album = JSON.parse(body)
      album.tracks.forEach((track) ->
        track.album = track.album || {}
        track.album.uri = r[n].album.uri
      )
      recordUserQueryResults(message, album.tracks)
      message.send(renderAlbum album)

  robot.respond /(how much )?(time )?(remaining|left)\??$/i, (message) ->
    spotRequest message, '/how-much-longer', 'get', {}, (err, res, body) ->
      message.send(":small_blue_diamond: #{body}")

  robot.respond /query (.*)/i, (message) ->
    params = {q: message.match[1]}
    spotRequest message, '/single-query', 'get', params, (err, res, body) ->
      track = JSON.parse(body)
      robot.brain.set('lastSingleQuery', track)
      message.send(":small_blue_diamond: I found:")
      message.send(explain track)

  robot.respond /find ?(\d+)? music (.*)/i, (message) ->
    limit = message.match[1] || 3
    params = {q: message.match[2], limit: limit}
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
    recordUserQueryResults(message, data)
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

  robot.respond /airplay (.*)/i, (message) ->
    params = {atv: message.match[1]}
    spotRequest message, '/airplay', 'put', params, (err, res, body) ->
      message.send("#{body} :mega:")

  robot.respond /spot/i, (message) ->
    spotRequest message, '/spot', 'put', {}, (err, res, body) ->
      message.send(body)

  robot.respond /respot/i, (message) ->
    spotRequest message, '/respot', 'put', {}, (err, res, body) ->
      message.send(body)
