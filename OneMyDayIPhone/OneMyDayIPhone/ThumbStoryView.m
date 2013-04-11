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
@synthesize story, controller;

- (id)initWithFrame:(CGRect)frame story:(Story *)_story {
    self = [super initWithFrame:frame];
    if (self) {
        [self setStory:_story];
        AsyncImageView *asyncImageView = [[AsyncImageView alloc] initWithFrame:
                                          CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        NSURL *url = [[self story] extractPhotoUrlType:@"thumb_url" atIndex:0];
        [asyncImageView loadImageFromURL:url];
        asyncImageView.loaded = ^void(UIImageView *imageView) {
            UIColor *color = [[UIColor alloc] initWithRed:0.85 green:0.85 blue:0.85 alpha:1];
            [imageView setBackgroundColor: color];
        };
        
        UIButton *imageBtn = [[UIButton alloc] initWithFrame:
                              CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageBtn.tag = story.storyId;
        [imageBtn addTarget:self action:@selector(imageTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:imageBtn];
        
        [self addSubview:asyncImageView];
        [self bringSubviewToFront:imageBtn];
    }
    return self;
}

- (void)imageTap:(UIButton *)sender
{
    NSNumber *storyId = [NSNumber numberWithInteger:sender.tag];
    [[self controller] performSelector:@selector(storyTap:) withObject:storyId];
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

