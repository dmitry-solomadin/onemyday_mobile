//
//  HiResImageDelegate.h
//  Onemyday
//
//  Created by dmitry.solomadin on 07.05.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HiResImageDelegate <NSObject>
@optional
- (void)hiresImageAvailable:(UIImage *)aimage;
@end
