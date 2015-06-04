//
//  MyXMPPManager.m
//  微信
//
//  Created by YangHao on 15/5/30.
//  Copyright (c) 2015年 YangHao. All rights reserved.
//

#import "MyXMPPManager.h"

MyXMPPManager *instance = nil;

@implementation MyXMPPManager{
    
    
    BOOL _isRegister;
}


+ (instancetype)shareManager{
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[[self class]alloc]init];
        
        [instance setupStream];
    });
    
    return instance;
    
}


//配置XMPP
- (void)setupStream {
    
    //1.创建XMPPStream对象
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //2.创建XMPPReconnect对象
    //可以帮助xmpp意外断开时，自动连接服务器
    XMPPReconnect *xmppReconnect = [[XMPPReconnect alloc] init];
    [xmppReconnect activate:_xmppStream];
    
    //3.创建 XMPPRosterCoreDataStorage 花名册存储对象
    //花名册对象是用于管理好友
    XMPPRosterCoreDataStorage *xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //创建花名册对象 XMPPRoster
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //将花名册添加到XMPP上使用
    [_xmppRoster activate:_xmppStream];
    
    //4.设置xmpp服务器信息：ip、端口号
    NSString *server = @"127.0.0.1"; //@"www.yanghao.com";
    [_xmppStream setHostName:server];
    //服务器的端口号，默认是5222
    [_xmppStream setHostPort:5222];
    
}


//1.连接(注册和登陆都要链接)
- (BOOL)connect {
    
    if (self.username.length == 0) {
        return NO;
    }
    
    //判断是否处于断开状态
    if (![_xmppStream isDisconnected]) {
        return NO;
    }
    
    //登陆用户的JID
    NSString *jidString = [NSString stringWithFormat:@"%@@127.0.0.1",self.username];
    XMPPJID *JID = [XMPPJID jidWithString:jidString];
    [_xmppStream setMyJID:JID];
    
    //连接服务器操作
    NSError *error = nil;
    BOOL success = [_xmppStream connectWithTimeout:60 error:&error];
    if (!success) {
        NSLog(@"连接错误:%@",error);
        
        return NO;
    }

    return YES;
}

//2.断开连接
- (void)disconnect {
    
    //下线
    [self goOffline];
    
    //断开连接
    [_xmppStream disconnect];
    
}

//上线
- (void)goOnline {
    //1.上线
    XMPPPresence *prsence = [[XMPPPresence alloc] init];  //type=available
    NSLog(@"%@",prsence.XMLString);
    //发送上线的消息
    [_xmppStream sendElement:prsence];
}

//离线
- (void)goOffline {
    //2.下线
    XMPPPresence *prsence = [XMPPPresence presenceWithType:@"unavailable"];
    NSLog(@"%@",prsence.XMLString);
    //发送上线的消息
    [_xmppStream sendElement:prsence];
}


#pragma mark - 操作的功能

//1.登陆
- (void)login:(NSString *)username password:(NSString *)password
 successBlock:(SucccessBlock)successBlock {
    
    self.username = username;
    self.password = password;
    self.loginBlock = successBlock;
    
    _isRegister = NO;
    
    //连接服务器
    [self connect];
}

//2.注册
- (void)registerUser:(NSString *)username password:(NSString *)password
        successBlock:(SucccessBlock)successBlock {
    
    self.username = username;
    self.password = password;
    self.registerBlock = successBlock;
    
    _isRegister = YES;
    
    //匿名连接
    //匿名ID
    XMPPJID *JID = [XMPPJID jidWithString:@"anonymous@127.0.0.1"];
    //设置连接的用户ID
    [_xmppStream setMyJID:JID];
    //连接
    BOOL success = [_xmppStream connectWithTimeout:-1 error:nil];
    if (!success) {
        NSLog(@"连接失败");
    }
    
}

//3.发送消息
/*
 发送的xml内容格式：
 <message type="chat" to="xiaoming@example.com">
 
 　　<body>Hello World!</body>
 
 </message>
 */
- (void)sendMessage:(NSString *)msg toUser:(NSString *)userJid {
    
    if (msg.length == 0 || userJid.length == 0) {
        return;
    }
    
    DDXMLElement *message = [DDXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:userJid];
    
    DDXMLElement *body = [DDXMLElement elementWithName:@"body" stringValue:msg];
    
    [message addChild:body];
    
    [_xmppStream sendElement:message];
    
    NSLog(@"发送：%@",message);
    
}

//4.添加好友
- (void)addFreind:(NSString *)freindUser {
    
    NSString *jid = [NSString stringWithFormat:@"%@@127.0.0.1",freindUser];
    XMPPJID *addJid = [XMPPJID jidWithString:jid];
    
    //添加好友并且设置昵称
    [_xmppRoster addUser:addJid withNickname:freindUser];
    

}


