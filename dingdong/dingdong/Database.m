//
//  Database.m
//  dingdong
//
//  Created by Zhongcai Ng on 19/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import "Database.h"

@implementation Database

@synthesize managedObjectContext= _managedObjectContext;
@synthesize managedObjectModel= _managedObjectModel;
@synthesize persistentStoreCoordinator= _persistentStoreCoordinator;

-(id)init {
    self= [super init];
    if(self) {
    }
    return self;
}

// PROFILE
-(Profile *)fetchProfile {
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *request= [[NSFetchRequest alloc] init];
    NSEntityDescription *entity= [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:context];
    request.entity= entity; NSArray *profile= [context executeFetchRequest:request error:nil];
    return profile.count> 0 ? [profile objectAtIndex:0] : [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:context];
}

-(BOOL)updateProfile:(NSMutableDictionary *)dict {
    Profile *profile= [self fetchProfile];
    NSManagedObjectContext *context= [self managedObjectContext];
    if(!profile) { profile= [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:context]; }
    if([dict objectForKey:@"username"]) { profile.username= [dict objectForKey:@"username"]; }
    if([dict objectForKey:@"password"]) { profile.password= [dict objectForKey:@"password"]; }
    if([dict objectForKey:@"nearby"]) { profile.nearby= [dict objectForKey:@"nearby"]; }
    if([dict objectForKey:@"token"]) { profile.token= [dict objectForKey:@"token"]; }
    return [context save:nil];
}

-(BOOL)resetProfile {
    Profile *profile= [self fetchProfile];
    NSManagedObjectContext *context= [self managedObjectContext];
    profile.username= nil; profile.password= nil;
    return [context save:nil];
}

// DINGDONG
-(Dingdong *)fetchDingdong:(NSString *)dingdong {
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *request= [[NSFetchRequest alloc] init];
    NSEntityDescription *entity= [NSEntityDescription entityForName:@"Dingdong" inManagedObjectContext:context];
    NSPredicate *predicate= [NSPredicate predicateWithFormat:@"dingdong== %@", dingdong];
    request.entity= entity; request.predicate= predicate;
    NSArray *dingdongs= [context executeFetchRequest:request error:nil];
    return dingdongs.count> 0 ? [dingdongs objectAtIndex:0] : nil;
}

-(NSArray *)fetchDingdongs {
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *request= [[NSFetchRequest alloc] init];
    NSEntityDescription *entity= [NSEntityDescription entityForName:@"Dingdong" inManagedObjectContext:context];
    request.entity= entity;
    NSArray *dingdongs= [context executeFetchRequest:request error:nil];
    return dingdongs.count> 0 ? dingdongs : nil;
}

-(BOOL)updateDingdong:(NSMutableDictionary *)dict {
    Dingdong *dingdong= [self fetchDingdong:[dict objectForKey:@"dingdong"]];
    NSManagedObjectContext *context= [self managedObjectContext];
    if(!dingdong) { dingdong= [NSEntityDescription insertNewObjectForEntityForName:@"Dingdong" inManagedObjectContext:context]; }
    if([dict objectForKey:@"dingdong"]) { dingdong.dingdong= [dict objectForKey:@"dingdong"]; }
    if([dict objectForKey:@"token"]) { dingdong.token= [dict objectForKey:@"token"]; }
    if([dict objectForKey:@"devices"]) { dingdong.devices= [dict objectForKey:@"devices"]; }
    return [context save:nil];
}

-(BOOL)deleteDingdong:(NSString *)dingdong {
    NSManagedObjectContext *context= [self managedObjectContext];
    [context deleteObject:[self fetchDingdong:dingdong]];
    return [context save:nil];
}

-(BOOL)deleteDingdongs {
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *request= [[NSFetchRequest alloc] init];
    NSEntityDescription *entity= [NSEntityDescription entityForName:@"Dingdong" inManagedObjectContext:context];
    request.entity= entity; NSArray *dingdongs= [context executeFetchRequest:request error:nil];
    for(Dingdong *dingdong in dingdongs) { [context deleteObject:dingdong]; }
    return [context save:nil];
}

// MESSAGE
-(Message *)fetchMessage:(NSString *)post {
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *request= [[NSFetchRequest alloc] init];
    NSEntityDescription *entity= [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSPredicate *predicate= [NSPredicate predicateWithFormat:@"post== %@", post];
    request.entity= entity; request.predicate= predicate;
    NSArray *messages= [context executeFetchRequest:request error:nil];
    return messages.count> 0 ? [messages objectAtIndex:0] : nil;
}

-(BOOL)updateMessage:(NSMutableDictionary *)dict {
    Message *message= [self fetchMessage:[dict objectForKey:@"post"]];
    NSManagedObjectContext *context= [self managedObjectContext];
    if(!message) { message= [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context]; }
    if([dict objectForKey:@"recipient"]) { message.recipient= [dict objectForKey:@"recipient"]; }
    if([dict objectForKey:@"sender"]) { message.sender= [dict objectForKey:@"sender"]; }
    if([dict objectForKey:@"timestamp"]) { message.timestamp= [dict objectForKey:@"timestamp"]; }
    if([dict objectForKey:@"post"]) { message.post= [dict objectForKey:@"post"]; }
    if([dict objectForKey:@"message"]) { message.message= [dict objectForKey:@"message"]; }
    return [context save:nil];
}

-(BOOL)deleteMessagsFromRecipient:(NSString *)recipient {
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *request= [[NSFetchRequest alloc] init];
    NSEntityDescription *entity= [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSPredicate *predicate= [NSPredicate predicateWithFormat:@"recipient== %@", recipient];
    request.entity= entity; request.predicate= predicate;
    NSArray *messages= [context executeFetchRequest:request error:nil];
    for(Message *message in messages) { [context deleteObject:message]; }
    return [context save:nil];
}

// CORE DATA
-(NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(NSManagedObjectContext *)managedObjectContext {
    if(_managedObjectContext!= nil) { return _managedObjectContext; }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if(coordinator!= nil) {
        _managedObjectContext= [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

-(NSManagedObjectModel *)managedObjectModel {
    if(_managedObjectModel!= nil) { return _managedObjectModel; }
    NSURL *modelURL= [[NSBundle mainBundle] URLForResource:@"dingdong.v1.0.0" withExtension:@"momd"];
    _managedObjectModel= [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if(_persistentStoreCoordinator != nil) { return _persistentStoreCoordinator; }
    NSURL *storeURL= [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"dingdong.v1.0.0.sqlite"];
    NSError *error= nil;
    _persistentStoreCoordinator= [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options= [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                            [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"@@@ COREDATA ERROR: %@", error.localizedDescription); abort();
    }
    return _persistentStoreCoordinator;
}

@end