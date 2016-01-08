//
//  LoginViewController.h
//  dingdong
//
//  Created by Zhongcai Ng on 17/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TextfieldCell.h"
#import "ButtonCell.h"

@interface LoginViewController: UIViewController <UITableViewDataSource, UITableViewDelegate> {
    CGFloat width;
    CGFloat height;
    UITableView *loginTableView;
    TextfieldCell *usernameCell;
    TextfieldCell *passwordCell;
}

@end