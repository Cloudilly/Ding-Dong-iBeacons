//
//  Cloudilly.m
//  Cloudilly iOS Plugin
//
//  Created by Zhongcai Ng on 27/5/15.
//  Copyright (c) 2015 Cloudilly Private Limited. All rights reserved.
//

#import "Cloudilly.h"
#import "GCDAsyncSocket.h"
#import "Reachability.h"

#define CONNECT 2
#define PING 15
#define PONG 5

@implementation Cloudilly {
    GCDAsyncSocket *socket;
    Reachability *reach;
    BOOL reattempt;
    int attempts;
    NSString *app;
    NSString *saas;
    NSNumber *version;
    NSString *origin;
    NSTimer *ping;
    NSTimer *pong;
    NSMutableDictionary *tasks;
    NSMutableDictionary *callbacks;
}

-(id)initWithApp:(NSString *)_app AndAccess:(NSString *)access WithCallback:(void(^)(void))callback {
    self= [super init];
    if(self) {
        NSNotificationCenter *notifCenter= [NSNotificationCenter defaultCenter]; UIApplication *sharedApp= [UIApplication sharedApplication];
        [notifCenter addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:sharedApp];
        [notifCenter addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:sharedApp];
        [notifCenter addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        reattempt= TRUE;
        attempts= 0;
        app= _app;
        saas= @"ios";
        version= [[NSNumber alloc] initWithInt:1];
        origin= [[NSBundle mainBundle] bundleIdentifier];
        tasks= [[NSMutableDictionary alloc] init];
        callbacks= [[NSMutableDictionary alloc] init];
        [callbacks setObject:[callback copy] forKey:@"initialized"];
        [self saveToKeyChain:access];
        
        dispatch_queue_t mainQueue= dispatch_get_main_queue();
        socket= [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
        reach= [Reachability reachabilityWithHostname:@"www.google.com"];
        reach.reachableOnWWAN= YES;
        [reach startNotifier];
    }
    return self;
}

-(void)connectToCloudilly {
    if([socket isConnected]) { return; }
    dispatch_time_t dispatchTime= dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * CONNECT * attempts);
    dispatch_after(dispatchTime, dispatch_get_main_queue(), ^(void) {
        [socket connectToHost:@"tcp.cloudilly.com" onPort:443 withTimeout:CONNECT + CONNECT * attempts error:nil];
    });
}

-(void)disconnectFromCloudilly {
    reattempt= FALSE;
    if([socket isDisconnected]) { return; }
    [socket disconnect];
}

-(void)write:(NSMutableDictionary *)dict {
    NSData *json= [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSMutableData *data= [json mutableCopy];
    [data appendData:[GCDAsyncSocket CRLFData]];
    [socket writeData:data withTimeout:-1 tag:0];
}

-(void)writeAndTask:(NSMutableDictionary *)dict WithCallback:(void(^)(NSDictionary *))callback {
    NSNumber *timestamp= [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    NSString *task= [NSString stringWithFormat:@"%@-%@", [dict objectForKey:@"type"], [[NSUUID UUID] UUIDString]];
    [dict setObject:task forKey:@"task"];
    NSMutableDictionary *dictTask= [[NSMutableDictionary alloc] init];
    [dictTask setObject:timestamp forKey:@"timestamp"];
    [dictTask setObject:dict forKey:@"data"];
    [dictTask setObject:task forKey:@"task"];
    [tasks setObject:dictTask forKey:task];
    [callbacks setObject:[callback copy] forKey:task];
    [self write:dict];
}

-(void)connect {
    NSMutableDictionary *dictKeyChain= [self retrieveFromKeyChain];
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"connect" forKey:@"type"];
    [dict setObject:app forKey:@"app"];
    [dict setObject:saas forKey:@"saas"];
    [dict setObject:version forKey:@"version"];
    [dict setObject:origin forKey:@"origin"];
    [dict setObject:[dictKeyChain objectForKey:@"device"] forKey:@"device"];
    [dict setObject:[dictKeyChain objectForKey:@"access"] forKey:@"access"];
    [self write:dict];
}

-(void)connectWithUsername:(NSString *)username Password:(NSString *)password {
    NSMutableDictionary *dictKeyChain= [self retrieveFromKeyChain];
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"connect" forKey:@"type"];
    [dict setObject:app forKey:@"app"];
    [dict setObject:saas forKey:@"saas"];
    [dict setObject:version forKey:@"version"];
    [dict setObject:origin forKey:@"origin"];
    [dict setObject:[dictKeyChain objectForKey:@"device"] forKey:@"device"];
    [dict setObject:[dictKeyChain objectForKey:@"access"] forKey:@"access"];
    [dict setObject:username forKey:@"username"];
    [dict setObject:password forKey:@"password"];
    [self write:dict];
}

-(void)disconnect {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"disconnect" forKey:@"type"];
    [self write:dict];
}

