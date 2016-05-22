var cloudilly= require("./hook.js");

var app= "GET YOUR APP NAME AT CLOUDILLY.COM>";
var access= "<GET YOUR ACCESS KEY AT CLOUDILLY.COM>";
cloudilly.initialize(app, access, function() {
	cloudilly.connect();
});

cloudilly.socketConnected(function(err, res) {
	if(err) { console.log("ERROR: Oops. Something wrong"); return; }
	console.log("@@@@@@ CONNECTED");
	console.log(res);

	var beaconID= "<INSERT IDENTIFIER, FORMAT AS 'DINGDONG:MAJOR:MINOR', MAJOR / MINOR FROM ESTIMOTE CLOUD>";
	var secretToken= "<INSERT YOUR OWN SECRET TOKEN>";
	cloudilly.create(beaconID, secretToken, function(err, res) {
		if(err) { console.log("ERROR: Oops. Something wrong"); return; }
		console.log("@@@@@@ CREATE");
		console.log(res);
		
		cloudilly.disconnect();
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