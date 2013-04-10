//
//  ShowStoryViewController.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 10.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "ShowStoryViewController.h"
#import "Story.h"
#import "AsyncImageView.h"

@interface ShowStoryViewController ()

@end

@implementation ShowStoryViewController
@synthesize story, scrollView;

- (id) initWithStory:(Story *)_story
{
    if(self = [super initWithNibName: nil bundle: nil]){
        self.story = _story;
        
        [[self view] setFrame: self.view.window.bounds];
        
        scrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
        [[self view] addSubview:scrollView];
        
        CGFloat currentStoryHeight = 0.0f;
        for (int i = 0; i < [[story photos] count]; i++) {
            // Add photo
            NSDictionary *photo = [[story photos] objectAtIndex:i];
            NSDictionary *photo_urls = (NSDictionary *) [photo objectForKey:@"photo_urls"];
            NSString *image = (NSString*) [photo_urls objectForKey:@"thumb_url"];
            if (image) {
                AsyncImageView *asyncImageView = [[AsyncImageView alloc] init];
                NSURL *url = [NSURL URLWithString:image];
                [asyncImageView loadImageFromURL:url];
                
                [scrollView addSubview:asyncImageView];
                asyncImageView.frame = CGRectMake(10, currentStoryHeight, 300, 300);
                currentStoryHeight += 300;
            }
            
            // Add text
            NSString *caption = (NSString *) [photo objectForKey:@"caption"];
            if (caption != ( NSString *) [ NSNull null ]) {
                UITextView *textView = [[UITextView alloc] init];
                textView.text = caption;
                [scrollView addSubview:textView];

                textView.frame = CGRectMake(10, currentStoryHeight, 300, textView.contentSize.height);
                currentStoryHeight += textView.contentSize.height;
            }
        }
        
        CGFloat scrollViewHeight = 0.0f;
        for (UIView* view in [self scrollView].subviews) {
            scrollViewHeight += view.frame.size.height + 20;
        }
        
        [scrollView setContentSize:(CGSizeMake(320, scrollViewHeight))];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

@end