-(void)listenGroup:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"listen" forKey:@"type"];
    [dict setObject:group forKey:@"group"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)listenGroup:(NSString *)group WithPassword:(NSString *)password WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"listen" forKey:@"type"];
    [dict setObject:group forKey:@"group"];
    [dict setObject:password forKey:@"password"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)unlistenGroup:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"unlisten" forKey:@"type"];
    [dict setObject:group forKey:@"group"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)joinGroup:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"join" forKey:@"type"];
    [dict setObject:group forKey:@"group"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)joinGroup:(NSString *)group WithPassword:(NSString *)password WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"join" forKey:@"type"];
    [dict setObject:group forKey:@"group"];
    [dict setObject:password forKey:@"password"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)unjoinGroup:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"unjoin" forKey:@"type"];
    [dict setObject:group forKey:@"group"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)updatePayload:(NSMutableDictionary *)payload WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"update" forKey:@"type"];
    [dict setObject:payload forKey:@"payload"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)postGroup:(NSString *)group WithPayload:(NSMutableDictionary *)payload WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"post" forKey:@"type"];
    [dict setObject:group forKey:@"group"];
    [dict setObject:payload forKey:@"payload"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)storeGroup:(NSString *)group WithPayload:(NSMutableDictionary *)payload WithCallback:(void (^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"store" forKey:@"type"];
    [dict setObject:group forKey:@"group"];
    [dict setObject:payload forKey:@"payload"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)removePost:(NSString *)post WithCallback:(void (^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"remove" forKey:@"type"];
    [dict setObject:post forKey:@"post"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)createGroup:(NSString *)group WithPassword:(NSString *)password WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"create" forKey:@"type"];
    [dict setObject:group forKey:@"group"];
    [dict setObject:password forKey:@"password"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)loginToUsername:(NSString *)username WithPassword:(NSString *)password WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"login" forKey:@"type"];
    [dict setObject:username forKey:@"username"];
    [dict setObject:password forKey:@"password"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)logoutWithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"logout" forKey:@"type"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)registerApns:(NSString *)token WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"register" forKey:@"type"];
    [dict setObject:token forKey:@"token"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)unregisterApnsWithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"unregister" forKey:@"type"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)linkGroup:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"link" forKey:@"type"];
    [dict setObject:group forKey:@"group"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)linkGroup:(NSString *)group WithPassword:(NSString *)password WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"link" forKey:@"type"];
    [dict setObject:group forKey:@"group"];
    [dict setObject:password forKey:@"password"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)unlinkGroup:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"unlink" forKey:@"type"];
    [dict setObject:group forKey:@"group"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)notify:(NSString *)message Group:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"notify" forKey:@"type"];
    [dict setObject:message forKey:@"message"];
    [dict setObject:group forKey:@"group"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)emailRecipient:(NSString *)recipient Subject:(NSString *)subject Body:(NSString *)body WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"email" forKey:@"type"];
    [dict setObject:recipient forKey:@"recipient"];
    [dict setObject:subject forKey:@"subject"];
    [dict setObject:body forKey:@"body"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)requestPasswordChangeForGroup:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"requestPasswordChange" forKey:@"type"];
    [dict setObject:group forKey:@"group"];
    [self writeAndTask:dict WithCallback:callback];
}

-(void)changePasswordForGroup:(NSString *)group Password:(NSString *)password Token:(NSString *)token WithCallback:(void(^)(NSDictionary *))callback {
    NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
    [dict setObject:@"changePassword" forKey:@"type"];
    [dict setObject:group forKey:@"group"];
    [dict setObject:password forKey:@"password"];
    [dict setObject:token forKey:@"token"];
    [self writeAndTask:dict WithCallback:callback];
}

// PING PONG
-(void)startPING {
    if(ping) { return; }
    ping= [NSTimer scheduledTimerWithTimeInterval:PING target:self selector:@selector(firePING) userInfo:nil repeats:YES];
    [self firePING];
}

-(void)stopPING {
    if(!ping) { return; }
    [ping invalidate];
    ping= nil;
}

