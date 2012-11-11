var apiKey = "21484962"; // Replace with your API key. See https://dashboard.tokbox.com
var sessionId = '2_MX4yMTQ4NDk2Mn5-U2F0IE5vdiAxMCAxNzozMDowMSBQU1QgMjAxMn4wLjY5NDc2OTR-'; // Replace with your own session ID. See http://static.opentok.com/opentok/api/tools/generator 
var token = 'T1==cGFydG5lcl9pZD0yMTQ4NDk2MiZzaWc9ZTAxMGY3YjZlOTBiYTQ0YjVmNzJhNzJhNGFkM2FhOWFlMTNiZTliYTpzZXNzaW9uX2lkPTJfTVg0eU1UUTRORGsyTW41LVUyRjBJRTV2ZGlBeE1DQXhOem96TURvd01TQlFVMVFnTWpBeE1uNHdMalk1TkRjMk9UUi0mY3JlYXRlX3RpbWU9MTM1MjU5NzM5MCZleHBpcmVfdGltZT0xMzUyNjgzNzkwJnJvbGU9cHVibGlzaGVyJmNvbm5lY3Rpb25fZGF0YT0mbm9uY2U9MjQ5MzY4'; // Replace with a generated token. See http://static.opentok.com/opentok/api/tools/generator

TB.setLogLevel(TB.DEBUG); // Set this for helpful debugging messages in console

var session = TB.initSession(sessionId);
session.addEventListener('sessionConnected', sessionConnectedHandler);
session.addEventListener('streamCreated', streamCreateHandler);
session.connect(apiKey, token);

var publisher;

function sessionConnectedHandler(event) {
	//lert('Hello world. I am connected to OpenTok :).');
	var publishProps = {height:240, width:320};
	publisher = TB.initPublisher(apiKey, 'myPublisherDiv', publishProps);
	session.publish(publisher);
	subscribeToStreams(event.streams);
}

function streamCreateHandler(event) {
	subscribeToStreams(event.streams);
}

function subscribeToStreams(streams) {
	console.log('blah:'+ streams.length);
	for (var i = 0; i <streams.length; i++) {
		if (streams[i].connection.connectionId == session.connection.connectionId)
		{
			return;
		}

		var div = document.createElement('div');
		div.setAttribute('id', 'stream' + streams[i].streamId);
		$("#myStreamsDiv").append(div);

		var subscribeProps = {height:240, width:320};
		session.subscribe(streams[i], div.id);
	}
}