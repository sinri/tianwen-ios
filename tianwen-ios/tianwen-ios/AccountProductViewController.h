//
//  AccountProductViewController.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/21.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunAccountModel.h"

@interface AccountProductViewController : UITableViewController

@property NSArray<AliyunAccountModel *> * accounts;
@property NSMutableArray<NSDictionary*> * productsByAccount;

@end
