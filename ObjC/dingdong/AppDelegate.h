//
//  AppDelegate.h
//  dingdong
//
//  Created by Zhongcai Ng on 16/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cloudilly.h"
#import "Database.h"
#import <EstimoteSDK/EstimoteSDK.h>
#import "MainViewController.h"

@class Cloudilly, Database, MainViewController;

@interface AppDelegate: UIResponder <UIApplicationDelegate, CloudillyDelegate, ESTBeaconManagerDelegate> {
    NSTimer *timer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Cloudilly *cloudilly;
@property (strong, nonatomic) Database *database;
@property (strong, nonatomic) ESTBeaconManager *beaconManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) MainViewController *mainViewController;

-(void)alertTitle:(NSString *)title AndMessage:(NSString *)message;

@end