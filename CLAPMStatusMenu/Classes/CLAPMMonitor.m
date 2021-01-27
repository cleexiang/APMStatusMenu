//
//  CLAPMMonitor.m
//  G7_APMMonitor
//
//  Created by LaiXuefei on 2019/12/5.
//  Copyright © 2019 G7. All rights reserved.
//

#import "CLAPMMonitor.h"
#import <mach/mach.h>

@interface CLAPMMonitor ()

@property (nonatomic, strong) NSHashTable *observers;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) CLAPMModel *apmModel;
@end
@implementation CLAPMMonitor
//开启监控
+ (void)startMonitoring {
    [[CLAPMMonitor shareInstance] startMonitoring];
}

//关闭监控
+ (void)stopMonitoring {
    [[CLAPMMonitor shareInstance] stopMonitoring];
}

// 根据类型获取监控值
+ (NSInteger)valueWithType:(CLAPMMonitorType)type {
    return [[CLAPMMonitor shareInstance] valueWithType:type];
}

//添加observer
+ (void)addObserver:(id<CLAPMMonitorObserver>)observer {
    if (!observer || [[CLAPMMonitor shareInstance].observers containsObject:observer]) {
        return;
    }
    [[CLAPMMonitor shareInstance].observers addObject:observer];
}

//移除observer
+ (void)removeObserver:(id<CLAPMMonitorObserver>)observer {
    if (!observer || ![[CLAPMMonitor shareInstance].observers containsObject:observer]) {
        return;
    }
    [[CLAPMMonitor shareInstance].observers removeObject:observer];
}

#pragma mark - private
+ (instancetype)shareInstance {
    static CLAPMMonitor *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      obj = [[CLAPMMonitor alloc] init];
    });
    return obj;
}

- (NSHashTable *)observers {
    if (!_observers) {
        //使用weak存储对象，当对象被销毁的时候自动将其从集合中移除。
        _observers = [NSHashTable weakObjectsHashTable];
    }
    return _observers;
}

- (CLAPMModel *)apmModel {
    if (!_apmModel) {
        _apmModel = [[CLAPMModel alloc] init];
    }
    return _apmModel;
}

// 开始监控
- (void)startMonitoring {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTimer:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

// 停止监控
- (void)stopMonitoring {
    if (_observers) {
        [_observers removeAllObjects];
    }
    [_displayLink invalidate];
    _displayLink = nil;
}

// 根据类型获取监控值
- (NSInteger)valueWithType:(CLAPMMonitorType)type {
    switch (type) {
    case CLAPMMonitorTypeCPU:
        return self.apmModel.cpu;
    case CLAPMMonitorTypeMemory:
        return self.apmModel.memory;
    case CLAPMMonitorTypeFPS:
        return self.apmModel.fps;
    default:
        return 0;
    }
}

#pragma mark - monitor
//
- (void)displayLinkTimer:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1)
        return;
    _lastTime = link.timestamp;
    NSInteger fps = (NSInteger)_count / delta;
    _count = 0;

    NSInteger cpu = [self cpuUsage];
    NSInteger memory = [self residentMemoryUsage];
    //是否和上次有变更（因为我们获取的是整数）
    BOOL isUpdated = (self.apmModel.fps != fps || self.apmModel.cpu != cpu || self.apmModel.memory != memory) ? YES : NO;
    if (isUpdated) {
        self.apmModel.fps = fps;
        self.apmModel.cpu = [self cpuUsage];
        self.apmModel.memory = [self residentMemoryUsage];

        // 若需要得知数值变化，则使用block
        for (id<CLAPMMonitorObserver> observer in _observers) {
            if ([observer respondsToSelector:@selector(valueDidUpdate:)]) {
                [observer valueDidUpdate:self.apmModel];
            }
        }
    }
}

//获取memory
- (CGFloat)residentMemoryUsage {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&vmInfo, &count);

    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    return (NSInteger)(vmInfo.phys_footprint / 1024.0 / 1024.0);
}

//获取cpu
- (CGFloat)cpuUsage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;

    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }

    thread_array_t thread_list;
    mach_msg_type_number_t thread_count;

    thread_info_data_t thinfo;
    mach_msg_type_number_t thread_info_count;

    thread_basic_info_t basic_info_th;

    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }

    long total_time = 0;
    long total_userTime = 0;
    CGFloat total_cpu = 0;
    int j;

    // for each thread
    for (j = 0; j < (int)thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        basic_info_th = (thread_basic_info_t)thinfo;
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            total_time = total_time + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            total_userTime = total_userTime + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            total_cpu = total_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100;
        }
    }

    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);

    return (NSInteger)total_cpu;
}
@end
