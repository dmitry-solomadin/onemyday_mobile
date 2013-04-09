//
//  ThumbStoryView.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 09.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "ThumbStoryView.h"
#import "AsyncImageView.h"
#import "Story.h"

@implementation ThumbStoryView
@synthesize story;

- (id)initWithFrame:(CGRect)frame story:(Story *)_story {
    self = [super initWithFrame:frame];
    if (self) {
        [self setStory:_story];
        AsyncImageView *asyncImageView = [[AsyncImageView alloc] initWithFrame:frame];
        
        NSURL *url = [[self story] extractPhotoUrlType:@"thumb_url" atIndex:0];
        [asyncImageView loadImageFromURL:url];
        
        [self addSubview:asyncImageView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

