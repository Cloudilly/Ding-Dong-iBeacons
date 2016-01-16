//
//  AppDelegate.m
//  dingdong
//
//  Created by Zhongcai Ng on 16/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate()
@end

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.database= [[Database alloc] init];
    NSMutableDictionary *dictProfile= [[NSMutableDictionary alloc] init];
    [dictProfile setObject:@"" forKey:@"nearby"];
    [self.database updateProfile:dictProfile];
    
    UIUserNotificationSettings *settings= [UIUserNotificationSettings
        settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    Profile *profile= [self.database fetchProfile];
    NSString *app= @"<GET YOUR APP NAME AT CLOUDILLY.COM>";
    NSString *access= @"<GET YOUR ACCESS KEY AT CLOUDILLY.COM>";
    self.cloudilly= [[Cloudilly alloc] initWithApp:app AndAccess:access WithCallback:^(void) {
        profile.username ? [self.cloudilly connectWithUsername:profile.username Password:profile.password] : [self.cloudilly connect];
    }];
    self.cloudilly.delegate= self;
    
    self.beaconManager= [ESTBeaconManager new];
    self.beaconManager.delegate= self;
    [self.beaconManager requestWhenInUseAuthorization];
    NSString *estimoteUUID= @"<GET YOUR UUID AT ESTIMOTE CLOUD>";
    NSString *estimoteIdentifier= @"<GET YOUR OWN IDENTIFIER AT ESTIMOTE CLOUD>";
    self.beaconRegion= [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:estimoteUUID] identifier:estimoteIdentifier];

    self.window= [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor= [UIColor clearColor];
    self.mainViewController= [[MainViewController alloc] init];
    self.window.rootViewController= self.mainViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)socketConnected:(NSDictionary *)dict {
    if([[dict objectForKey:@"status"] isEqual: @"fail"]) { [self alertTitle:@"ERROR" AndMessage:[NSString stringWithFormat:@"%@", dict]]; return; }
    NSLog(@"@@@@@@ CONNECTED");
    NSLog(@"%@", dict);
    
    NSArray *dingdongs= [self.database fetchDingdongs];
    for(Dingdong *dingdong in dingdongs) {
        NSMutableDictionary *dictDingdong= [[NSMutableDictionary alloc] init];
        [dictDingdong setObject:[NSNumber numberWithInt:0] forKey:@"devices"];
        [dictDingdong setObject:dingdong.dingdong forKey:@"dingdong"];
        [self.database updateDingdong:dictDingdong];
        [self.cloudilly listenGroup:dingdong.dingdong WithCallback:^(NSDictionary *dict) {
            if([[dict objectForKey:@"status"] isEqual: @"fail"]) { [self alertTitle:@"ERROR" AndMessage:[NSString stringWithFormat:@"%@", dict]]; return; }
            NSLog(@"@@@@@@ LISTEN");
            NSLog(@"%@", dict);
        }];
    }
}

-(void)socketDisconnected {
    NSLog(@"@@@@@@ DISCONNECTED");
}

-(void)socketReceivedDevice:(NSDictionary *)dict {
    NSLog(@"@@@@@@ RECEIVED DEVICE");
    NSLog(@"%@", dict);
    
    NSString *group= [dict objectForKey:@"group"];
    NSArray *dingdongs= [self.database fetchDingdongs];
    for(Dingdong *dingdong in dingdongs) {
        if([dingdong.dingdong isEqualToString:group]) {
            int devices= [dingdong.devices intValue];
            [[dict objectForKey:@"timestamp"] isEqualToNumber:[NSNumber numberWithInt:0]] ? devices++ : devices--;
            NSMutableDictionary *dictDingdong= [[NSMutableDictionary alloc] init];
            [dictDingdong setObject:[NSNumber numberWithInt:devices] forKey:@"devices"];
            [dictDingdong setObject:dingdong.dingdong forKey:@"dingdong"];
            [self.database updateDingdong:dictDingdong];
        }
    }
}

