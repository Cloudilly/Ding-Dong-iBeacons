//
//  Database.h
//  dingdong
//
//  Created by Zhongcai Ng on 19/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Profile.h"
#import "Dingdong.h"
#import "Message.h"

@interface Database: NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(Profile *)fetchProfile;
-(BOOL)updateProfile:(NSMutableDictionary *)dict;
-(BOOL)resetProfile;
-(Dingdong *)fetchDingdong:(NSString *)dingdong;
-(NSArray *)fetchDingdongs;
-(BOOL)updateDingdong:(NSMutableDictionary *)dict;
-(BOOL)deleteDingdong:(NSString *)dingdong;
-(BOOL)deleteDingdongs;
-(Message *)fetchMessage:(NSString *)post;
-(BOOL)updateMessage:(NSMutableDictionary *)dict;
-(BOOL)deleteMessagsFromRecipient:(NSString *)recipient;

@end