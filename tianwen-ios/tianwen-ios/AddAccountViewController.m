//
//  AddAccountViewController.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/18.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "AddAccountViewController.h"

@interface AddAccountViewController ()

@end

@implementation AddAccountViewController

-(instancetype)initWithAliyunAccountModel:(nullable AliyunAccountModel*)aam{
    self=[super init];
    if(self) {
        _aliyunAccountModel=aam;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self view]setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationItem setTitle:@"Account Info"];
    
    UIBarButtonItem * saveButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemSave) target:self action:@selector(addAccount:)];
    [self.navigationItem setRightBarButtonItem:saveButton];
    
    UIScrollView * container=[[UIScrollView alloc]initWithFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))];
    [self.view addSubview:container];
    
    CGFloat h=10;
    CGFloat m=20;
    
    _accountType=[[UISegmentedControl alloc]initWithItems:@[@"AccessKey",@"Registered"]];
    [_accountType setFrame:(CGRectMake(m, h, self.view.frame.size.width-2*m, 30))];
    if(_aliyunAccountModel && [_aliyunAccountModel isUPMode]){
        [_accountType setSelectedSegmentIndex:1];
    }else{
        [_accountType setSelectedSegmentIndex:0];
    }
    //[_accountType setTitle:@"AccessKey" forSegmentAtIndex:0];
    //[_accountType setTitle:@"Registered" forSegmentAtIndex:1];
    [container addSubview:_accountType];
    
    h+=30+10;
    
    UILabel * labelForNickname=[[UILabel alloc]initWithFrame:(CGRectMake(m, h, 300, 30))];
    [labelForNickname setText:@"AccessKey ID / Username"];
    [container addSubview:labelForNickname];
    
    h+=30+10;
    
    _nickname = [[UITextField alloc]initWithFrame:(CGRectMake(m, h, self.view.frame.size.width-2*m, 30))];
    [_nickname setBorderStyle:(UITextBorderStyleRoundedRect)];
    [_nickname setDelegate:self];
    [_nickname setReturnKeyType:(UIReturnKeyNext)];
    if(_aliyunAccountModel){
        [_nickname setText:_aliyunAccountModel.nickname];
    }
    [container addSubview:_nickname];
    
    h+=30+10;
    
    UILabel * labelForUsername=[[UILabel alloc]initWithFrame:(CGRectMake(m, h, 300, 30))];
    [labelForUsername setText:@"AccessKey ID / Username"];
    [container addSubview:labelForUsername];
    
    h+=30+10;
    
    _username = [[UITextField alloc]initWithFrame:(CGRectMake(m, h, self.view.frame.size.width-2*m, 30))];
    [_username setBorderStyle:(UITextBorderStyleRoundedRect)];
    [_username setDelegate:self];
    [_username setReturnKeyType:(UIReturnKeyNext)];
    if(_aliyunAccountModel){
        [_username setText:_aliyunAccountModel.username];
    }
    [container addSubview:_username];
    
    h+=30+10;
    
    UILabel * labelForPassword=[[UILabel alloc]initWithFrame:(CGRectMake(m, h, 300, 30))];
    [labelForPassword setText:@"AccessKey Secret / Password"];
    [container addSubview:labelForPassword];
    
    h+=30+10;
    
    _password = [[UITextField alloc]initWithFrame:(CGRectMake(m, h, self.view.frame.size.width-2*m, 30))];
    [_password setBorderStyle:(UITextBorderStyleRoundedRect)];
    [_password setDelegate:self];
    [_password setReturnKeyType:(UIReturnKeyDone)];
    if(_aliyunAccountModel){
        [_password setText:_aliyunAccountModel.password];
    }
    [container addSubview:_password];
    
    h+=30+20;
    
    UILabel * regionsLable=[[UILabel alloc]initWithFrame:(CGRectMake(m, h, 300, 30))];
    [regionsLable setText:@"Regions"];
    [container addSubview:regionsLable];
    
    h+=30+10;
    
    NSArray*regions=@[];
    if(_aliyunAccountModel){
        regions=[_aliyunAccountModel regions];
    }
    _regionSG=[[AliyunRegionSwitchGroup alloc]initWithFrame:(CGRectMake(m, h, self.view.frame.size.width-2*m, 1)) andRegions:regions];
    [container addSubview:_regionSG];
    
    h+=_regionSG.frame.size.height+10;
    /*
    UIButton * addButton=[UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    [addButton setFrame:(CGRectMake(m, h, self.view.frame.size.width-2*m, 40))];
    //    [addButton setTintColor:[UIColor whiteColor]];
    [addButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [[addButton layer]setBorderColor:[[UIColor blueColor]CGColor]];
    [[addButton layer]setBackgroundColor:[[UIColor blueColor]CGColor]];
    [[addButton layer]setCornerRadius:5];
    //    [[addButton titleLabel]setText:@"Save Account"];
    [addButton setTitle:@"Save Account" forState:(UIControlStateNormal)];
    [addButton addTarget:self action:@selector(addAccount:) forControlEvents:(UIControlEventTouchUpInside)];
    [container addSubview:addButton];
    */
    h+=40+20;
    
    //finally
    [container setContentSize:(CGSizeMake(container.frame.size.width, h))];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)addAccount:(id)sender{
    if([_username.text isEqualToString:@""] || [_password.text isEqualToString:@""]){
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Failed" message:@"Empty Input Found" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction * okAction=[UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            //
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
            //
        }];
        return;
    }
    
    if(_aliyunAccountModel){
        [AliyunAccountModel removeAccountInStore:[_aliyunAccountModel computeAliyunAccountModelKey]];
        [_aliyunAccountModel setTokenType:(_accountType.selectedSegmentIndex==0?@"AK":@"UP")];
        [_aliyunAccountModel setUsername:_username.text];
        [_aliyunAccountModel setPassword:_password.text];
    }else{
        if(_accountType.selectedSegmentIndex==0){
            _aliyunAccountModel=[[AliyunAccountModel alloc]initWithAKId:_username.text andAKSecret:_password.text];
        }else{
            _aliyunAccountModel=[[AliyunAccountModel alloc]initWithUsername:_username.text andPassword:_password.text];
        }
    }
    [_aliyunAccountModel setNickname:_nickname.text];
    [_aliyunAccountModel setRegions:[_regionSG regionsOpened]];
    [AliyunAccountModel addAccountToStore:_aliyunAccountModel];
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField==_username){
        [_password becomeFirstResponder];
    }
    else if(textField==_nickname){
        [_username becomeFirstResponder];
    }
    else if (textField==_password){
        [textField resignFirstResponder];
    }
    return NO;
}

@end