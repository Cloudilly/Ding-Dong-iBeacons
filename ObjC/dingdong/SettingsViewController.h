//
//  SettingsViewController.h
//  dingdong
//
//  Created by Zhongcai Ng on 16/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TitleCell.h"
#import "NormalCell.h"

@interface SettingsViewController: UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    CGFloat width;
    CGFloat height;
    UITableView *settingsTableView;
    NSFetchedResultsController *profileFetchedResultsController;
}

@end