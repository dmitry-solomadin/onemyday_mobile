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
#import "User.h"
#import "UserStore.h"
#import "StoryShadowWrapView.h"
#import <QuartzCore/QuartzCore.h>

@interface ThumbStoryView ()
{
    AsyncImageView *photoView;
}

@end

@implementation ThumbStoryView
@synthesize story, controller;

- (id)initWithFrame:(CGRect)frame story:(Story *)_story {
    self = [super initWithFrame:frame];
    if (self) {
        [self setStory:_story];
        
        // Photo
        photoView = [[AsyncImageView alloc] initWithFrame: CGRectMake(0, 0, 300, 300)];
        photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        photoView.contentMode = UIViewContentModeScaleAspectFit;
        photoView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"furley_bg"]];
        
        StoryShadowWrapView *wrapView = [[StoryShadowWrapView alloc] initWithFrame: CGRectMake(0, 45, 300, 300)
                                                                      andAsyncView:photoView];
        [wrapView addSubview:photoView];
        
        NSURL *url = [[self story] extractPhotoUrlType:@"thumb_url" atIndex:0];
        [photoView setImageURL:url];
        [self addSubview:wrapView];
        
        // Photo hidden button
        UIButton *imageBtn = [[UIButton alloc] initWithFrame:
                              CGRectMake(0, 45, 300, 300)];
        imageBtn.tag = story.storyId;
        [imageBtn addTarget:self action:@selector(imageTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:imageBtn];
        [self bringSubviewToFront:imageBtn];
        
        // Author avatar
        User *author = [[UserStore get] findById:[story authorId]];
        AsyncImageView *avatarView = [[AsyncImageView alloc] initWithFrame: CGRectMake(0, 0, 35, 35)];
        avatarView.clipsToBounds = YES;
        avatarView.layer.cornerRadius = 35.0 / 2;

        NSURL *avatarUrl = [author extractAvatarUrlType:@"small_url"];
        [avatarView setImageURL:avatarUrl];
        [self addSubview:avatarView];
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

