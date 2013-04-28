//
//  StoryShadowWrapView.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 19.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "StoryShadowWrapView.h"
#import "AsyncImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation StoryShadowWrapView

- (id)initWithFrame:(CGRect)frame andAsyncView:(AsyncImageView *)aview
{
    self = [super initWithFrame:frame];
    if (self) {
        aview.layer.cornerRadius = 5.0;
        aview.layer.masksToBounds = YES;
        
        self.layer.cornerRadius = 5.0;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 1.5;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:5.0].CGPath;
        self.clipsToBounds = NO;
    }
    return self;
}

@end
