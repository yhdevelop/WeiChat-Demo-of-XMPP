//
//  MessageCell.h
//  微信
//
//  Created by YangHao on 15/5/10.
//  Copyright (c) 2015年 YangHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Message;

@interface MessageCell : UITableViewCell{
    
    //子视图
    UIImageView *_userImg; //用户头像
    UIImageView *_bgImg; //背景
    UILabel *_msgLabel; //消息内容

}

//数据Model
@property(nonatomic,retain)Message *msg;


@end
