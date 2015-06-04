//
//  Message.h
//  微信
//
//  Created by YangHao on 15/5/10.
//  Copyright (c) 2015年 YangHao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property(nonatomic,copy)NSString *content; //内容
@property(nonatomic,copy)NSString *time; //时间
@property(nonatomic,copy)NSString *icon; //头像
@property(nonatomic,assign)BOOL isSelf;

@end
