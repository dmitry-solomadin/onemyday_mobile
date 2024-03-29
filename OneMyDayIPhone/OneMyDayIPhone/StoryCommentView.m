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
#import "Request.h"
#import "AppDelegate.h"
#import "ProfileViewController.h"

@implementation StoryCommentView

@synthesize controller;

UIView *strokeView;
__weak Comment *comment;

- (id)initWithFrame:(CGRect)frame andComment:(Comment *)_comment andIsFirst:(bool)first andIsLast:(bool)last
 andShowDeleteLabel:(BOOL)showDeleteLabel andController:(UIViewController *)_controller
{
    self = [super initWithFrame:frame];
    if (self) {
        comment = _comment;
        controller = _controller;
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
        
        UIButton *authorBtn = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 200, 40)];
        authorBtn.tag = [comment authorId];
        [authorBtn addTarget:self action:@selector(authorTap) forControlEvents:UIControlEventTouchUpInside];
        [commentContainerView addSubview:authorBtn];
        [commentContainerView bringSubviewToFront:authorBtn];
        
        // Time created
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        NSString *time = [timeIntervalFormatter stringForTimeInterval:[[comment createdAt] timeIntervalSinceNow]];
        
        UILabel *timeAgoLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 15, 0, 35)];
        [timeAgoLabel setText:time];
        [timeAgoLabel setBackgroundColor:[UIColor clearColor]];
        [timeAgoLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [timeAgoLabel setTextColor:[UIColor grayColor]];
        [timeAgoLabel sizeToFit];
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
            if (first && last){
                path = [UIBezierPath bezierPathWithRoundedRect: commentContainerView.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                   cornerRadii: (CGSize){10.0, 10.}];
            } else if (first) {
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
            strokeView = [[UIView alloc] initWithFrame:commentContainerView.bounds];
            strokeView.userInteractionEnabled = NO; // in case your container view contains controls
            [strokeView.layer addSublayer:strokeLayer];
            
            [commentContainerView addSubview:strokeView];
        } else {
            commentContainerView.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
            commentContainerView.layer.borderWidth = 1;
        }
        
        // Delete label
        if (showDeleteLabel) {
            UILabel *deleteView = [[UILabel alloc] initWithFrame: CGRectMake(270, 3, 30, 15)];
            [deleteView setBackgroundColor:[UIColor clearColor]];
            [deleteView setText:@"X "];
            [deleteView setFont:[UIFont systemFontOfSize:12]];
            [deleteView setUserInteractionEnabled:YES];
            deleteView.tag = [comment commentId];
            UITapGestureRecognizer *deleteViewTap = [[UITapGestureRecognizer alloc] initWithTarget:controller
                                                                                            action:@selector(deleteViewTapped:)];
            [deleteView addGestureRecognizer:deleteViewTap];
            [deleteView setTextAlignment:NSTextAlignmentRight];
            [commentContainerView addSubview:deleteView];
        }
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 300, textView.contentSize.height + additionalHeight);
    }
    return self;
}

- (void)removeRoundedCorners
{
    UIView *commentContainer = [[self subviews] objectAtIndex:0];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *path;
    path = [UIBezierPath bezierPathWithRoundedRect: commentContainer.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight |UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){0, 0}];
    maskLayer.path = path.CGPath;
    
    commentContainer.layer.mask = maskLayer;
    commentContainer.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
    commentContainer.layer.borderWidth = 1;
    
    if (strokeView) {
        [strokeView removeFromSuperview];
    }
}

- (void)setTopRoundedCorners
{
    UIView *commentContainer = [[self subviews] objectAtIndex:0];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect: commentContainer.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){10.0, 10.}];
    [self addRoundedCornersWithPath:path];
}

- (void)setAllRoundedCorners
{
    UIView *commentContainer = [[self subviews] objectAtIndex:0];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect: commentContainer.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){10.0, 10.}];
    [self addRoundedCornersWithPath:path];
}

- (void)setBottomRoundedCorners
{
    UIView *commentContainer = [[self subviews] objectAtIndex:0];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect: commentContainer.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){10.0, 10.}];
    [self addRoundedCornersWithPath:path];
}

- (void)addRoundedCornersWithPath:(UIBezierPath *)path
{
    UIView *commentContainer = [[self subviews] objectAtIndex:0];
    
    if (strokeView) {
        [strokeView removeFromSuperview];
    }
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    
    commentContainer.layer.mask = maskLayer;
    
    // Make a transparent, stroked layer which will dispay the stroke.
    CAShapeLayer *strokeLayer = [CAShapeLayer layer];
    strokeLayer.path = path.CGPath;
    strokeLayer.fillColor = [UIColor clearColor].CGColor;
    strokeLayer.strokeColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
    strokeLayer.lineWidth = 2;
    
    // Transparent view that will contain the stroke layer
    strokeView = [[UIView alloc] initWithFrame:commentContainer.bounds];
    strokeView.userInteractionEnabled = NO; // in case your container view contains controls
    [strokeView.layer addSublayer:strokeLayer];
    
    [commentContainer addSubview:strokeView];
}

- (void)authorTap
{
    [ProfileViewController showWithUser:[comment authorId] andNavController:[controller navigationController]];
}

@end