-(void)socketReceivedPost:(NSDictionary *)dict {
    NSLog(@"@@@@@@ RECEIVED POST");
    NSLog(@"%@", dict);
    
    NSMutableDictionary *dictMessage= [[NSMutableDictionary alloc] init];
    [dictMessage setObject:[dict objectForKey:@"recipient"] forKey:@"recipient"];
    [dictMessage setObject:[dict objectForKey:@"sender"] forKey:@"sender"];
    [dictMessage setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]* 1000] forKey:@"timestamp"];
    [dictMessage setObject:[[dict objectForKey:@"payload"] objectForKey:@"message"] forKey:@"message"];
    [dictMessage setObject:[dict objectForKey:@"post"] forKey:@"post"];
    [self.database updateMessage:dictMessage];
    
    Profile *profile= [self.database fetchProfile];
    if([[[dict objectForKey:@"payload"] objectForKey:@"message"] isEqualToString:@"DingDong"] && ![[dict objectForKey:@"sender"] isEqualToString:profile.username]) {
        NSMutableDictionary *task= [[NSMutableDictionary alloc] init];
        [task setObject:@"visitor" forKey:@"task"];
        [task setObject:[dict objectForKey:@"recipient"] forKey:@"value"];
        NSString *key= [NSString stringWithFormat:@"VISITOR:%@", [dict objectForKey:@"recipient"]];
        [self.mainViewController.tasks setObject:task forKey:key];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 20* NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.mainViewController.tasks removeObjectForKey:key];
        });
    }
    
    if(![[[dict objectForKey:@"payload"] objectForKey:@"message"] isEqualToString:@"DingDong"]
       && ![[dict objectForKey:@"sender"] isEqualToString:profile.username] && !self.mainViewController.messageViewController) {
        NSMutableDictionary *dictUserInfo= [[NSMutableDictionary alloc] init];
        [dictUserInfo setObject:[dict objectForKey:@"recipient"] forKey:@"recipient"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showMessageView" object:nil userInfo:dictUserInfo];
        [self.mainViewController.tasks removeObjectForKey:[NSString stringWithFormat:@"WAITING:%@", [dict objectForKey:@"recipient"]]];
    }
}

-(void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon= beacons.firstObject; if(!beacon) { return; }
    [self startCountdown];
    if(beacon.proximity!= CLProximityImmediate && beacon.proximity!= CLProximityNear) { return; }
    NSString *nearby= [NSString stringWithFormat:@"%@:%@", beacon.major, beacon.minor];
    Profile *profile= [self.database fetchProfile];
    if([profile.nearby isEqualToString:nearby]) { return; }
    NSMutableDictionary *dictProfile= [[NSMutableDictionary alloc] init];
    [dictProfile setObject:nearby forKey:@"nearby"];
    [self.database updateProfile:dictProfile];
}

-(void)beaconManager:(id)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *_Nullable)region withError:(NSError *)error {
    NSLog(@"@@@@@@ ERROR. BEACON FAILED TO RANGE");
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const unsigned *tokenBytes= [deviceToken bytes];
    NSString *token= [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                      ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]), ntohl(tokenBytes[3]),
                      ntohl(tokenBytes[4]), ntohl(tokenBytes[5]), ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSMutableDictionary *dictProfile= [[NSMutableDictionary alloc] init];
    [dictProfile setObject:token forKey:@"token"];
    [self.database updateProfile:dictProfile];
}

-(void)startCountdown {
    if(timer) { [timer invalidate]; timer= nil; }
    timer= [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(fireCountdown) userInfo:nil repeats:NO];
}

-(void)fireCountdown {
    NSMutableDictionary *dictProfile= [[NSMutableDictionary alloc] init];
    [dictProfile setObject:@"" forKey:@"nearby"];
    [self.database updateProfile:dictProfile];
}

-(void)alertTitle:(NSString *)title AndMessage:(NSString *)message {
    UIAlertController *alert= [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok= [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok]; [self.mainViewController presentViewController:alert animated:YES completion:nil];
}

-(void)applicationWillResignActive:(UIApplication *)application { }
-(void)applicationDidEnterBackground:(UIApplication *)application { [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion]; }
-(void)applicationWillEnterForeground:(UIApplication *)application { }
-(void)applicationDidBecomeActive:(UIApplication *)application { [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion]; }
-(void)applicationWillTerminate:(UIApplication *)application { }

@end