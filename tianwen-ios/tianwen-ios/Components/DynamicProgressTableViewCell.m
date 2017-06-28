//
//  DynamicProgressTableViewCell.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/26.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "DynamicProgressTableViewCell.h"

@interface DynamicProgressTableViewCell ()
@property UIProgressView * progressView;
@end

@implementation DynamicProgressTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _progress=0;
        _progressColor=[UIColor greenColor];
        
        _progressView=[[UIProgressView alloc]initWithProgressViewStyle:(UIProgressViewStyleDefault)];
        [_progressView setBackgroundColor:[self backgroundColor]];
        [_progressView setAlpha:0];
        //[self insertSubview:_progressView belowSubview:self.imageView];
        [self insertSubview:_progressView aboveSubview:self.imageView];
    }
    return self;
}

-(void)cleanCell{
    [super cleanCell];
    
    [self setProgress:0 andColor:[self backgroundColor]];
    [_progressView setAlpha:0];
}

-(void)setProgress:(CGFloat)progress andColor:(UIColor*)color{
    _progress=progress;
    _progressColor=color;
    
    [_progressView setProgress:_progress];
    [_progressView setProgressTintColor:_progressColor];
    [_progressView setAlpha:0.8];
    
    CGFloat screen_width=[[UIScreen mainScreen]bounds].size.width;
    [_progressView setFrame:(CGRectMake(0, self.frame.size.height-2, screen_width, 2))];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
