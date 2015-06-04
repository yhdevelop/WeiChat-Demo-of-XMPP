//
//  MessageCell.m
//  微信
//
//  Created by YangHao on 15/5/10.
//  Copyright (c) 2015年 YangHao. All rights reserved.
//

#import "MessageCell.h"
#import "Message.h"

@implementation MessageCell


//若cell是从xib中加载 则会调用此方法
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //创建子视图
        [self _initViews];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
    
}

//这里只做子视图的创建和属性的初始化，不设置frame和加载数据
- (void)_initViews{
    
    _userImg = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self.contentView addSubview:_userImg];
    
    _bgImg = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self.contentView addSubview:_bgImg];
    
    _msgLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _msgLabel.font = [UIFont systemFontOfSize:16];
    _msgLabel.textColor = [UIColor blackColor];
    _msgLabel.numberOfLines = 0;
    [self.contentView addSubview:_msgLabel];
    
}

//复写set方法 告诉系统调用layoutSubviews

- (void)setMsg:(Message *)msg{
    
    if (_msg != msg) {
        
        _msg = msg;
        
        //告诉系统，需要调用layoutSubviews,

        [self setNeedsLayout];
    }
}

/**
 *  此视图快要被渲染引擎渲染的时候调用
 *
 1. 给子视图填充数据
 2. 布局子视图，设置子视图的frame
 */

- (void)layoutSubviews{
    
    //调用父类layoutSubviews
    [super layoutSubviews];
    
    //填充数据
    UIImage *image1 = [UIImage imageNamed:@"chatfrom_bg_normal"]; //对方的聊天信息背景 绿色
    UIImage *image2 = [UIImage imageNamed:@"chatto_bg_normal"]; //自己的聊天信息背景 白色
    
    UIImage *image = _msg.isSelf ? image2 : image1;
    
    //拉伸图片
    image = [image stretchableImageWithLeftCapWidth:image.size.width*.5 topCapHeight:image.size.height*.7];
    _userImg.image = [UIImage imageNamed:self.msg.icon];
    _bgImg.image = image;
    _msgLabel.text = self.msg.content;

    //获取字体的size
    CGSize size = [_msg.content sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(180, 1000)];
    
    //布局
    if (_msg.isSelf) {
        
        _userImg.frame = CGRectMake(kScreenWidth - 50, 10, 40, 40);
        _bgImg.frame = CGRectMake(100, 10, 220, size.height+30);
        _msgLabel.frame = CGRectMake(120, 20, 180, size.height);
        
    }else{
        
        _userImg.frame = CGRectMake(10, 10, 40, 40);
        _bgImg.frame = CGRectMake(60, 10, 220, size.height+30);
        _msgLabel.frame = CGRectMake(80, 20, 180, size.height);

    }
}

@end
