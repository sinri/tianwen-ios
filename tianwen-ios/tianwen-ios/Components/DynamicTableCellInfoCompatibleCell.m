//
//  DynamicTableCellInfoCompatibleCell.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/26.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "DynamicTableCellInfoCompatibleCell.h"

@implementation DynamicTableCellInfoCompatibleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)cleanCell{
    [[self textLabel]setText:nil];
    [[self detailTextLabel]setText:nil];
    [[self imageView]setImage:nil];
    [self setAccessoryType:(UITableViewCellAccessoryNone)];
    [self setAccessoryView:nil];
}


@end
