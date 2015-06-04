//
//  ViewController.h
//  微信
//
//  Created by YangHao on 15/5/10.
//  Copyright (c) 2015年 YangHao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;
@interface MessageViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    
 
    IBOutlet UIView *inputView;
    
    IBOutlet UITextField *textField;
    
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic,retain)NSMutableArray *data;

@property(nonatomic,strong)User *toUser;


- (IBAction)doneAction:(id)sender;

- (IBAction)editAction:(id)sender;



@end

