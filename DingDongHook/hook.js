var WebSocket= require("ws");

module.exports= {
	initialize: function(app, access, callback) {
		this.app= app;
		this.access= access;
		this.socket= {};
		this.tasks= {};
		this.callbacks= {};
		this.pings= {};
		this.attempts= 0;
		this.username= "";
		this.password= "";
		callback();
		return;
	},
	
	connect: function(username, password) {
		var self= this;
		if(self.socket && (self.socket.readyState== 0 || self.socket.readyState== 1)) { return; }
		self.username= username;
		self.password= password;
		self.socket= new WebSocket("wss://ws.cloudilly.com");
		self.socket.onopen= function() { self.attempts= 0; self.connectNormal.call(self); return; }

		self.socket.onmessage= function(msg) {
			if(msg.data== "1") { return; }
			var obj= JSON.parse(msg.data);
			
			switch(obj.type) {
				case "connect":
					switch(obj.status) {
						case "success": self.connectSuccess.call(self, obj); return;
						case "fail": self.connectFail.call(self, obj); return;
					}
					return;
				
				case "task":
					switch(obj.status) {
						case "success": self.taskSuccess.call(self, obj); return;
						case "fail": self.taskFail.call(self, obj); return;
					}
					return;
				
				case "device": self.callbacks["device"].call(self, obj); return;
				case "post": self.callbacks["post"].call(self, obj); return;
			}
		}

		self.socket.onerror= function(err) {
			self.attempts= self.attempts+ 1;
			clearTimeout(self.pings);
			self.callbacks["disconnected"].call(self);
			if(err.code== 4000 || self.attempts> 100) { self.attempts= 0; return; }
			setTimeout(function() { self.connect.call(self, self.username, self.password); }, 2000 * self.attempts);
			return;
		}

		self.socket.onclose= function(err) {
			self.attempts= self.attempts+ 1;
			clearTimeout(self.pings);
			self.callbacks["disconnected"].call(self);
			if(err.code== 4000 || self.attempts> 100) { self.attempts= 0; return; }
			setTimeout(function() { self.connect.call(self, self.username, self.password); }, 2000 * self.attempts);
			return;
		}
	},

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// SAAS METHODS
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	disconnect: function() {
		var self= this;
		var obj= {};
		obj.type= "disconnect";
		var str= JSON.stringify(obj);
		self.socket.send(str);
	},

	listen: function(group, callback) {
		var self= this;
		var obj= {};
		obj.type= "listen";
		obj.group= group;
		self.writeAndTask.call(self, obj, callback);
	},
	
	listenWithPassword: function(group, password, callback) {
		var self= this;
		var obj= {};
		obj.type= "listen";
		obj.group= group;
		obj.password= password;
		self.writeAndTask.call(self, obj, callback);
	},
	
	unlisten: function(group, callback) {
		var self= this;
		var obj= {};
		obj.type= "unlisten";
		obj.group= group;
		self.writeAndTask.call(self, obj, callback);
	},

	join: function(group, callback) {
		var self= this;
		var obj= {};
		obj.type= "join";
		obj.group= group;
		self.writeAndTask.call(self, obj, callback);
	},
	
	joinWithPassword: function(group, password, callback) {
		var self= this;
		var obj= {};
		obj.type= "join";
		obj.group= group;
		obj.password= password;
		self.writeAndTask.call(self, obj, callback);
	},
	
	unjoin: function(group, callback) {
		var self= this;
		var obj= {};
		obj.type= "unjoin";
		obj.group= group;
		self.writeAndTask.call(self, obj, callback);
	},

	update: function(payload, callback) {
		var self= this;
		var obj= {};
		obj.type= "update";
		obj.payload= payload;
		self.writeAndTask.call(self, obj, callback);
	},
	
	post: function(group, payload, callback) {
		var self= this;
		var obj= {};
		obj.type= "post";
		obj.group= group;
		obj.payload= payload;
		self.writeAndTask.call(self, obj, callback);
	},

	store: function(group, payload, callback) {
		var self= this;
		var obj= {};
		obj.type= "store";
		obj.group= group;
		obj.payload= payload;
		self.writeAndTask.call(self, obj, callback);
	},
		
	remove: function(post, callback) {
		var self= this;
		var obj= {};
		obj.type= "remove";
		obj.post= post;
		self.writeAndTask.call(self, obj, callback);
	},
	
	create: function(group, password, callback) {
		var self= this;
		var obj= {};
		obj.type= "create";
		obj.group= group;
		obj.password= password;
		self.writeAndTask.call(self, obj, callback);
	},

	login: function(username, password, callback) {
		var self= this;
		self.username= username;
		self.password= password;
		var obj= {};
		obj.type= "login";
		obj.username= self.username;
		obj.password= self.password;
		self.writeAndTask.call(self, obj, callback);
	},

	logout: function(callback) {
		var self= this;
		delete self.username;
		delete self.password;
		var obj= {};
		obj.type= "logout";
		self.writeAndTask.call(self, obj, callback);
	},
	
	link: function(group, callback) {
		var self= this;
		var obj= {};
		obj.type= "link";
		obj.group= group;
		self.writeAndTask.call(self, obj, callback);
	},
	
	unlink: function(group, callback) {
		var self= this;
		var obj= {};
		obj.type= "unlink";
		obj.group= group;
		self.writeAndTask.call(self, obj, callback);
	},
			
	notify: function(message, group, callback) {
		var self= this;
		var obj= {};
		obj.type= "notify";
		obj.message= message;
		obj.group= group;
		self.writeAndTask.call(self, obj, callback);
	},

	email: function(recipient, subject, body, callback) {
		var self= this;
		var obj= {};
		obj.type= "email";
		obj.recipient= recipient;
		obj.subject= subject;
		obj.body= body;
		self.writeAndTask.call(self, obj, callback);
	},
	
	requestPasswordChange: function(group, callback) {
		var self= this;
		var obj= {};
		obj.type= "requestPasswordChange";
		obj.group= group;
		self.writeAndTask.call(self, obj, callback);
	},

	changePassword: function(group, password, token, callback) {
		var self= this;
		var obj= {};
		obj.type= "changePassword";
		obj.group= group;
		obj.password= password;
		obj.token= token;
		self.writeAndTask.call(self, obj, callback);
	},

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// SUPER METHODS
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	_verifyAccount: function(username, accountID, callback) {
		var self= this;
		var obj= {};
		obj.type= "_verifyAccount";
		obj.username= username;
		obj.accountID= accountID;
		self.writeAndTask.call(self, obj, callback);
	},

	_updateAPNSPlatform: function(app, device, platform, arn, callback) {
		var self= this;
		var obj= {};
		obj.type= "_updateAPNSPlatform";
		obj.app= app;
		obj.device= device;
		obj.platform= platform;
		obj.arn= arn;
		self.writeAndTask.call(self, obj, callback);
	},

	_updateGCMPlatform: function(app, device, arn, serverkey, callback) {
		var self= this;
		var obj= {};
		obj.type= "_updateGCMPlatform";
		obj.app= app;
		obj.device= device;
		obj.arn= arn;
		obj.serverkey= serverkey;
		self.writeAndTask.call(self, obj, callback);
	},

	_updatePlan: function(app, plan, callback) {
		var self= this;
		var obj= {};
		obj.type= "_updatePlan";
		obj.app= app;
		obj.plan= plan;
		self.writeAndTask.call(self, obj, callback);
	},

	_cleanDevices: function(host, callback) {
		var self= this;
		var obj= {};
		obj.type= "_cleanDevices";
		obj.host= host;
		self.writeAndTask.call(self, obj, callback);
	},
	
// @@@@@@@@@@@@@@@@@@@@@@@@@@@
// HELPER METHODS
// @@@@@@@@@@@@@@@@@@@@@@@@@@@
	
	connectNormal: function(username, password) {
		var self= this; if(!self.socket || self.socket.readyState!= 1) { return; }
		var obj= {}; obj.type= "connect"; obj.app= self.app; obj.access= self.access; obj.saas= "hook"; obj.version= 1;
		if(self.username) { obj.username= self.username; }; if(self.password) { obj.password= self.password; }
		var str= JSON.stringify(obj); self.socket.send(str);
	},
	connectSuccess: function(obj) { var self= this; self.startPing.call(self); self.callbacks["connected"].call(self, null, obj); },
	connectFail: function(obj) { var self= this; self.callbacks["connected"].call(self, 1, obj); },
	taskSuccess: function(obj) {
		var self= this;
		self.callbacks[obj.task].call(self, null, obj);
		delete self.callbacks[obj.task];
		delete self.tasks[obj.task];
	},
	taskFail: function(obj) {
		var self= this;
		self.callbacks[obj.task].call(self, 1, obj);
		delete self.callbacks[obj.task];
		delete self.tasks[obj.task];
	},
	startPing: function() { var self= this; self.firePing.call(self); self.pings= setInterval(function() { self.firePing.call(self); }, 15000); },
	firePing: function() {
		var self= this; if(!self.socket || self.socket.readyState!= 1) { return; }
		self.socket.send("1"); var tasks= [];
		for(var key in self.tasks) { tasks.push([key, self.tasks[key]["timestamp"]]); };
		tasks.sort(function(a, b) { return a[1]< b[1] ? 1 : a[1]> b[1] ? -1 : 0 });
		var length= tasks.length; while(length--) { var task= self.tasks[tasks[length][0]]; self.socket.send(task.data); }
	},
	writeAndTask: function(obj, callback) {
		var self= this; if(!self.socket || self.socket.readyState!= 1) { return; }
		var timestamp= Math.round(new Date().getTime()); var tid= obj.type + "-" + self.generateUUID.call();
		obj.task= tid; self.callbacks[tid]= callback;
		var task= {}; task.timestamp= timestamp; task.data= JSON.stringify(obj); task.task= tid; self.tasks[tid]= task;
		var str= JSON.stringify(obj); self.socket.send(str);
	},
	generateUUID: function() {
		return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function(c) { var r= Math.random()*16|0; var v= c=== "x" ? r : (r&0x3|0x8); return v.toString(16); });
	},
	
// @@@@@@@@@@@@@@@@@@@@@@@@@@@
// DELEGATE METHODS
// @@@@@@@@@@@@@@@@@@@@@@@@@@@

	socketConnected: function(callback) { this.callbacks["connected"]= callback; },
	socketDisconnected: function(callback) { this.callbacks["disconnected"]= callback; },
	socketReceivedDevice: function(callback) { this.callbacks["device"]= callback; },
	socketReceivedPost: function(callback) { this.callbacks["post"]= callback; }

}