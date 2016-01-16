//
//  NormalCell.m
//  dingdong
//
//  Created by Zhongcai Ng on 16/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import "NormalCell.h"

@implementation NormalCell

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
        
        self.value= [[UILabel alloc] initWithFrame:CGRectMake(50.0, 10.0, width -60.0, 24.0)];
        self.value.backgroundColor= [UIColor clearColor];
        self.value.font= [UIFont systemFontOfSize:18.0];
        self.value.textColor= [UIColor grayColor];
        self.value.highlightedTextColor= [UIColor grayColor];
        self.value.textAlignment= NSTextAlignmentRight;
        [self.contentView addSubview:self.value];
    }
    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end