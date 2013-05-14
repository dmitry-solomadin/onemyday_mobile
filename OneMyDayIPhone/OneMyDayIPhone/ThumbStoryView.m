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
        photoView = [[AsyncImageView alloc] initWithFrame: CGRectMake(5, 5, 290, 290)];
        photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        photoView.contentMode = UIViewContentModeScaleAspectFit;
        photoView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"furley_bg"]];
        
        StoryShadowWrapView *wrapView = [[StoryShadowWrapView alloc] initWithFrame: CGRectMake(0, 45, 300, 300)
                                                                      andAsyncView:photoView];
        
        NSURL *url = [[self story] extractPhotoUrlType:@"iphone2x_thumb_url" atIndex:0];
        [photoView setImageURL:url];
        [self addSubview:wrapView];
        
        // Photo hidden button
        UIButton *imageBtn = [[UIButton alloc] initWithFrame: CGRectMake(0, 45, 300, 300)];
        imageBtn.tag = story.storyId;
        [imageBtn addTarget:self action:@selector(imageTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:imageBtn];
        [self bringSubviewToFront:imageBtn];
        
        // Author avatar
        User *author = [[UserStore get] findById:[story authorId]];
        AsyncImageView *avatarView = [[AsyncImageView alloc] initWithFrame: CGRectMake(0, 0, 35, 35)];
        avatarView.clipsToBounds = YES;
        avatarView.layer.cornerRadius = 35.0 / 2;
        avatarView.layer.borderColor = [[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor];
        avatarView.layer.borderWidth = 1;
        avatarView.layer.backgroundColor = [[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1] CGColor];
        avatarView.showActivityIndicator = NO;

        NSURL *avatarUrl = [author extractAvatarUrlType:@"small_url"];
        if ([self isAvatarEmpty:[avatarUrl absoluteString]]) {
            [avatarView setImage:[UIImage imageNamed:@"no-avatar"]];
        } else {
            [avatarView setImageURL:avatarUrl];
        }
        
        [self addSubview:avatarView];
    }
    return self;
}

- (void)imageTap:(UIButton *)sender
{
    NSNumber *storyId = [NSNumber numberWithInteger:sender.tag];
    [[self controller] performSelector:@selector(storyTap:) withObject:storyId];
}

- (BOOL)isAvatarEmpty:(NSString *)avatarURL
{
    if ([avatarURL rangeOfString:@"no-avatar" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    return NO;
}

@end

