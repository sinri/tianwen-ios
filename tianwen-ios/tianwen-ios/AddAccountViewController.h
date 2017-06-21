//
//  AddAccountViewController.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/18.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunAccountModel.h"
#import "AliyunRegionSwitchGroup.h"

@interface AddAccountViewController : UIViewController<UITextFieldDelegate>

@property AliyunAccountModel * _Nullable aliyunAccountModel;

@property UISegmentedControl * _Nonnull accountType;
@property UITextField * _Nonnull nickname;
@property UITextField * _Nonnull username;
@property UITextField * _Nonnull password;
@property AliyunRegionSwitchGroup * _Nonnull regionSG;

-(instancetype _Nonnull )initWithAliyunAccountModel:(nullable AliyunAccountModel*)aam;

@end
