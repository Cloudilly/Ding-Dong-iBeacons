//
//  MessageViewController.h
//  dingdong
//
//  Created by Zhongcai Ng on 22/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MessageViewController: UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate> {
    CGFloat width;
    CGFloat height;
    NSString *recipient;
    UITableView *messageTableView;
    UIView *bottom;
    UITextField *field;
    NSFetchedResultsController *messageFetchedResultsController;
}

-(id)initWithRecipient:(NSString *)recipient;
    
@end