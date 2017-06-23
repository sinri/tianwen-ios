//
//  DynamicTableCellInfo.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/22.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>
#import <UIkit/UITableView.h>

@interface DynamicTableCellInfo : NSObject

@property NSString * _Nonnull cellKey;
@property NSString * _Nonnull cellReusableId;

@property UITableViewCellStyle cellStyle;
//@property (readonly) NSInteger cellStyle;

@property UITableViewCellAccessoryType cellAccessoryType;

@property NSString * _Nullable text;
@property NSString * _Nullable detailText;
@property NSString * _Nullable imageName;

@property void (^ _Nullable onSelect)(DynamicTableCellInfo* _Nonnull cellInfo, id _Nullable otherInfo);

-(instancetype _Nonnull)initWithCellKey:(NSString*_Nonnull)cellKey andCellReusableId:(NSString*_Nonnull)cellReusableId;

@end
