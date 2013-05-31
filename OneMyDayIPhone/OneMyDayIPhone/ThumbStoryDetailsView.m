//
//  ThumbStoryDetailsView.m
//  Onemyday
//
//  Created by dmitry.solomadin on 17.05.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "ThumbStoryDetailsView.h"
#import "Story.h"
#import <QuartzCore/QuartzCore.h>

@implementation ThumbStoryDetailsView

@synthesize story;

- (id)initWithFrame:(CGRect)frame story:(Story *)_story {
    self = [super initWithFrame:frame];
    if (self) {
        [self setStory:_story];
        
        self.backgroundColor = [UIColor clearColor];
        
        UILabel *storyTitleLabel = [self createLabelWithFrame:CGRectMake(5, 5, 0, 35)
                                                      andText:[story title]];
        [self addSubview:storyTitleLabel];
        
        // Add views count
        UIImageView *eyeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eye"]];
        eyeImage.frame = CGRectMake(5, 27, eyeImage.frame.size.width, eyeImage.frame.size.height);
        [self addSubview:eyeImage];

        UILabel *viewsCount = [self createLabelWithFrame:CGRectMake(eyeImage.frame.origin.x + eyeImage.frame.size.width + 4, 25, 0, 35)
                                                      andText:[NSString stringWithFormat:@"%d",[story viewsCount]]];
        [self addSubview:viewsCount];
        
        // Add likes count
        UIImageView *heartImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart_small"]];
        heartImage.frame = CGRectMake(viewsCount.frame.origin.x + viewsCount.frame.size.width + 8, 27,
                                      heartImage.frame.size.width, heartImage.frame.size.height);
        [self addSubview:heartImage];
        
        UILabel *likesCount = [self createLabelWithFrame:CGRectMake(heartImage.frame.origin.x + heartImage.frame.size.width + 4, 25, 0, 35)
                                                 andText:[NSString stringWithFormat:@"%d",[story likesCount]]];
        [self addSubview:likesCount];
        
        // Add comments count
        UIImageView *commentImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment"]];
        commentImage.frame = CGRectMake(likesCount.frame.origin.x + likesCount.frame.size.width + 8, 27,
                                      commentImage.frame.size.width, commentImage.frame.size.height);
        [self addSubview:commentImage];
        
        UILabel *commentsCount = [self createLabelWithFrame:CGRectMake(commentImage.frame.origin.x + commentImage.frame.size.width + 4,
                                                                       25, 0, 35) andText:[NSString stringWithFormat:@"%d",[story viewsCount]]];
        [self addSubview:commentsCount];

    }
    return self;
}

- (UILabel *)createLabelWithFrame:(CGRect)frame andText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setText:text];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label setTextColor:[UIColor whiteColor]];
    label.layer.shadowOpacity = 1.0;
    label.layer.shadowRadius = 0.0;
    label.layer.shadowColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1].CGColor;
    label.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    [label sizeToFit];
    return label;
}

- (void)drawRect:(CGRect)rect
{
    float radius = 5.0f;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.35);
    
    // Bottom left corner
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius,
                    radius, M_PI / 4, M_PI / 2, 1);
    
    // Bottom right corner
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius,
                            rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius,
                    rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    
    // Top right corner
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    
    // Top left corner
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
    
    CGContextFillPath(context);
}

@end
