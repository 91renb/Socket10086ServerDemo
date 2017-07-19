//
//  main.m
//  测试Socket连接
//
//  Created by 任波 on 2017/7/5.
//  Copyright © 2017年 renb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyService.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //1.创建一个服务监听对象
        MyService *service = [[MyService alloc]init];
        //2.开始监听
        [service startService];
        //3.开启主运行循环，让服务不能停（服务器一般要永久开启）
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
