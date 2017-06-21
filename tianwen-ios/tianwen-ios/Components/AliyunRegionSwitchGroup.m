//
//  AliyunRegionSwitchGroup.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/19.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "AliyunRegionSwitchGroup.h"

@implementation AliyunRegionSwitchGroup

-(instancetype)initWithFrame:(CGRect)frame andRegions:(NSArray*)regionList{
    self=[super initWithFrame:frame];
    if(self){
        [self refreshSwitchs:regionList];
    }
    return self;
}

-(void)refreshSwitchs:(NSArray*)regionList{
    //NSLog(@"refresh switchs region list: %@",regionList);
    NSDictionary*regions=[AliyunAccountModel fullRegionDict];
    NSArray*regionKeys=[AliyunAccountModel fullRegionDictKeys];
    _switchList=[@[] mutableCopy];
    
    CGFloat h=0;
    
    for(NSUInteger i =0;i<[regionKeys count];i++){
        UISwitch * switcher=[[UISwitch alloc]initWithFrame:(CGRectMake(0, h, 51, 31))];
        [self addSubview:switcher];
        [_switchList addObject:switcher];
        
        UILabel * label=[[UILabel alloc]initWithFrame:(CGRectMake(70, h, 200, 31))];
        [label setText:[regionKeys objectAtIndex:i]];
        [self addSubview:label];
        
        h+=60;
        
        //on or off
        NSString*code=[regions objectForKey:[regionKeys objectAtIndex:i]];
        [switcher setOn:[regionList containsObject:code]];
    }
    
    CGRect rect=self.frame;
    rect.size.height=h;
    self.frame=rect;
}

-(NSArray*)regionsOpened{
    NSMutableArray * ma=[@[] mutableCopy];
    NSDictionary*regions=[AliyunAccountModel fullRegionDict];
    NSArray*keys=[AliyunAccountModel fullRegionDictKeys];
    for (NSUInteger i=0; i<[_switchList count]; i++) {
        UISwitch *switcher=[_switchList objectAtIndex:i];
        if([switcher isOn]){
            [ma addObject:[regions objectForKey:[keys objectAtIndex:i]]];
        }
    }
    return ma;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
