//
//  Message+CoreDataProperties.m
//  dingdong
//
//  Created by Zhongcai Ng on 22/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message+CoreDataProperties.h"

@implementation Message (CoreDataProperties)

@dynamic recipient;
@dynamic sender;
@dynamic timestamp;
@dynamic message;
@dynamic post;

@end