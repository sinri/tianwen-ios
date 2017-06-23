//
//  DynamicTableCellInfo.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/22.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "DynamicTableCellInfo.h"

@implementation DynamicTableCellInfo

//-(instancetype)init{
//    //@throw [NSException exceptionWithName:@"Method Locked" reason:@"Do not use this `init` in product" userInfo:nil];
//}

-(instancetype _Nonnull)initWithCellKey:(NSString*_Nonnull)cellKey andCellReusableId:(NSString*_Nonnull)cellReusableId{
    self=[super init];
    if(self){
        _cellKey=cellKey;
        _cellReusableId=cellReusableId;
        
        _cellStyle=UITableViewCellStyleDefault;
        _cellAccessoryType=UITableViewCellAccessoryNone;
        
        _text=nil;
        _detailText=nil;
        _imageName=nil;
        
        _onSelect=nil;
    }
    return self;
}

@end
