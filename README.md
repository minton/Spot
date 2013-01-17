#Spot

Simple Spotify-powered tunes for your office.

![](https://github.com/minton/Spot/raw/master/resources/Diagram.gif)

##Origins

This project is heavily inspired by [Play](https://github.com/play/play). Which is an awesome iTunes-based solution.

##Requirements

*   OS X
*   Spotify > 0.8
*   Campfire with Hubot (optional but recommended)

##Setup

Install [Spotify](https://www.spotify.com).

Clone the repo:

    git clone https://github.com/minton/Spot.git && cd Spot

Install gems:

    bundle install

Start Spot:

    rake start

The server will start up here: [localhost:5051](http://localhost:5051).

Spotify will open and `Repeat` and `Shuffle` will be turned on.

You should now open your favorite playlist or radio station.

##Usage

Spot can technically be used by any client capable of GET/PUT/POST requests as described below but it was really designed to be controlled via [Hubot](http://hubot.github.com/) in [Campfire](http://campfirenow.com/). You can find the latest Spot Hubot script here: [Spot.coffee](https://raw.github.com/github/hubot-scripts/master/src/scripts/spot.coffee).

###Campfire

    hubot play! - Plays current playlist or song.
    hubot pause - Pause the music.
    hubot play next - Plays the next song.
    hubot play back - Plays the previous song.
    hubot playing? - Returns the currently-played song.
    hubot play <song> - Play a particular song. This plays the first most popular result.
    hubot volume? - Returns the current volume level.
    hubot volume [0-100] - Sets the volume.
    hubot volume+ - Bumps the volume.
    hubot volume- - Bumps the volume down.
    hubot mute - Sets the volume to 0.
    hubot [name here] says turn it down - Sets the volume to 15 and blames [name here].

###API

What song is playing:

    ~$ curl -i -H "Accept: application/json" -X GET http://localhost:5051/playing
    
    HTTP/1.1 200 OK
    Content-Length: 50
    Now playing “Raise Your Weapon” by Deadmau5...

Album art for current song:

    ~$ wget http://localhost:5051/playing.png
    
    100%[======================================>] 87,510      --.-K/s   in 0s      
    2012-12-21 21:20:38 (518 MB/s) - ‘playing.png’ saved [87510/87510]
    
Play a specific song:

    ~$ curl -i -H "Accept: application/json" -X POST -d "q=Raise your weapon" http://localhost:5051/find
    
    HTTP/1.1 200 OK
    Content-Length: 50
    Now playing “Raise Your Weapon” by Deadmau5...
    
Play the music:

    ~$ curl -i -H "Accept: application/json" -X PUT http://localhost:5051/play
    
    HTTP/1.1 200 OK
    Content-Length: 50
    Now playing “Raise Your Weapon” by Deadmau5...

Pause the music:

    ~$ curl -i -H "Accept: application/json" -X PUT http://localhost:5051/pause
    
    HTTP/1.1 200 OK
    Content-Length: 21
    Everything is paused.

Mute the music:

    ~$ curl -i -H "Accept: application/json" -X PUT http://localhost:5051/mute
    
    HTTP/1.1 200 OK
    Content-Length: 7
    Shhh...
    
What's the volume set at:

    ~$ curl -i -H "Accept: application/json" -X  GET http://localhost:5051/volume
    
    HTTP/1.1 200 OK
    Content-Length: 2
    42
    
Set the volume:

    ~$ curl -i -H "Accept: application/json" -X PUT -d "volume=42" http://localhost:5051/volume
    
    HTTP/1.1 200 OK
    Content-Length: 2
    41 <--Close enough :)
    
Skip to the next track:

    ~$ curl -i -H "Accept: application/json" -X PUT http://localhost:5051/next
    
    HTTP/1.1 200 OK
    Content-Length: 56
    Onwards! Now playing “Ghosts N Stuff” by Deadmau5...

Play the previous track:

    ~$ curl -i -H "Accept: application/json" -X PUT http://localhost:5051/back
    
    HTTP/1.1 200 OK
    Content-Length: 71
    Let's hear it again! Now playing “Raise Your Weapon” by Deadmau5...
    
#Author

Spot was lovingly crafted by [@mcminton](https://twitter.com/mcminton). You should [follow me](https://twitter.com/intent/follow?screen_name=mcminton) for good karma!

#Art

Hubot image from [Cameron McEfee](https://github.com/cameronmcefee) found here: http://octodex.github.com/hubot/

Campfire image from [37signals](http://37signals.com/).

Spotify image from [Spotify](http://spotify.com/).

    
