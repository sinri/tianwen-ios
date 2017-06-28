//
//  DynamicProgressTableViewCell.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/26.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DynamicTableCellInfoCompatibleCell.h"

@interface DynamicProgressTableViewCell : DynamicTableCellInfoCompatibleCell


@property (readonly) CGFloat progress;
@property (readonly) UIColor * progressColor;

-(void)setProgress:(CGFloat)progress andColor:(UIColor*)color;

@end
