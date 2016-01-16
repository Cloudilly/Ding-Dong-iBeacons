#DingDong iBeacons
Repository contains sample codes required to build a digital doorbell with Estimote iBeacons. Cloudilly is used to build its chat + push notification system. When a device is near an iBeacon, a visitor can press on a digital button to trigger a push notification out to the associated owner. If the owner choose to answer a ringing doorbell, both visitor and owner can communicate via a chat room. A secret token is used to verify ownership before associating an iBeacon to a user account.

![DingDong](https://github.com/Cloudilly/Images/blob/master/ios_dingdong_secret.png) 

Code is split into 2 sections: 1) the [iOS ObjC](/ObjC) section containing the majority of the code, and 2) the [NodeJS Hook](/Hook) section for initializing the secret token.

![DingDong](https://github.com/Cloudilly/Images/blob/master/ios_dingdong.png) 

---

#####Create app
If you have not already done so, first create an account on [Cloudilly](https://cloudilly.com). Next create an app with a unique app identifier and a cool name. Once done, you should arrive at the app page with all the access keys for the different platforms. Under iOS SDK, you will find the parameters required for your Cloudilly application. _"Access"_ refers to the access keys to be embedded in the ObjC codes. _"Bundle ID"_ can be found inside xCode project under _Targets_ >> _General_ >> _Identity_. If you require push notifications, generate a non-password protected .P12 cert file and upload to the appropriate environment.

![iOS Console](https://github.com/Cloudilly/Images/blob/master/ios_dingdong_console.png)

Under Hook SDK, you will find the parameters required for your Cloudilly application. _"Access"_ refers to the access keys to be embedded in your server side Hook codes.

![Hook Console](https://github.com/cloudilly/images/blob/master/hook_console.png)

#####Instantiate NodeJS server
Deploy the below websocket dependency.
```
npm install --save ws
```

#####Update Access on NodeJS codes
[Insert your _"App Name"_ and _"Access"_](../../blob/master/app.js#L1-L2). Once done, upload your NodeJS files and run the application. Verify connection to Cloudilly. If you have setup the anonymous chat app for other platforms, you should also test if you can send messages across platforms, ie from Android to Web / iOS and vice versa.

#####Create secret token for iBeacon
Each iBeacon comes with a unique pair of major and minor number that can be modified via the [Estimote Cloud](https://cloud.estimote.com). We will use this as our unique identifier. Each DingDong iBeacon will be tagged with a 

#####Update Access on ObjC codes
[Insert your _"App Name"_ and _"Access"_](../../blob/master/ObjC/dingdong/AppDelegate.m#L28-L29). Once done, build and run the application. Open up developer console to verify connection to Cloudilly. Try sending messages and push notifications across multiple devices.
