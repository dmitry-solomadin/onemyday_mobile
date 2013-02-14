//
//  Story.m
//  OneMyDayIPhone
//
//  Created by Admin on 2/9/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "Story.h"



@implementation Story

@synthesize title = _title;
@synthesize thumbImageUrl = _thumbImageUrl;

- (id)initWithTitle:(NSString*)title andImageUrl: (NSString*)thumbImageUrl{
    if ((self = [super init])) {
        self.title = title;
        self.thumbImageUrl = thumbImageUrl;
    }
    return self;
}

@end
