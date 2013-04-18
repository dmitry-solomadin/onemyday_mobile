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

@implementation ThumbStoryView
@synthesize story, controller;

- (id)initWithFrame:(CGRect)frame story:(Story *)_story {
    self = [super initWithFrame:frame];
    if (self) {
        [self setStory:_story];
        
        // Photo
        AsyncImageView *photoView = [[AsyncImageView alloc] initWithFrame:
                                          CGRectMake(0, 45, 300, 300)];
        photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        photoView.contentMode = UIViewContentModeScaleAspectFit;
        photoView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"furley_bg"]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDidLoad:)
                                                     name:@"AsyncImageLoadDidFinish" object:nil];
        NSURL *url = [[self story] extractPhotoUrlType:@"thumb_url" atIndex:0];
        [photoView setImageURL:url];

        //photoView.loaded = ^void(UIImageView *imageView) {
        //    UIColor *color = [[UIColor alloc] initWithRed:0.85 green:0.85 blue:0.85 alpha:1];
        //    [imageView setBackgroundColor: color];
        //};
        [self addSubview:photoView];
        
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
        NSURL *avatarUrl = [author extractAvatarUrlType:@"small_url"];
        [avatarView setImageURL:avatarUrl];
        [self addSubview:avatarView];
    }
    return self;
}

- (void)imageDidLoad:(NSNotification *)notification
{
    NSLog(@"image did load!!!");
//    img.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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