//5.获取好友列表
/*
 XML格式：
 <iq type="get"
 　　from="xiaoming@example.com"
 　　to="example.com"
 　　id="1234567">
 　　<query xmlns="jabber:iq:roster"/>
 <iq />
 
 type 属性，说明了该 iq 的类型为 get，与 HTTP 类似，向服务器端请求信息
 from 属性，消息来源，这里是你的 JID
 to 属性，消息目标，这里是服务器域名
 id 属性，标记该请求 ID，当服务器处理完毕请求 get 类型的 iq 后，响应的 result 类型 iq 的 ID 与 请求 iq 的 ID 相同
 <query xmlns="jabber:iq:roster"/> 子标签，说明了客户端需要查询 roster
 */
- (void)getFreind:(FethFreindBlock)freindBlock {
    self.freindBlcok = freindBlock;
    
    XMPPJID *myJID = _xmppStream.myJID;
    
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"from" stringValue:myJID.description];
    [iq addAttributeWithName:@"to" stringValue:myJID.domain];
    [iq  addAttributeWithName:@"id" stringValue:@"123456"];
    
    DDXMLElement *query = [DDXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    [iq addChild:query];
    
    
    [_xmppStream sendElement:iq];
}





#pragma mark - XMPPStream delegate
//1.连接服务器成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    
    NSLog(@"连接成功");
    
    if (_isRegister) { //注册
        
        //发送注册的请求
        
        NSString *jidString = [NSString stringWithFormat:@"%@@127.0.0.1",self.username];
        XMPPJID *JID = [XMPPJID jidWithString:jidString];
        //设置注册的用户ID
        [_xmppStream setMyJID:JID];
        
        //发送注册
        BOOL suucess = [_xmppStream registerWithPassword:self.password error:nil];
        if (!suucess) {
            NSLog(@"发送注册失败");
        }
        
    } else {  //登陆
        
        //发送登陆密码的验证
        NSError *error = nil;
        BOOL success = [_xmppStream authenticateWithPassword:self.password error:&error];
        
        if (!success) {
            NSLog(@"登陆的密码验证失败：%@",error);
        }
        
    }
    
}

//2.密码验证通过，登陆成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    
    NSLog(@"登陆成功");
    
    //上线
    [self goOnline];
    
    //回调block，将事件传出
    self.loginBlock();
}

//3.密码验证失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    NSLog(@"登陆失败");
}

//4.注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    
    NSLog(@"注册成功");
    
    //回调block，将事件传出
    self.registerBlock();
    
}

//5.注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error {
    
    NSLog(@"注册失败：%@",error);
}


//6.收到好友列表
/*
 XML格式：
 一个 IQ 响应：
 
 <iq type="result"
 　　id="1234567"
 　　to="xiaoming@example.com">
 　　<query xmlns="jabber:iq:roster">
 　　　　<item jid="xiaoyan@example.com" name="小燕" />
 　　　　<item jid="xiaoqiang@example.com" name="小强"/>
 　　<query />
 <iq />
 
 type 属性，说明了该 iq 的类型为 result，查询的结果
 <query xmlns="jabber:iq:roster"/> 标签的子标签 <item />，为查询的子项，即为 roster
 item 标签的属性，包含好友的 JID，和其它可选的属性，例如昵称等。
 */
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    
    if ([iq.type isEqualToString:@"result"]) {
        
        DDXMLElement *query = [iq childElement];
        
        if ([query.name isEqualToString:@"query"]) {
            
            //遍历query中的子标签
            
            NSMutableArray *freinds = [NSMutableArray array];
            for (DDXMLElement *item in [query children]) {
                NSString *name = [item attributeStringValueForName:@"name"];
                NSString *jid = [item attributeStringValueForName:@"jid"];
                
                if (name.length == 0 || jid.length == 0) {
                    continue;
                }
                
                //                NSLog(@"jid=%@,name=%@",jid,name);
                NSMutableDictionary *data = [NSMutableDictionary dictionary];
                
                [data setObject:name forKey:@"name"];
                [data setObject:jid forKey:@"jid"];
                [freinds addObject:data];
            }
            
            //回调block，将好友列表传出
            self.freindBlcok(freinds);
        }
        
    }
    
    
    return YES;
}

//7.接受好友的消息
/*
 * XML格式：
 * <message xmlns="jabber:client"
 id="37Moq-35"
 to="study20@xmpp.wxhl.com/e5c18b0d"
 from="wxhl@xmpp.wxhl.com/spark"  type="chat">
 <body>haha</body>
 <thread>69TU9u</thread>
 <x xmlns="jabber:x:event">
 <offline/>
 <composing/>
 </x>
 </message>
 */
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    
    if ([message isChatMessageWithBody]) {
        //1.取得消息的内容
        NSString *body = [message body];
        XMPPJID *fromJID = message.from;
        NSString *fromUser = fromJID.user;
        
        NSDictionary *msg = @{
                              @"fromUser":fromUser,
                              @"text":body,
                              };
        
        
        //发送通知，将消息传出
        [[NSNotificationCenter defaultCenter] postNotificationName:kReceiveMessageNotification object:nil userInfo:msg];
    }
}


@end
