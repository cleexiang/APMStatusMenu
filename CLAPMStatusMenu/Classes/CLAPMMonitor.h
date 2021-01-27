//
//  CLAPMMonitor.h
//  G7_APMMonitor
//
//  Created by LaiXuefei on 2019/12/5.
//  Copyright © 2019 G7. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CLAPMModel.h>

typedef NS_ENUM(NSUInteger, CLAPMMonitorType) {
    CLAPMMonitorTypeCPU,
    CLAPMMonitorTypeMemory,
    CLAPMMonitorTypeFPS
};

@protocol CLAPMMonitorObserver<NSObject>
- (void)valueDidUpdate:(CLAPMModel *_Nonnull)model;
@end

NS_ASSUME_NONNULL_BEGIN

@interface CLAPMMonitor : NSObject
//开启监控
+ (void)startMonitoring;

//关闭监控
+ (void)stopMonitoring;

//添加observer
+ (void)addObserver:(id<CLAPMMonitorObserver>)observer;

//移除observer
+ (void)removeObserver:(id<CLAPMMonitorObserver>)observer;

// 根据类型获取监控值
+ (NSInteger)valueWithType:(CLAPMMonitorType)type;

@end

NS_ASSUME_NONNULL_END
