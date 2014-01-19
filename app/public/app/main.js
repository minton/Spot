function init() {

	initAux();
	
}

function initAux() {

	playing();

	setTimeout(function() {
	      initAux()
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

function just_find() {

	$('#search').attr("value", "Loading...");

	$.ajax({
		type: "POST",
		url: "/just-find",
		data: {
			"q": $('#searchString').val()
		}
	})
	.done(function( msg ) {

		$('#search').attr("value", "Search");

		$('#notice').html(loadNotice(msg));


	});

	return false;

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

function loadNotice(text) {
	return '<div class="alert alert-success alert-dismissable">' + 
			  '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' + 
			  '<p>' + text +'</p>' + 
			'</div>';
}