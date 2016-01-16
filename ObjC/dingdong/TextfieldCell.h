//
//  TextfieldCell.h
//  dingdong
//
//  Created by Zhongcai Ng on 17/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextfieldCell: UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UITextField *textField;

-(void)showTextFieldKeyboard;
-(void)hideTextFieldKeyboard;

@end