//
//  Story.m
//  OneMyDayIPhone
//
//  Created by Admin on 2/9/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "Story.h"



@implementation Story

@synthesize text = _text;
@synthesize image = _image;

- (id)initWithText:(NSString*)text {
    if ((self = [super init])) {
        self.text = text;
        //self.image = image;
    }
    return self;
}

@end
