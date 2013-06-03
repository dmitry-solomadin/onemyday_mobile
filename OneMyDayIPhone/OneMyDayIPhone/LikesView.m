//
//  LikesView.m
//  Onemyday
//
//  Created by Admin on 6/2/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "LikesView.h"

@implementation LikesView

@synthesize story, controller;

- (id)initWithFrame:(CGRect)frame andStory:(Story *)_story
{
    self = [super initWithFrame:frame];
    if (self) {
        UITextView *likeView = [[UITextView alloc] init];
        
        likeView.clipsToBounds = YES;
        likeView.layer.cornerRadius = 10.0;
        likeView.layer.borderColor = [[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1] CGColor];
        likeView.layer.borderWidth = 2;
        [likeView setEditable:NO];
        [likeView setFont:[UIFont systemFontOfSize:15]];
        [likeView setBackgroundColor:[UIColor whiteColor]];
        [likeView setContentInset:UIEdgeInsetsMake(0, -8, 0, 0)];
        [scrollView addSubview:likeView];
        likeView.frame = CGRectMake(10, currentStoryHeight, 300, 50);
        
        
        
        likeButtonView = [[UITextView alloc] init];
        likeButtonView.clipsToBounds = YES;
        likeButtonView.layer.cornerRadius = 14.0;
        likeButtonView.layer.borderColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1] CGColor];
        likeButtonView.layer.borderWidth = 2;
        NSLog(@"[story isLikedByUser] %d", [story isLikedByUser]);
        if(![story isLikedByUser]){
            likeButtonView.text = @"Like";
            [likeButtonView setContentInset:UIEdgeInsetsMake(-5, 10, 0, 0)];
        }
        else {
            likeButtonView.text = @"Liked";
            [likeButtonView setContentInset:UIEdgeInsetsMake(-5, 6, 0, 0)];
        }
        [likeButtonView setEditable:NO];
        [likeButtonView setFont:[UIFont systemFontOfSize:18]];
        [likeButtonView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]];
        [likeView addSubview:likeButtonView];
        likeButtonView.frame = CGRectMake(15, 12, 70, 27);
        
        UITapGestureRecognizer *likeButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeButtonTapped:)];
        [likeButtonView addGestureRecognizer:likeButtonTap];
        
        numberOfPeopleView = [[UITextView alloc] init];
        numberOfPeopleView.text = [NSString stringWithFormat:@"%d",[story likesCount]];
        [numberOfPeopleView setFont:[UIFont systemFontOfSize:17]];
        [likeView addSubview:numberOfPeopleView];
        numberOfPeopleView.frame = CGRectMake(90, 5, 20, 27);
        
        UITextView *numberOfPeopleTextView = [[UITextView alloc] init];
        numberOfPeopleTextView.text = @"people likes this story";
        [numberOfPeopleTextView setFont:[UIFont systemFontOfSize:17]];
        [likeView addSubview:numberOfPeopleTextView];
        numberOfPeopleTextView.frame = CGRectMake(120, 5, 200, 27);
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
