//
//  RegisterViewController.h
//  微信
//
//  Created by YangHao on 15/5/30.
//  Copyright (c) 2015年 YangHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController{
    
    IBOutlet UITextField *_userField;
    
    IBOutlet UITextField *_passField;
    
    
}
- (IBAction)registerAction:(id)sender;

- (IBAction)cancleAction:(id)sender;


@end
