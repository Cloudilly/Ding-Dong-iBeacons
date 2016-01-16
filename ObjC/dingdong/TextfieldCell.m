//
//  TextfieldCell.m
//  dingdong
//
//  Created by Zhongcai Ng on 17/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import "TextfieldCell.h"

@implementation TextfieldCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self= [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        CGFloat width= [[UIScreen mainScreen] bounds].size.width;
        CGFloat thick= [[UIScreen mainScreen] scale]== 2.0 ? 0.5 : 1.0;
        self.backgroundColor= [UIColor clearColor];
        
        CALayer *separator= [CALayer layer];
        separator.frame= CGRectMake(0.0, 44.0 -thick, width, thick);
        separator.backgroundColor= [UIColor grayColor].CGColor;
        [self.contentView.layer addSublayer:separator];
        
        self.label= [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, width- 60.0, 24.0)];
        self.label.backgroundColor= [UIColor clearColor];
        self.label.font= [UIFont systemFontOfSize:18.0];
        self.label.textColor= [UIColor grayColor];
        self.label.highlightedTextColor= [UIColor grayColor];
        [self.contentView addSubview:self.label];
        
        self.textField= [[UITextField alloc] initWithFrame:CGRectMake(50.0, 10.0, width -60.0, 24.0)];
        self.textField.contentVerticalAlignment= UIControlContentVerticalAlignmentCenter;
        self.textField.textColor= [UIColor grayColor];
        self.textField.backgroundColor= [UIColor clearColor];
        self.textField.font= [UIFont systemFontOfSize:18.0];
        self.textField.autocorrectionType= UITextAutocorrectionTypeYes;
        self.textField.textAlignment= NSTextAlignmentRight;
        self.textField.returnKeyType= UIReturnKeyDefault;
        self.textField.delegate= self;
        [self.contentView addSubview:self.textField];
    }
    return self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fireLogin" object:nil];
    return NO;
}

-(void)showTextFieldKeyboard {
    [self.textField becomeFirstResponder];
}

-(void)hideTextFieldKeyboard {
    [self.textField resignFirstResponder];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end