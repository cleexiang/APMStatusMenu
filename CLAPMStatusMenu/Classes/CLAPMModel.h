//
//  CLAPMModel.h
//  APMStatusMenu
//
//  Created by cleexiang on 2019/12/12.
//  Copyright © 2019 cleexiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLAPMModel : NSObject
@property (nonatomic, assign) NSInteger cpu;
@property (nonatomic, assign) NSInteger memory;
@property (nonatomic, assign) NSInteger fps;
@end

NS_ASSUME_NONNULL_END
