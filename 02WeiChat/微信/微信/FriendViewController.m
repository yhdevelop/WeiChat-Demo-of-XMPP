//
//  FriendViewController.m
//  微信
//
//  Created by YangHao on 15/5/30.
//  Copyright (c) 2015年 YangHao. All rights reserved.
//

#import "FriendViewController.h"
#import "User.h"
#import "MyXMPPManager.h"
#import "MessageViewController.h"

@implementation FriendViewController{
    
        NSString *identify;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"好友列表";
    self.data = [NSMutableArray array];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [self.view addSubview:_tableView];
    
    //设置添加好友按钮
    UIButton *addFriendsBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    addFriendsBtn.frame = CGRectMake(0, 100, 150, 40);
//    addFriendsBtn.backgroundColor = [UIColor orangeColor];
    [addFriendsBtn setTitle:@"添加好友" forState:UIControlStateNormal];
    [addFriendsBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [addFriendsBtn addTarget:self action:@selector(addFreindAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:addFriendsBtn];
    UIBarButtonItem *addFriendsItem = [[UIBarButtonItem alloc]initWithCustomView:addFriendsBtn];
    self.navigationItem.rightBarButtonItem = addFriendsItem;
    
    //注册单元格的类型
    identify = @"freindCell";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identify];
    
    __weak FriendViewController *this = self;
    [[MyXMPPManager shareManager] getFreind:^(NSArray *freinds) {
        
        
        for (NSDictionary *dic in freinds) {
            User *user = [[User alloc] init];
            user.username = dic[@"name"];
            user.jid = dic[@"jid"];
            
            [this.data addObject:user];
        }
        
        //刷新tableView显示数据
        [self.tableView reloadData];
    }];
}

#pragma  添加好友

- (void)addFreindAction:(UIButton *)button{
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"添加好友" message:@"请输入好友的用户名" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
    
//    [MyXMPPManager shareManager]addFreind:<#(NSString *)#>
    
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
    
    User *user = self.data[indexPath.row];
    cell.textLabel.text = user.username;
    cell.detailTextLabel.text = user.jid;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    User *user = self.data[indexPath.row];
    
    MessageViewController *msgVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageViewController"];
    [self.navigationController pushViewController:msgVC animated:YES];
    
    msgVC.toUser = user;
}


#pragma  alertViewDelegate 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
        return;
    }
    else{
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        NSString *userName = textField.text;
        
        [[MyXMPPManager shareManager]addFreind:userName];
        
//        [self.tableView reloadData];
    }
    
    
}


@end
