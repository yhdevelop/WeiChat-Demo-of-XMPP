//
//  RegisterViewController.m
//  微信
//
//  Created by YangHao on 15/5/30.
//  Copyright (c) 2015年 YangHao. All rights reserved.
//

#import "RegisterViewController.h"
#import "MyXMPPManager.h"

@implementation RegisterViewController


- (IBAction)registerAction:(id)sender {
    
    NSString *user = _userField.text;
    NSString *pass = _passField.text;
    
    if (user.length == 0 || pass.length == 0) {
        return;
    }
    
    __weak RegisterViewController *weakSelf = self;
    [[MyXMPPManager shareManager] registerUser:user password:pass successBlock:^{
        
        [weakSelf dismissViewControllerAnimated:YES completion:NULL];
        
    }];
}

- (IBAction)cancleAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
