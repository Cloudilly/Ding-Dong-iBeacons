//
//  TitleCell.m
//  dingdong
//
//  Created by Zhongcai Ng on 16/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import "TitleCell.h"

@implementation TitleCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self= [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        CGFloat width= [[UIScreen mainScreen] bounds].size.width;
        CGFloat thick= [[UIScreen mainScreen] scale]== 2.0 ? 0.5 : 1.0;
        self.selectionStyle= UITableViewCellSelectionStyleNone;
        self.backgroundColor= [UIColor clearColor];
        
        CALayer *separator= [CALayer layer];
        separator.frame= CGRectMake(0.0, 44.0 -thick, width, thick);
        separator.backgroundColor= [UIColor lightGrayColor].CGColor;
        [self.contentView.layer addSublayer:separator];
        
        self.label= [[UILabel alloc] initWithFrame:CGRectMake(5.0, 20.0, width- 10.0, 20.0)];
        self.label.backgroundColor= [UIColor clearColor];
        self.label.font= [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:14.0];
        self.label.textColor= [UIColor grayColor];
        [self.contentView addSubview:self.label];
    }
    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end