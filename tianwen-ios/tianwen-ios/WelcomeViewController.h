//
//  WelcomeViewController.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/18.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "TianwenMultiWarningInfoView.h"
#import "DynamicTianwenWarningView.h"

@interface WelcomeViewController : UIViewController
<DynamicTianwenWarningViewDelegate>

//@property UIScrollView * reportContainer;
//@property TianwenMultiWarningInfoView * warningReportView;
@property DynamicTianwenWarningView * warningReportView;

@end
