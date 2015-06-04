//
//  LoginViewController.h
//  微信
//
//  Created by YangHao on 15/5/30.
//  Copyright (c) 2015年 YangHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController{
    
    
    IBOutlet UITextField *_userFiled;
    
    IBOutlet UITextField *_passFiled;
    
    
}
- (IBAction)loginAction:(id)sender;

@end
