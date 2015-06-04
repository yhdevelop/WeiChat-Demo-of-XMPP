//
//  LoginViewController.m
//  微信
//
//  Created by YangHao on 15/5/30.
//  Copyright (c) 2015年 YangHao. All rights reserved.
//

#import "LoginViewController.h"
#import "MyXMPPManager.h"
#import "FriendViewController.h"
@implementation LoginViewController


- (IBAction)loginAction:(id)sender {
    
    NSString *user = _userFiled.text;
    NSString *pass = _passFiled.text;
    
    if (user.length == 0 || pass.length == 0) {
        return;
    }
    
    MyXMPPManager *xmppManager = [MyXMPPManager shareManager];

    //防止循环引用
    __weak LoginViewController *weakSelf = self;
    [xmppManager login:user password:pass successBlock:^{
        
        __strong LoginViewController *strongSelf = weakSelf;
        
        [[[UIAlertView alloc] initWithTitle:@"恭喜" message:@"登陆成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        
        FriendViewController *freind = [self.storyboard instantiateViewControllerWithIdentifier:@"FreindViewController"];
        
        //此处登陆后不需要在返回到登陆页面，故这里可把他当作window的根视图控制器
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:freind];
        
        //block中直接用self 会循环引用 blok 被copy
        strongSelf.view.window.rootViewController = nav;
        
        
    }];
    
}
@end
