//
//  StoryCommentView.m
//  Onemyday
//
//  Created by Admin on 6/2/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "StoryCommentView.h"
#import "User.h"
#import "AsyncImageView.h"
#import "UserStore.h"
#import "TTTTimeIntervalFormatter.h"
#import <QuartzCore/QuartzCore.h>

@implementation StoryCommentView

@synthesize controller;

- (id)initWithFrame:(CGRect)frame andComment:(Comment *)comment andIsFirst:(bool)first andIsLast:(bool)last
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *commentContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 45)];
        [commentContainerView setBackgroundColor:[UIColor whiteColor]];
        
        // Author avatar
        User *author = [[UserStore get] findById:[comment authorId]];
        AsyncImageView *avatarView = [[AsyncImageView alloc] initWithFrame: CGRectMake(5, 5, 35, 35)];
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
        
        [commentContainerView addSubview:avatarView];
        
        self.tag = [comment commentId];
        
        // Author name
        UILabel *authorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 13, 0, 35)];
        [authorNameLabel setText:[author name]];
        [authorNameLabel setBackgroundColor:[UIColor clearColor]];
        [authorNameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [authorNameLabel setTextColor:[UIColor colorWithRed:63/255.f green:114/255.f blue:155/255.f alpha:1]];
        [authorNameLabel sizeToFit];
        [commentContainerView addSubview:authorNameLabel];
        
        // Time created
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        NSString *time = [timeIntervalFormatter stringForTimeInterval:[[comment createdAt] timeIntervalSinceNow]];
        
        UILabel *timeAgoLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 15, 0, 35)];
        [timeAgoLabel setText:time];
        [timeAgoLabel setBackgroundColor:[UIColor clearColor]];
        [timeAgoLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [timeAgoLabel setTextColor:[UIColor grayColor]];
        [timeAgoLabel sizeToFit];
        //NSLog(@"%f", timeAgoLabel.frame.size.width);
        timeAgoLabel.frame = CGRectMake(295 - timeAgoLabel.frame.size.width, 15,
                                        timeAgoLabel.frame.size.width, timeAgoLabel.frame.size.height);
        [commentContainerView addSubview:timeAgoLabel];
        
        UITextView *textView = [[UITextView alloc] init];
        textView.text = [comment text];
        [textView setEditable:NO];
        [textView setFont:[UIFont systemFontOfSize:12]];
        [textView sizeToFit];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setContentInset:UIEdgeInsetsMake(0, -8, 0, 0)];
        [commentContainerView addSubview:textView];
        
        textView.frame = CGRectMake(10, 45, 290, textView.contentSize.height);
        [textView sizeToFit];
        
        [self addSubview:commentContainerView];
        float additionalHeight = 45.0;
        commentContainerView.frame = CGRectMake(0, 0, 300, textView.contentSize.height + additionalHeight);
        
        if (first || last) {
            // Add top and bottom rounded corners
            // We do this here because we know actual comment height here
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            UIBezierPath *path;
            if (first) {
                path = [UIBezierPath bezierPathWithRoundedRect: commentContainerView.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){10.0, 10.}];
            } else if (last) {
                path = [UIBezierPath bezierPathWithRoundedRect: commentContainerView.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){10.0, 10.}];
            }
            maskLayer.path = path.CGPath;
            
            commentContainerView.layer.mask = maskLayer;
            
            // Make a transparent, stroked layer which will dispay the stroke.
            CAShapeLayer *strokeLayer = [CAShapeLayer layer];
            strokeLayer.path = path.CGPath;
            strokeLayer.fillColor = [UIColor clearColor].CGColor;
            strokeLayer.strokeColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
            strokeLayer.lineWidth = 2;
            
            // Transparent view that will contain the stroke layer
            UIView *strokeView = [[UIView alloc] initWithFrame:commentContainerView.bounds];
            strokeView.userInteractionEnabled = NO; // in case your container view contains controls
            [strokeView.layer addSublayer:strokeLayer];
            
            [commentContainerView addSubview:strokeView];
        } else {
            commentContainerView.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
            commentContainerView.layer.borderWidth = 1;
        }
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 300, textView.contentSize.height + additionalHeight);
    }
    return self;
}

@end
