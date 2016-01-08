//
//  Dingdong+CoreDataProperties.h
//  dingdong
//
//  Created by Zhongcai Ng on 20/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Dingdong.h"

NS_ASSUME_NONNULL_BEGIN

@interface Dingdong (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *dingdong;
@property (nullable, nonatomic, retain) NSString *token;
@property (nullable, nonatomic, retain) NSNumber *devices;

@end

NS_ASSUME_NONNULL_END