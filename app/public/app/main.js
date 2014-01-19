function init() {
	playing();

	setTimeout(function() {
	      init()
	}, 10 * 1000);
}

function playing() {

	$.ajax({
		type: "GET",
		url: "/playing"
	})
	.done(function( msg ) {

		var song = msg.match(/Now playing (.*) by/g);
		var artist = msg.match(/by (.*)/g);

		$('#songTitle').html(song[0].substring(12,song[0].length - 2));
		$('#songArtist').html(artist[0]);

		loadArt();
	});

}

function loadArt() {
	var timestamp = new Date().getTime();
	$('#albumArt').attr("src", "playing.png?random=" + timestamp);
}

function play() {

	$('#toggle').attr('class', 'glyphicon glyphicon-pause');
	$('#tp').attr('href', 'JavaScript: pause()');

	api("PUT", "/play");

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