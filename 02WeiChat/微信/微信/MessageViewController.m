//
//  ViewController.m
//  微信
//
//  Created by YangHao on 15/5/10.
//  Copyright (c) 2015年 YangHao. All rights reserved.
//

#import "MessageViewController.h"

#import "Message.h"

#import "MessageCell.h"

#import "MyXMPPManager.h"
#import "User.h"
@interface MessageViewController ()

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = self.toUser.username;
    
    //1.加载数据
    [self loadData];
    
    //2.创建视图
    [self initViews];
    
    //3.通知，监听键盘弹出事件
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    
    //监听是否有消息的事件
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveMsg:) name:kReceiveMessageNotification object:nil];
    
}

//视图显示后就将单元格滑动到最后
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSInteger lastIndex = _data.count-1;  //最后一个消息的下标
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastIndex inSection:0];
    
    //滚动指定的cell  UITableViewScrollPositionBottom:在视图的底部
    [_tableView scrollToRowAtIndexPath:lastIndexPath
                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


//监听到键盘弹出后执行的方法
- (void)showKeyboard:(NSNotification *)notification{
    
//    NSLog(@"%@",notification.userInfo);
    
    //取得键盘的frame
    NSValue *rectValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [rectValue CGRectValue];
//    frame.size.height
    
    //获取高度 两种方式
//    CGFloat height = CGRectGetHeight(frame);
    CGFloat height = frame.size.height;
    
    //CGAffineTransformMakeTranslation 每次在原始的transform 上修改
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    inputView.transform = CGAffineTransformMakeTranslation(0, -height);
    _tableView.transform = CGAffineTransformMakeTranslation(0, -height);
    [UIView commitAnimations];
    
}

//监听到新消息事件后
- (void)receiveMsg:(NSNotification *)notification {
    
    NSDictionary *msg = notification.userInfo;
    
    //    NSString *fromUser = msg[@"fromUser"];
    NSString *text = msg[@"text"];
    
    [self addMessage:text isSelf:NO];
}

//创建视图
- (void)initViews{
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    inputView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"toolbar_bottom_bar"]];
    textField.returnKeyType = UIReturnKeySend;
    textField.delegate = self;
    
}

//加载数据

- (void)loadData{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"messages" ofType:@"plist"];
    NSArray *msgArray = [[NSArray alloc]initWithContentsOfFile:path];
    self.data = [NSMutableArray arrayWithCapacity:msgArray.count];
    
    for (NSDictionary *dic in msgArray) {
        
        Message *message = [[Message alloc]init];
        message.content = dic[@"content"];
        message.time = dic[@"time"];
        message.icon = dic[@"icon"];
        message.isSelf = [dic[@"self"] boolValue];
        
        [self.data addObject:message];
    }
    
//    self.
    
    
}

#pragma  mark - tableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"messageCell";
    
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        
        cell = [[MessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    //从数组中取得对应消息的Model
    Message *message = [self.data objectAtIndex:indexPath.row];
//    cell.textLabel.text = message.content;
    
    //将model交给cell显示
    [cell setMsg:message];
    
    return cell;
    
}

//计算单元格的高度

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Message *msg = self.data[indexPath.row];
    
    NSString *content = msg.content;
    
    CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(180, 1000)];
    CGFloat height = size.height;
//    NSLog(@"%f",height);
    
    return height+40;
}

//单击单元格 收起键盘 输入框退回原来的高度
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //收起键盘的两种方式
//    [textField resignFirstResponder];
    [self.view endEditing:YES];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    inputView.transform = CGAffineTransformIdentity;
    self.tableView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    
}

#pragma mark -  编辑单元格的协议方法

//单元格上面的删除、插入被点击调用的协议方法
//此协议方法实现后，单元格左滑会出现删除按钮

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //1.删除数组中的消息对象
        [self.data removeObjectAtIndex:indexPath.row];
        
        //2.刷新单元格
//        [self.tableView reloadData];
        
        //从tableView中删除一个单元格
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
    
}

//这个没有效果 不知为何
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    
    //调换数组中的消息对象位置
    [self.data exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"***");
}


//点击完成按钮后 取消编辑状态
- (IBAction)doneAction:(id)sender {
    
    [self.tableView setEditing:NO animated:YES];
}


//打开编辑状态
- (IBAction)editAction:(id)sender {
    
    //单元格是否可以多选
//    _tableView.allowsMultipleSelectionDuringEditing = YES;
    
    //
    [self.tableView setEditing:YES animated:YES];
    
}

#pragma mark - textField Delegate

//点击发送后的事件方法
- (BOOL)textFieldShouldReturn:(UITextField *)testField{
   
    //1.获取输入框的内容
    NSString *text = testField.text;
    
    //2.添加消息到tableView
    [self addMessage:text isSelf:YES];
    
    //3.输入框置空
    textField.text = nil;
    
    
    //4.发送消息
    [[MyXMPPManager shareManager] sendMessage:text toUser:self.toUser.jid];
 
    return YES;
}

- (void)addMessage:(NSString *)text isSelf:(BOOL)isSelf {
    
    //2.创建消息对象
    Message *msg = [[Message alloc] init];
    msg.content = text;
    msg.icon = isSelf?@"icon01.jpg":@"icon02.jpg";
    msg.isSelf = isSelf;
    
    //3.消息对象加入数组
    [self.data addObject:msg];
    
    
    
    //4.刷新tableView,显示新消息单元格
    [_tableView reloadData];
    
    
    NSInteger lastIndex = _data.count-1;  //最后一个消息的下标
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastIndex inSection:0];
    
    //往_tableView中插入一个单元格
    //    [_tableView insertRowsAtIndexPaths:@[lastIndexPath]
    //                      withRowAnimation:UITableViewRowAnimationRight];
    
    
    //5.滚动指定的cell  UITableViewScrollPositionBottom:在视图的底部
    [_tableView scrollToRowAtIndexPath:lastIndexPath
                      atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
}

@end
