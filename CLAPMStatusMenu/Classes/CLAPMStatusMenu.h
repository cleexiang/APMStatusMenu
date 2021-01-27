//
//  G7APMStatusMenu.h
//  TruckManager
//
//  Created by 李响 on 2019/8/7.
//  Copyright © 2019 G7. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLAPMStatusMenu : UIView

+ (CLAPMStatusMenu *)showInWindow:(UIWindow *)window;
+ (void)dissmiss;

@end

NS_ASSUME_NONNULL_END
