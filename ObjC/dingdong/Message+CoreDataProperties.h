//
//  Message+CoreDataProperties.h
//  dingdong
//
//  Created by Zhongcai Ng on 22/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *recipient;
@property (nullable, nonatomic, retain) NSString *sender;
@property (nullable, nonatomic, retain) NSNumber *timestamp;
@property (nullable, nonatomic, retain) NSString *message;
@property (nullable, nonatomic, retain) NSString *post;

@end

NS_ASSUME_NONNULL_END