//
//  PopupError.m
//  Onemyday
//
//  Created by dmitry.solomadin on 02.07.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "PopupError.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation PopupError

UIView *parentView;
UILabel *label;
float prevScrollY = 0;

- (id)initWithView:(UIView *)view
{
    self = [super initWithFrame:CGRectMake(0, -30, 320, 30)];
    if (self) {
        UIView *redRectangle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        UIColor *onemydayColor = [appDelegate onemydayColor];
        [redRectangle setBackgroundColor:onemydayColor];
        redRectangle.layer.opacity = 0.8;
        [self addSubview:redRectangle];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 320, 20)];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setShadowColor:[UIColor blackColor]];
        [label setShadowOffset:CGSizeMake(0, 1)];
        [self addSubview:label];
        
        [view addSubview:self];
        parentView = view;        
        
        if ([parentView isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)parentView).delegate = self;
            prevScrollY = ((UIScrollView *)parentView).contentOffset.y;
        }
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float deltaScrollY = ((UIScrollView *)parentView).contentOffset.y - prevScrollY;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + deltaScrollY,
                            self.frame.size.width, self.frame.size.height);
    prevScrollY = ((UIScrollView *)parentView).contentOffset.y;
}

- (void)setTextAndShow:(NSString *)text
{
    [self setText:text];
    [self show];
}

- (void)setText:(NSString *)text
{
    [label setText:text];
}

- (void)show
{
    if ([parentView isKindOfClass:[UIScrollView class]]) {
        self.frame = CGRectMake(self.frame.origin.x, -30 + [(UIScrollView *)parentView contentOffset].y,
                                self.frame.size.width, self.frame.size.height);        
    } 
    
    self.hidden = NO;
    
    [parentView bringSubviewToFront:self];
    
    [UIView beginAnimations:@"showErrorAnimation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.25f];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + 30,
                            self.frame.size.width, self.frame.size.height);
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(hide) withObject:nil afterDelay:3];
}

- (void)hide
{
    [UIView animateWithDuration:0.25 delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn 
                     animations:^{
                         self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - 30,
                                                 self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL compl){
                         self.hidden = YES;
                     }
     ];
}

@end
