//
//  MainViewController.h
//  dingdong
//
//  Created by Zhongcai Ng on 16/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "SignupViewController.h"
#import "LoginViewController.h"
#import "PairViewController.h"
#import "BeaconViewController.h"
#import "MessageViewController.h"

@class SettingsViewController, SignupViewController, LoginViewController, PairViewController, BeaconViewController, MessageViewController;

@interface MainViewController: UIViewController <NSFetchedResultsControllerDelegate> {
    CGFloat width;
    CGFloat height;
    UIButton *dingdongBtn;
    NSFetchedResultsController *profileFetchedResultsController;
}

@property (strong, nonatomic) NSString *currentTask;
@property (strong, nonatomic) NSTimer *taskTimer;
@property (strong, nonatomic) NSMutableDictionary *tasks;
@property (strong, nonatomic) SettingsViewController *settingsViewController;
@property (strong, nonatomic) SignupViewController *signupViewController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) PairViewController *pairViewController;
@property (strong, nonatomic) BeaconViewController *beaconViewController;
@property (strong, nonatomic) MessageViewController *messageViewController;

@end