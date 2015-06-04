//
//  FriendViewController.h
//  微信
//
//  Created by YangHao on 15/5/30.
//  Copyright (c) 2015年 YangHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property(nonatomic,strong)NSMutableArray *data;

@property(nonatomic,strong)UITableView *tableView;
@end
