//
//  UIApplication+NetworkActivity.m
//  Onemyday
//
//  Created by dmitry.solomadin on 07.07.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "UIApplication+NetworkActivity.h"
static NSInteger activityCount = 0;
@implementation UIApplication (NetworkActivity)

- (void)showNetworkActivityIndicator {
    if ([[UIApplication sharedApplication] isStatusBarHidden]) return;
    @synchronized ([UIApplication sharedApplication]) {
        if (activityCount == 0) {
            [self setNetworkActivityIndicatorVisible:YES];
        }
        activityCount++;
    }
}

- (void)hideNetworkActivityIndicator {
    if ([[UIApplication sharedApplication] isStatusBarHidden]) return;
    @synchronized ([UIApplication sharedApplication]) {
        activityCount--;
        if (activityCount <= 0) {
            [self setNetworkActivityIndicatorVisible:NO];
            activityCount=0;
        }
    }
}

@end
