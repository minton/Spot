var time = 1;
var timeLeft = 50;
var lastSong = "";

function init() {

	initAux();
	progressAux();
	
}

function initAux() {

	playing();

	setTimeout(function() {
	      initAux()
	}, 10 * 1000);

}

function progressAux() {

	$('#progress').css('width', (time++ / timeLeft) * 100 + '%');

	setTimeout(function() {
	      progressAux();
	}, 1 * 1000);

}

function getTimeLeft() {

	$.ajax({
		type: "GET",
		url: "/seconds-left"
	})
	.done(function( msg ) {

		time = 1;
		timeLeft = msg
	});

}

function playing() {

	$.ajax({
		type: "GET",
		url: "/playing"
	})
	.done(function( msg ) {

		var song = msg.match(/Now playing (.*) by/g);
		song = song[0].substring(12,song[0].length - 2);

		if (song != lastSong) {
			lastSong = song;
			getTimeLeft();
		}


		var artist = msg.match(/by (.*)/g);

		$('#songTitle').html(song);
		$('#songArtist').html(artist[0]);

		loadArt();
	});

}

function loadArt() {
	var timestamp = new Date().getTime();
	$('#albumArt').attr("src", "playing.png?random=" + timestamp);
}

function find_any_play() {

	$.ajax({
		type: "POST",
		url: "/find",
		data: {
			"q": $('#searchString').val()
		}
	})
	.done(function( msg ) {
		playing();
	});

	return false;

}

function query() {

	$('#search').attr("value", "Loading...");

	$.ajax({
		type: "GET",
		url: "/query",
		data: {
			"q": $('#searchString').val()
		}
	})
	.done(function( msg ) {

		$('#search').attr("value", "Search");

		$('#queryList').html(loadQueryResult(msg));


	});

	return false;

}

function play() {

	$('#toggle').attr('class', 'glyphicon glyphicon-pause');
	$('#tp').attr('href', 'JavaScript: pause()');

	api("PUT", "/play");

}

function play_uri(uri) {

	$('#toggle').attr('class', 'glyphicon glyphicon-pause');
	$('#tp').attr('href', 'JavaScript: pause()');

	$.ajax({
		type: "POST",
		url: "/play-uri",
		data: {
			"uri": uri
		}
	})
	.done(function( msg ) {
		playing();
	});

} 

function pause() {

	$('#toggle').attr('class', 'glyphicon glyphicon-play');
	$('#tp').attr('href', 'JavaScript: play()');

	api("PUT", "/pause");
}

function back() {
	api("PUT", "/back");
}

function next() {
	api("PUT", "/next");
}

function mute() {
	api("PUT", "/mute");
}

function bumpdown() {
	api("PUT", "/bumpdown");
}

function bumpup() {
	api("PUT", "/bumpup");
}

function api(method, uri) {

	$.ajax({
		type: method,
		url: uri
	})
	.done(function( msg ) {
		playing();
	});

}

function loadQueryResult(msg) {

	var result = "";

	for (var i = 0; i < msg.length; i++) {
		result += loadQueryAux(msg[i]);
	}

	return result;

}

function loadQueryAux(item) {

	return '<a href="JavaScript: play_uri(\''+ item.uri +'\');" class="list-group-item">' + 
    	   '<h4 class="list-group-item-heading">'+ item.name +'</h4>' +
    	   '<p class="list-group-item-text">by '+ item.artists[0].name +'</p>' +
  		   '</a>';

}

function loadNotice(text) {
	return '<div class="alert alert-success alert-dismissable">' + 
			  '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' + 
			  '<p>' + text +'</p>' + 
			'</div>';
}