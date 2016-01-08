var cloudilly= require("./hook.js");
var randomstring= require("randomstring");

cloudilly.initialize("com.cloudilly.dingdong", "008db012-d30f-475f-8aef-582fd2b1b923", function() {
	cloudilly.connect();
});

cloudilly.socketConnected(function(err, res) {
	if(err) { console.log("ERROR: Oops. Something wrong"); return; }
	console.log("@@@@@@ CONNECTED");
	console.log(res);
	
	cloudilly.create("dingdong:10508:54650", randomstring.generate(8), function(err, res) {
		if(err) { console.log("ERROR: Oops. Something wrong"); return; }
		console.log("@@@@@@ CREATE");
		console.log(res);
	});
});

cloudilly.socketDisconnected(function() {
	console.log("@@@@@@ CLOSED");
});

cloudilly.socketReceivedDevice(function(res) {
	console.log("@@@@@@ RECEIVED DEVICE");
	console.log(res);
});

cloudilly.socketReceivedPost(function(res) {
	console.log("@@@@@@ RECEIVED POST");
	console.log(res);
});