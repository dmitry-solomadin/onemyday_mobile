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
@synthesize photos = _photos;

- (id)initWithTitle:(NSString*)title andPhotos: (NSArray*)photos{
    if ((self = [super init])) {
        self.title = title;
        self.photos = photos;
    }
    return self;
}

@end
