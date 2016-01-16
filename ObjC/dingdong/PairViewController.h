//
//  PairViewController.h
//  dingdong
//
//  Created by Zhongcai Ng on 17/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TitleCell.h"
#import "NormalCell.h"
#import "TextfieldCell.h"
#import "ButtonCell.h"

@interface PairViewController: UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    CGFloat width;
    CGFloat height;
    UITableView *pairTableView;
    TextfieldCell *tokenCell;
    NSFetchedResultsController *profileFetchedResultsController;
}

@end