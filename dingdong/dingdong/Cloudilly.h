//
//  Cloudilly.h
//  Cloudilly iOS Plugin
//
//  Created by Zhongcai Ng on 27/5/15.
//  Copyright (c) 2015 Cloudilly Private Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Security/Security.h>

@protocol CloudillyDelegate <NSObject>
@required

-(void)socketConnected:(NSDictionary *)dict;
-(void)socketDisconnected;
-(void)socketReceivedDevice:(NSDictionary *)dict;
-(void)socketReceivedPost:(NSDictionary *)dict;

@end

@interface Cloudilly: NSObject

@property (nonatomic, weak) id delegate;

-(id)initWithApp:(NSString *)app AndAccess:(NSString *)access WithCallback:(void(^)(void))callback;
-(void)connect;
-(void)connectWithUsername:(NSString *)username Password:(NSString *)password;
-(void)disconnect;
-(void)listenGroup:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback;
-(void)listenGroup:(NSString *)group WithPassword:(NSString *)password WithCallback:(void(^)(NSDictionary *))callback;
-(void)unlistenGroup:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback;
-(void)joinGroup:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback;
-(void)joinGroup:(NSString *)group WithPassword:(NSString *)password WithCallback:(void(^)(NSDictionary *))callback;
-(void)unjoinGroup:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback;
-(void)updatePayload:(NSMutableDictionary *)payload WithCallback:(void(^)(NSDictionary *))callback;
-(void)postGroup:(NSString *)group WithPayload:(NSMutableDictionary *)payload WithCallback:(void(^)(NSDictionary *))callback;
-(void)storeGroup:(NSString *)group WithPayload:(NSMutableDictionary *)payload WithCallback:(void(^)(NSDictionary *))callback;
-(void)removePost:(NSString *)post WithCallback:(void(^)(NSDictionary *))callback;
-(void)createGroup:(NSString *)group WithPassword:(NSString *)password WithCallback:(void(^)(NSDictionary *))callback;
-(void)loginToUsername:(NSString *)username WithPassword:(NSString *)password WithCallback:(void(^)(NSDictionary *))callback;
-(void)logoutWithCallback:(void(^)(NSDictionary *))callback;
-(void)registerApns:(NSString *)token WithCallback:(void(^)(NSDictionary *))callback;
-(void)unregisterApnsWithCallback:(void(^)(NSDictionary *))callback;
-(void)linkGroup:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback;
-(void)linkGroup:(NSString *)group WithPassword:(NSString *)password WithCallback:(void(^)(NSDictionary *))callback;
-(void)unlinkGroup:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback;
-(void)notify:(NSString *)message Group:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback;
-(void)emailRecipient:(NSString *)recipient Subject:(NSString *)subject Body:(NSString *)body WithCallback:(void(^)(NSDictionary *))callback;
-(void)requestPasswordChangeForGroup:(NSString *)group WithCallback:(void(^)(NSDictionary *))callback;
-(void)changePasswordForGroup:(NSString *)group Password:(NSString *)password Token:(NSString *)token WithCallback:(void(^)(NSDictionary *))callback;

@end