-(void)firePING {
    NSMutableData *data= [[@"1" dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    [data appendData:[GCDAsyncSocket CRLFData]];
    [socket writeData:data withTimeout:-1 tag:0];
    [self startPONG];
    
    NSMutableArray *array= [[tasks allValues] mutableCopy];
    [array sortUsingComparator: (NSComparator)^(NSMutableDictionary *a, NSMutableDictionary *b) {
        NSString *key1= [a objectForKey: @"timestamp"];
        NSString *key2= [b objectForKey: @"timestamp"];
        return [key1 compare:key2];
    }];
    
    for(NSMutableDictionary *task in array) { [self write:[task objectForKey:@"data"]]; }
}

-(void)startPONG {
    if(pong) { [pong invalidate]; pong= nil; }
    pong= [NSTimer scheduledTimerWithTimeInterval:PONG target:self selector:@selector(firePONG) userInfo:nil repeats:NO];
}

-(void)stopPONG {
    if(!pong) { return; }
    [pong invalidate];
    pong= nil;
}

-(void)firePONG {
    [self disconnectFromCloudilly];
}

// ASYNC DELEGATE METHODS
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSMutableDictionary *settings= [NSMutableDictionary dictionaryWithCapacity:1];
    [settings setObject:@"tcp.cloudilly.com" forKey:(NSString *)kCFStreamSSLPeerName];
    [sock startTLS:settings];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    attempts++;
    [self stopPING];
    [self.delegate socketDisconnected];
    if(!reattempt || attempts>= 8) { return; }
    [self connectToCloudilly];
}

-(void)socketDidSecure:(GCDAsyncSocket *)sock {
    attempts= 0; reattempt= TRUE;
    [sock enableBackgroundingOnSocket];
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
    void (^callback)(void)= [callbacks objectForKey:@"initialized"]; callback();
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
    NSString *response= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *trimmed= [response stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    if([trimmed isEqualToString:@"1"]) { [self stopPONG]; return; }
    if([trimmed isEqualToString:@"4000"]) { [self disconnectFromCloudilly]; return; }
    
    NSData *json= [trimmed dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableContainers error:nil];
    NSString *type= [dict objectForKey:@"type"];
    if(!type) { return; }
    if([type isEqualToString:@"device"]) { [self.delegate socketReceivedDevice:dict]; return; }
    if([type isEqualToString:@"post"]) { [self.delegate socketReceivedPost:dict]; return; }
    if([type isEqualToString:@"connect"]) {
        NSString *status= [dict objectForKey:@"status"];
        if([status isEqual: @"success"]) { [self startPING]; }
        [self.delegate socketConnected:dict];
        return;
    }
    
    if([type isEqualToString:@"task"]) {
        NSString *task= [dict objectForKey:@"task"];
        void (^callback)(NSDictionary *)= [callbacks objectForKey:task];
        callback(dict);
        [callbacks removeObjectForKey:task];
        [tasks removeObjectForKey:task];
        return;
    }
}

// KEYCHAIN
-(void)saveToKeyChain:(NSString *)access {
    NSMutableDictionary *dictKeyChain= [[NSMutableDictionary alloc] init];
    [dictKeyChain setObject:(__bridge id)kSecClassInternetPassword forKey:(__bridge id)kSecClass];
    [dictKeyChain setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    [dictKeyChain setObject:[[NSBundle mainBundle] bundleIdentifier] forKey:(__bridge id)kSecAttrServer];
    
    if(SecItemCopyMatching((__bridge CFDictionaryRef)dictKeyChain, NULL)== noErr) {
        NSMutableDictionary *dictUpdate= [NSMutableDictionary dictionary];
        [dictUpdate setObject:[access dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        SecItemUpdate((__bridge CFDictionaryRef)dictKeyChain, (__bridge CFDictionaryRef)dictUpdate);
    }
    else {
        [dictKeyChain setObject:[[NSUUID UUID] UUIDString] forKey:(__bridge id)kSecAttrAccount];
        [dictKeyChain setObject:[access dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        SecItemAdd((__bridge CFDictionaryRef)dictKeyChain, NULL);
    }
}

-(NSMutableDictionary *)retrieveFromKeyChain {
    NSMutableDictionary *dictKeyChain= [[NSMutableDictionary alloc] init];
    [dictKeyChain setObject:(__bridge id)kSecClassInternetPassword forKey:(__bridge id)kSecClass];
    [dictKeyChain setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    [dictKeyChain setObject:[[NSBundle mainBundle] bundleIdentifier] forKey:(__bridge id)kSecAttrServer];
    [dictKeyChain setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [dictKeyChain setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    
    CFDictionaryRef cfRes= nil; if(SecItemCopyMatching((__bridge CFDictionaryRef)dictKeyChain, (CFTypeRef *)&cfRes)!= noErr) { return nil; }
    NSMutableDictionary *dictRes= (__bridge_transfer NSMutableDictionary *)cfRes;
    NSMutableDictionary *dictResult= [[NSMutableDictionary alloc] init];
    [dictResult setObject:[[NSString alloc] initWithData:[dictRes objectForKey:(__bridge id)kSecValueData] encoding:NSUTF8StringEncoding] forKey:@"access"];
    [dictResult setObject:[dictRes objectForKey:(__bridge id)kSecAttrAccount] forKey:@"device"];
    return dictResult;
}

// LISTENERS
-(void)appDidBecomeActive:(NSNotification *)notification { attempts= 0; reattempt= TRUE; [self connectToCloudilly]; }
-(void)appDidEnterBackground:(NSNotification *)notification { [self disconnectFromCloudilly]; }
-(void)reachabilityChanged:(NSNotification *)notification {
    if(reach.isReachable) { attempts= 0; reattempt= TRUE; [self connectToCloudilly]; return; }
    NSLog(@"ERROR: The internet connection appears to be offline");
}

@end