//
//  G7APMStatusMenu.m
//  TruckManager
//
//  Created by 李响 on 2019/8/7.
//  Copyright © 2019 G7. All rights reserved.
//

#import "CLAPMStatusMenu.h"
#import <CLAPMMonitor.h>
#import <mach/mach.h>

static NSUInteger const kMemoryThresHold = 250;
static NSUInteger const kCpuThresHold = 50;
static NSUInteger const kFpsThresHold = 30;
static NSInteger const kMenuTag = 20000;
static CLAPMStatusMenu *sharedMenu = nil;

@interface CLAPMStatusMenu ()<CLAPMMonitorObserver>

@property (nonatomic, weak) UIWindow *window;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UILabel *lblResidentMemory;
@property (nonatomic, strong) UILabel *lblCpu;
@property (nonatomic, strong) UILabel *lblFps;
@property (nonatomic, assign) NSUInteger residentMemoryUsage;
@property (nonatomic, assign) NSUInteger cpuUsage;
@property (nonatomic, assign) NSUInteger fps;

@end

@implementation CLAPMStatusMenu

+ (CLAPMStatusMenu *)showInWindow:(UIWindow *)window {
    if (sharedMenu) {
        [window bringSubviewToFront:sharedMenu];
        return sharedMenu;
    }
    CGFloat topMargin = 0;
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeArea = window.safeAreaInsets;
        topMargin = safeArea.top;
    } else {
        // Fallback on earlier versions
    }
    CGSize windowSize = window.bounds.size;
    CLAPMStatusMenu *menu = [[CLAPMStatusMenu alloc] initWithFrame:CGRectMake((windowSize.width - 80) * 0.5, 20 + topMargin, 80, 30)];
    menu.tag = kMenuTag;
    sharedMenu = menu;
    [window addSubview:menu];
    [window bringSubviewToFront:menu];
    return menu;
}

+ (void)dissmiss {
    [sharedMenu removeFromSuperview];
    sharedMenu = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];

        UIStackView *stackView = [[UIStackView alloc] initWithFrame:self.bounds];
        stackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        stackView.axis = UILayoutConstraintAxisVertical;
        stackView.distribution = UIStackViewDistributionFillEqually;
        stackView.alignment = UIStackViewAlignmentFill;
        [self addSubview:stackView];

        self.lblResidentMemory = [self createLabel];
        [stackView addArrangedSubview:self.lblResidentMemory];

        self.lblCpu = [self createLabel];
        [stackView addArrangedSubview:self.lblCpu];

        self.lblFps = [self createLabel];
        [stackView addArrangedSubview:self.lblFps];

        UIPanGestureRecognizer *ges = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGes:)];
        [self addGestureRecognizer:ges];
    }
    return self;
}

- (UILabel *)createLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:8.0];
    label.textColor = [UIColor whiteColor];
    return label;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [CLAPMMonitor addObserver:self];
}

- (void)panGes:(UIPanGestureRecognizer *)ges {
    CGPoint point = [ges translationInView:self];
    CGFloat x = self.center.x + point.x;
    CGFloat y = self.center.y + point.y;
    self.center = CGPointMake(x, y);
    [ges setTranslation:CGPointZero inView:self];
}

- (void)setResidentMemoryUsage:(NSUInteger)residentMemoryUsage {
    if (residentMemoryUsage < kMemoryThresHold) {
        self.lblResidentMemory.textColor = [UIColor whiteColor];
    } else {
        self.lblResidentMemory.textColor = [UIColor redColor];
    }
    self.lblResidentMemory.text = [NSString stringWithFormat:@"memory: %luMB", (unsigned long)residentMemoryUsage];
}

- (void)setCpuUsage:(NSUInteger)cpuUsage {
    if (cpuUsage < kCpuThresHold) {
        self.lblCpu.textColor = [UIColor whiteColor];
    } else {
        self.lblCpu.textColor = [UIColor redColor];
    }
    self.lblCpu.text = [NSString stringWithFormat:@"cpu: %lu%%", (unsigned long)cpuUsage];
}

- (void)setFps:(NSUInteger)fps {
    if (fps > kFpsThresHold) {
        self.lblFps.textColor = [UIColor whiteColor];
    } else {
        self.lblFps.textColor = [UIColor redColor];
    }
    self.lblFps.text = [NSString stringWithFormat:@"fps: %lu", (unsigned long)fps];
}

#pragma mark - CLAPMMonitorDelegate
- (void)valueDidUpdate:(CLAPMModel *_Nonnull)model {
    self.cpuUsage = model.cpu;
    self.residentMemoryUsage = model.memory;
    self.fps = model.fps;
}
@end
