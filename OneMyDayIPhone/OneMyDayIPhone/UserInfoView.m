//
//  UserInfoView.m
//  Onemyday
//
//  Created by Admin on 6/17/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "UserInfoView.h"
#import <QuartzCore/QuartzCore.h>
#import "AsyncImageView.h"
#import "UserStore.h"
#import "AppDelegate.h"
#import "YIInnerShadowView.h"

@implementation UserInfoView

@synthesize controller;

- (id)initWithFrame:(CGRect)frame andUser:(User *)user
{
    self = [super initWithFrame:frame];
    if (self) {        
        UIView *containerView = [[UIView alloc] initWithFrame:frame];        
        containerView.clipsToBounds = NO;
        containerView.layer.cornerRadius = 5.0;
        containerView.layer.shadowColor = [[UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:1] CGColor];
        containerView.layer.shadowOffset = CGSizeMake(0, 1);
        containerView.layer.shadowOpacity = 1;
        containerView.layer.shadowRadius = 1.75;
        containerView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:containerView.bounds cornerRadius:5.0].CGPath;
        [containerView setBackgroundColor:[UIColor whiteColor]];
        
        UIView *containerInnerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        containerInnerView.clipsToBounds = YES;
        containerInnerView.layer.cornerRadius = 5.0;
        [containerInnerView setBackgroundColor:[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1]];
        [containerView addSubview:containerInnerView];
        
        // Author avatar with the fancy shadow. 
        YIInnerShadowView *avatarShadowView = [[YIInnerShadowView alloc] initWithFrame: CGRectMake(5, 5, 50, 50)];
        avatarShadowView.shadowRadius = 2;
        avatarShadowView.shadowColor = [UIColor blackColor];
        avatarShadowView.shadowMask = YIInnerShadowMaskAll;
        avatarShadowView.cornerRadius = 5;
        AsyncImageView *avatarView = [[AsyncImageView alloc] initWithFrame: CGRectMake(5, 5, 50, 50)];
        avatarView.layer.cornerRadius = 5;
        avatarView.clipsToBounds = YES;
        [avatarView setBackgroundColor:[UIColor clearColor]];
        avatarView.showActivityIndicator = NO;
        NSURL *avatarUrl = [user extractAvatarUrlType:@"small_url"];
        if ([UserStore isAvatarEmpty:[avatarUrl absoluteString]]) {
            [avatarView setImage:[UIImage imageNamed:@"no-avatar"]];
        } else {
            [avatarView setImageURL:avatarUrl];
        }        
        
        [containerInnerView addSubview:avatarView];
        [containerInnerView addSubview:avatarShadowView];
        [containerInnerView bringSubviewToFront:avatarShadowView];
        
        // Author name
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 0, 30)];
        [usernameLabel setText:[user name]];
        [usernameLabel setBackgroundColor:[UIColor clearColor]];
        [usernameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [usernameLabel setTextColor:[UIColor colorWithRed:63/255.f green:114/255.f blue:155/255.f alpha:1]];
        [usernameLabel sizeToFit];
        [containerInnerView addSubview:usernameLabel];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        if (appDelegate.currentUserId == [user userId]) {
            // Edit profile button
            UIButton *editBtn = [[UIButton alloc] initWithFrame: CGRectMake(60, 25, 120, 30)];
            editBtn.tag = [user userId];
            [editBtn setImage:[UIImage imageNamed:@"edit_profile_button"] forState:UIControlStateNormal];
            [editBtn addTarget:self action:@selector(editBtnTap:) forControlEvents:UIControlEventTouchUpInside];
            [containerInnerView addSubview:editBtn];
            [containerInnerView bringSubviewToFront:editBtn];
        }
        
        // stries count
        UIView *storiesCountContainer = [[UIView alloc] initWithFrame:CGRectMake(-1, 60, 101, 61)];
        [storiesCountContainer setBackgroundColor:[UIColor clearColor]];
        storiesCountContainer.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
        storiesCountContainer.layer.borderWidth = 1;
        [containerInnerView addSubview:storiesCountContainer];
        
        UIView *storiesWhiteBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 1, 101, 1)];
        [storiesWhiteBorder setBackgroundColor:[UIColor whiteColor]];
        [storiesCountContainer addSubview:storiesWhiteBorder];
        
        //storiesNumber
        UILabel *storiesNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 101, 15)];
        [storiesNumber setText: [NSString stringWithFormat:@"%d", [user storiesSize]]];
        [storiesNumber setBackgroundColor:[UIColor clearColor]];
        [storiesNumber setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [storiesNumber setTextColor:[UIColor redColor]];
        [storiesNumber setTextAlignment:NSTextAlignmentCenter];
        [storiesNumber setShadowColor:[UIColor whiteColor]];
        [storiesNumber setShadowOffset:CGSizeMake(0, 1)];
        [storiesCountContainer addSubview:storiesNumber];
        
        //storiesText
        UILabel *storiesText = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 101, 25)];
        [storiesText setText:NSLocalizedString(@"stories", nil)];
        [storiesText setBackgroundColor:[UIColor clearColor]];
        [storiesText setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [storiesText setTextColor:[UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:1]];
        [storiesText setTextAlignment:NSTextAlignmentCenter];
        [storiesCountContainer addSubview:storiesText];
        
        // followers count
        UIView *followersCountContainer = [[UIView alloc] initWithFrame:CGRectMake(99, 60, 101, 60)];
        [followersCountContainer setBackgroundColor:[UIColor clearColor]];
        followersCountContainer.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
        followersCountContainer.layer.borderWidth = 1;
        [containerInnerView addSubview:followersCountContainer];
        
        UIView *followersWhiteBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 1, 101, 1)];
        [followersWhiteBorder setBackgroundColor:[UIColor whiteColor]];
        [followersCountContainer addSubview:followersWhiteBorder];
        
        //folowersNumber
        UILabel *folowersNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 101, 15)];
        [folowersNumber setText: [NSString stringWithFormat:@"%d", [user followersSize]]];
        [folowersNumber setBackgroundColor:[UIColor clearColor]];
        [folowersNumber setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [folowersNumber setTextColor:[UIColor redColor]];
        [folowersNumber setTextAlignment:NSTextAlignmentCenter];
        [folowersNumber setShadowColor:[UIColor whiteColor]];
        [folowersNumber setShadowOffset:CGSizeMake(0, 1)];
        [followersCountContainer addSubview:folowersNumber];
        
        //folowersText
        UILabel *followersText = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 101, 25)];
        [followersText setText:NSLocalizedString(@"followers", nil)];
        [followersText setBackgroundColor:[UIColor clearColor]];
        [followersText setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [followersText setTextColor:[UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:1]];
        [followersText setTextAlignment:NSTextAlignmentCenter];
        [followersCountContainer addSubview:followersText];
        
        //follow count
        UIView *followCountContainer = [[UIView alloc] initWithFrame:CGRectMake(199, 60, 102, 60)];
        [followCountContainer setBackgroundColor:[UIColor clearColor]];   
        followCountContainer.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
        followCountContainer.layer.borderWidth = 1;
        [containerInnerView addSubview:followCountContainer];
        
        UIView *followWhiteBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 1, 101, 1)];
        [followWhiteBorder setBackgroundColor:[UIColor whiteColor]];
        [followCountContainer addSubview:followWhiteBorder];
        
        //followNumber
        UILabel *followNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 100, 15)];
        [followNumber setText: [NSString stringWithFormat:@"%d", [user followedBySize]]];
        [followNumber setBackgroundColor:[UIColor clearColor]];
        [followNumber setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [followNumber setTextColor:[UIColor redColor]];      
        [followNumber setTextAlignment:NSTextAlignmentCenter];
        [followNumber setShadowColor:[UIColor whiteColor]];
        [followNumber setShadowOffset:CGSizeMake(0, 1)];
        [followCountContainer addSubview:followNumber];
        
        //followText
        UILabel *followText = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 100, 25)];
        [followText setText:NSLocalizedString(@"follow", nil)];
        [followText setBackgroundColor:[UIColor clearColor]];
        [followText setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [followText setTextColor:[UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:1]];
        [followText setTextAlignment:NSTextAlignmentCenter];
        [followCountContainer addSubview:followText];
        
        [self addSubview:containerView];
    }
    return self;
}

- (void)editBtnTap:(UIButton *)sender
{
    //NSLog(@"sender %d", sender.tag);
    NSNumber *storyId = [NSNumber numberWithInteger:sender.tag];
    [[self controller] performSelector:@selector(editBtnTap:) withObject:storyId];
}

@end
