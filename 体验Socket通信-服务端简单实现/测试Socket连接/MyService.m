//
//  MyService.m
//  测试Socket连接
//
//  Created by 任波 on 2017/7/5.
//  Copyright © 2017年 renb. All rights reserved.
//

#import "MyService.h"
#import "GCDAsyncSocket.h"

@interface MyService ()<GCDAsyncSocketDelegate>
/** 保存服务端的Socket对象 */
@property (nonatomic, strong) GCDAsyncSocket *serviceSocket;
/** 保存客户端的所有Socket对象 */
@property (nonatomic, strong) NSMutableArray *clientSocketArr;

@end

@implementation MyService

//开启10086服务:5288
- (void)startService {
    NSError *error = nil;
    // 绑定端口 + 开启监听
    [self.serviceSocket acceptOnPort:5288 error:&error];
    if (!error) {
        NSLog(@"服务开启成功！");
    } else {
        NSLog(@"服务开启失败！");
    }
}

#pragma mark -- 实现代理的方法 如果有客户端的Socket连接到服务器，就会调用这个方法。
- (void)socket:(GCDAsyncSocket *)serviceSocket didAcceptNewSocket:(GCDAsyncSocket *)clientSocket {
    static NSInteger index = 1;
    NSLog(@"客户端【%ld】已连接到服务器!", index++);
    //1.保存客户端的Socket（客户端的Socket被释放了，连接就会关闭）
    [self.clientSocketArr addObject:clientSocket];
    
    //提供服务(客户端一连接到服务器，就打印下面的内容)
    NSMutableString *serviceStr = [[NSMutableString alloc]init];
    [serviceStr appendString:@"========欢迎来到10086在线服务========\n"];
    [serviceStr appendString:@"请输入下面的数字选择服务...\n"];
    [serviceStr appendString:@" [0] 在线充值\n"];
    [serviceStr appendString:@" [1] 在线投诉\n"];
    [serviceStr appendString:@" [2] 优惠信息\n"];
    [serviceStr appendString:@" [3] special services\n"];
    [serviceStr appendString:@" [4] 退出\n"];
    [serviceStr appendString:@"=====================================\n"];
    // 服务端给客户端发送数据
    [clientSocket writeData:[serviceStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    //2.监听客户端有没有数据上传 (参数1：超时时间，-1代表不超时)
    /**
     *  timeout: 超时时间，-1 代表不超时
     *  tag:标识作用，现在不用就写0
     */
    [clientSocket readDataWithTimeout:-1 tag:0];
}

#pragma mark -- 服务器端 读取 客户端请求（发送）的数据。在服务端接收客户端数据，这个方法会被调用
- (void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag {
    //1.获取客户端发送的数据
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSInteger index = [self.clientSocketArr indexOfObject:clientSocket];
    NSLog(@"接收到客户端【%ld】发送的数据:%@", index + 1, str);
    // 把字符串转成数字
    NSInteger num = [str integerValue];
    NSString *responseStr = nil;
    //服务器对应的处理的结果
    switch (num) {
        case 0:
            responseStr = @"在线充值服务暂停中...\n";
            break;
        case 1:
            responseStr = @"在线投诉服务暂停中...\n";
            break;
        case 2:
            responseStr = @"优惠信息没有\n";
            break;
        case 3:
            responseStr = @"没有特殊服务\n";
            break;
        case 4:
            responseStr = @"恭喜你退出成功!\n";
            break;
        default:
            break;
    }
    //2.服务端给客户端发送数据：服务端处理请求，返回数据(data)给客户端
    [clientSocket writeData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    //写完数据后 判断
    if (num == 4) {
        //移除客户端，就会关闭连接
        [self.clientSocketArr removeObject:clientSocket];
    }
    
    //由于框架内部的实现，每次读完数据后，都要调用一次监听数据的方法（保证能接收到客户端第二次上传的数据）
    [clientSocket readDataWithTimeout:-1 tag:0];
}

- (GCDAsyncSocket *)serviceSocket {
    if (!_serviceSocket) {
        // 1.创建一个Socket对象
        // serviceSocket 服务端的Socket只监听 有没有客户端请求连接
        // 队列：代理的方法在哪个队列里调用 (子线程的队列)
        _serviceSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _serviceSocket;
}

- (NSMutableArray *)clientSocketArr {
    if (!_clientSocketArr) {
        _clientSocketArr = [[NSMutableArray alloc]init];
    }
    return _clientSocketArr;
}

@end
