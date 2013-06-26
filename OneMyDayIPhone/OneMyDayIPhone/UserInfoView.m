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

@implementation UserInfoView

- (id)initWithFrame:(CGRect)frame andUser: (User *)user
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UITextView *containerView = [[UITextView alloc] init];
        
        containerView.clipsToBounds = YES;
        containerView.layer.cornerRadius = 10.0;
        containerView.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
        containerView.layer.borderWidth = 2;
        [containerView setEditable:NO];
        [containerView setFont:[UIFont systemFontOfSize:15]];
        [containerView setBackgroundColor:[UIColor whiteColor]];
        [containerView setContentInset:UIEdgeInsetsMake(0, -8, 0, 0)];
        containerView.frame = frame;
        
        AsyncImageView *avatarView = [[AsyncImageView alloc] initWithFrame: CGRectMake(13, 5, 50, 50)];
        avatarView.clipsToBounds = YES;
        avatarView.layer.cornerRadius = 10;
        avatarView.layer.borderColor = [[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor];
        avatarView.layer.borderWidth = 1;
        avatarView.layer.backgroundColor = [[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1] CGColor];
        avatarView.showActivityIndicator = NO;        
        NSURL *avatarUrl = [user extractAvatarUrlType:@"small_url"];
        if ([UserStore isAvatarEmpty:[avatarUrl absoluteString]]) {
            [avatarView setImage:[UIImage imageNamed:@"no-avatar"]];
        } else {
            [avatarView setImageURL:avatarUrl];
        }        
        [containerView addSubview:avatarView];
        
        // Author name
        UILabel *authorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, 0, 35)];
        [authorNameLabel setText:[user name]];
        [authorNameLabel setBackgroundColor:[UIColor clearColor]];
        [authorNameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [authorNameLabel setTextColor:[UIColor colorWithRed:63/255.f green:114/255.f blue:155/255.f alpha:1]];
        [authorNameLabel sizeToFit];
        [containerView addSubview:authorNameLabel];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        if(appDelegate.currentUserId == [user userId]){
            // Edit profile button
            UITextView *editButton = [[UITextView alloc] initWithFrame:CGRectMake(70, 28, 120, 25)];
            [editButton setText:@"Edit profile"];
            [editButton setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1]];
            [editButton setFont:[UIFont fontWithName:@"Helvetica" size:14]];
            [editButton setTextColor:[UIColor blackColor]];
            [editButton setContentInset:UIEdgeInsetsMake(-5, 0, 0, 0)];
            [editButton setEditable:NO];
            [editButton setTextAlignment:NSTextAlignmentCenter];
            editButton.layer.cornerRadius = 5.0;
            editButton.layer.borderColor = [[UIColor blackColor] CGColor];
            editButton.layer.borderWidth = 2;
            [containerView addSubview:editButton];
        }
        
        // stries count
        UITextView *storiesCount = [[UITextView alloc] initWithFrame:CGRectMake(0, 60, 100, 60)];
        [storiesCount setBackgroundColor:[UIColor clearColor]];
        [storiesCount setContentInset:UIEdgeInsetsMake(-5, 0, 0, 0)];
        [storiesCount setEditable:NO];
        [storiesCount setTextAlignment:NSTextAlignmentCenter];
        storiesCount.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
        storiesCount.layer.borderWidth = 2;
        [containerView addSubview:storiesCount];
        
        //storiesNumber
        UILabel *storiesNumber = [[UILabel alloc] initWithFrame:CGRectMake(5, 18, 95, 15)];
        [storiesNumber setText: [NSString stringWithFormat:@"%d", [user storiesSize]]];
        [storiesNumber setBackgroundColor:[UIColor clearColor]];
        [storiesNumber setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        [storiesNumber setTextColor:[UIColor redColor]];
        [storiesNumber setTextAlignment:NSTextAlignmentCenter];
        [storiesCount addSubview:storiesNumber];
        
        //storiesText
        UILabel *storiesText = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 100, 40)];
        [storiesText setText:@"Stories"];
        [storiesText setBackgroundColor:[UIColor clearColor]];
        [storiesText setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [storiesText setTextColor:[UIColor blackColor]];
        [storiesText setTextAlignment:NSTextAlignmentCenter];
        [storiesCount addSubview:storiesText];
        
        
        // followers count
        UITextView *followersCount = [[UITextView alloc] initWithFrame:CGRectMake(98, 60, 120, 60)];
        [followersCount setBackgroundColor:[UIColor clearColor]];
        [followersCount setContentInset:UIEdgeInsetsMake(-5, 0, 0, 0)];
        [followersCount setEditable:NO];
        [followersCount setTextAlignment:NSTextAlignmentCenter];
        followersCount.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
        followersCount.layer.borderWidth = 2;
        [containerView addSubview:followersCount];
        
        //folowersNumber
        UILabel *folowersNumber = [[UILabel alloc] initWithFrame:CGRectMake(5, 18, 115, 15)];
        [folowersNumber setText: [NSString stringWithFormat:@"%d", [user followersSize]]];
        [folowersNumber setBackgroundColor:[UIColor clearColor]];
        [folowersNumber setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        [folowersNumber setTextColor:[UIColor redColor]];
        [folowersNumber setTextAlignment:NSTextAlignmentCenter];
        [followersCount addSubview:folowersNumber];
        
        //folowersText
        UILabel *followersText = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 120, 40)];
        [followersText setText:@"Followers"];
        [followersText setBackgroundColor:[UIColor clearColor]];
        [followersText setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [followersText setTextColor:[UIColor blackColor]];
        [followersText setTextAlignment:NSTextAlignmentCenter];
        [followersCount addSubview:followersText];
        
        
        //follow count
        UITextView *followCount = [[UITextView alloc] initWithFrame:CGRectMake(216, 60, 100, 60)];
        [followCount setBackgroundColor:[UIColor clearColor]];   
        [followCount setContentInset:UIEdgeInsetsMake(-5, 0, 0, 0)];
        [followCount setEditable:NO];
        [followCount setTextAlignment:NSTextAlignmentCenter];     
        followCount.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
        followCount.layer.borderWidth = 2;
        [containerView addSubview:followCount];
        
        //followNumber
        UILabel *followNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 100, 15)];
        [followNumber setText: [NSString stringWithFormat:@"%d", [user followedBySize]]];
        [followNumber setBackgroundColor:[UIColor clearColor]];
        [followNumber setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        [followNumber setTextColor:[UIColor redColor]];      
        [followNumber setTextAlignment:NSTextAlignmentCenter];
        [followCount addSubview:followNumber];
        
        //followText
        UILabel *followText = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 100, 40)];
        [followText setText:@"Follow"];
        [followText setBackgroundColor:[UIColor clearColor]];
        [followText setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [followText setTextColor:[UIColor blackColor]];    
        [followText setTextAlignment:NSTextAlignmentCenter];
        [followCount addSubview:followText];
        
        [self addSubview:containerView];         
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
