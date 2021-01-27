//
//  CLViewController.m
//  CLAPMStatusMenu
//
//  Created by lixiang on 01/27/2021.
//  Copyright (c) 2021 lixiang. All rights reserved.
//

#import "CLViewController.h"
#import <CLAPMStatusMenu/CLAPMStatusMenu.h>
#import <CLAPMStatusMenu/CLAPMMonitor.h>
#import "CLAppDelegate.h"

@interface CLViewController ()

@end

@implementation CLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [CLAPMMonitor startMonitoring];
    [CLAPMStatusMenu showInWindow: UIApplication.sharedApplication.keyWindow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
