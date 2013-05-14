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
        aview.layer.borderColor = [[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1] CGColor];
        aview.layer.borderWidth = 1;
        
        self.layer.cornerRadius = 5.0;
        self.layer.shadowColor = [[UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1] CGColor];
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 1.5;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:5.0].CGPath;
        self.clipsToBounds = NO;
        
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        [whiteView setBackgroundColor:[UIColor whiteColor]];
        whiteView.layer.cornerRadius = 5.0;
        whiteView.layer.masksToBounds = YES;
        
        [whiteView addSubview:aview];
        [self addSubview:whiteView];
    }
    return self;
}

@end
