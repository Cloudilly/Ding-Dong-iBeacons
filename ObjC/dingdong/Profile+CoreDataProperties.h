//
//  Profile+CoreDataProperties.h
//  dingdong
//
//  Created by Zhongcai Ng on 19/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Profile.h"

NS_ASSUME_NONNULL_BEGIN

@interface Profile (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSString *password;
@property (nullable, nonatomic, retain) NSString *nearby;
@property (nullable, nonatomic, retain) NSString *token;

@end

NS_ASSUME_NONNULL_END