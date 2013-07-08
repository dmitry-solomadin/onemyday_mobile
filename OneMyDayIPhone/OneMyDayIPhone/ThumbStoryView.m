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
#import "TTTTimeIntervalFormatter.h"
#import "ThumbStoryDetailsView.h"
#import <QuartzCore/QuartzCore.h>
#import "ProfileViewController.h"

@interface ThumbStoryView ()
{
    AsyncImageView *photoView;
}

@end

@implementation ThumbStoryView
@synthesize story, controller;

__weak UINavigationController *navController;

- (id)initWithFrame:(CGRect)frame story:(Story *)_story navController:(UINavigationController *)_navController {
    self = [super initWithFrame:frame];
    if (self) {
        [self setStory:_story];
        navController = _navController;
        
        // Photo
        photoView = [[AsyncImageView alloc] initWithFrame: CGRectMake(5, 5, 290, 290)];
        photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        photoView.contentMode = UIViewContentModeScaleAspectFit;
        photoView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"furley_bg"]];
        
        StoryShadowWrapView *wrapView = [[StoryShadowWrapView alloc] initWithFrame: CGRectMake(0, 40, 300, 300)
                                                                      andAsyncView:photoView];
        
        NSURL *url = [[self story] extractPhotoUrlType:@"iphone2x_thumb_url" atIndex:0];
        [photoView setImageURL:url];
        [self addSubview:wrapView];
        
        // Photo hidden button
        UIButton *imageBtn = [[UIButton alloc] initWithFrame: CGRectMake(0, 40, 300, 300)];
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
        if ([UserStore isAvatarEmpty:[avatarUrl absoluteString]]) {
            [avatarView setImage:[UIImage imageNamed:@"no-avatar"]];
        } else {
            [avatarView setImageURL:avatarUrl];
        }
        
        [self addSubview:avatarView];
        
        // Author name
        UILabel *authorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 8, 0, 35)];
        [authorNameLabel setText:[author name]];
        [authorNameLabel setBackgroundColor:[UIColor clearColor]];
        [authorNameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [authorNameLabel setTextColor:[UIColor colorWithRed:63/255.f green:114/255.f blue:155/255.f alpha:1]];
        [authorNameLabel sizeToFit];
        [self addSubview:authorNameLabel];
        
        // Author button
        UIButton *authorBtn = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 200, 40)];
        authorBtn.tag = [story authorId];
        [authorBtn addTarget:self action:@selector(authorTap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:authorBtn];
        [self bringSubviewToFront:authorBtn];
        
        // Time created
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        NSString *time = [timeIntervalFormatter stringForTimeInterval:[[story createdAt] timeIntervalSinceNow]];
        
        UILabel *timeAgoLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 10, 0, 35)];
        [timeAgoLabel setText:time];
        [timeAgoLabel setBackgroundColor:[UIColor clearColor]];
        [timeAgoLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [timeAgoLabel setTextColor:[UIColor grayColor]];
        [timeAgoLabel sizeToFit];
        //NSLog(@"%f", timeAgoLabel.frame.size.width);
        timeAgoLabel.frame = CGRectMake(300 - timeAgoLabel.frame.size.width, 10,
                                        timeAgoLabel.frame.size.width, timeAgoLabel.frame.size.height);
        [self addSubview:timeAgoLabel];
        
        // Story details rect
        ThumbStoryDetailsView *storyDetails = [[ThumbStoryDetailsView alloc] initWithFrame:CGRectMake(6, 285, 288, 50)
                                                                                     story:story];
        [self addSubview:storyDetails];
    }
    return self;
}

- (void)imageTap:(UIButton *)sender
{
    NSNumber *storyId = [NSNumber numberWithInteger:sender.tag];
    [[self controller] performSelector:@selector(storyTap:) withObject:storyId];
}

- (void)authorTap
{
    [ProfileViewController showWithUser:[story authorId] andNavController:navController];
}

@end

