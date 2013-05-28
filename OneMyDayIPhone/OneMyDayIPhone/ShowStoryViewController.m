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
#import <QuartzCore/QuartzCore.h>
#import "Request.h"
#import "AppDelegate.h"

@interface ShowStoryViewController ()

@end

@implementation ShowStoryViewController
@synthesize story, scrollView;

- (id) initWithStory:(Story *)_story
{
    if (self = [super initWithNibName: nil bundle: nil]) {
        self.story = _story;
        
        [[self view] setFrame: self.view.window.bounds];
        
        scrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
        [scrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cool_bg"]]];
        [[self view] addSubview:scrollView];
        
        CGFloat currentStoryHeight = 10.0f;
        for (int i = 0; i < [[story photos] count]; i++) {
            // Add photo
            NSDictionary *photo = [[story photos] objectAtIndex:i];
            NSDictionary *photo_urls = (NSDictionary *) [photo objectForKey:@"photo_urls"];
            NSString *image = (NSString*) [photo_urls objectForKey:@"iphone2x_url"];
            
            NSDictionary *photo_dimensions = (NSDictionary *) [photo objectForKey:@"photo_dimensions"];
            NSDictionary *dimensions = (NSDictionary *) [photo_dimensions objectForKey:@"iphone2x"];
            NSNumber *height2x = [dimensions objectForKey:@"height"];
            float height = [height2x floatValue] / 2;

            if (image) {
                AsyncImageView *asyncImageView = [[AsyncImageView alloc] initWithFrame:
                                                  CGRectMake(10, currentStoryHeight, 300, height)];
                asyncImageView.contentMode = UIViewContentModeScaleAspectFit;
                
                NSURL *url = [NSURL URLWithString:image];
                asyncImageView.imageURL = url;
                
                [scrollView addSubview:asyncImageView];
                currentStoryHeight += height;
            }
            
            // Add text
            NSString *caption = (NSString *) [photo objectForKey:@"caption"];
            if (caption != ( NSString *) [ NSNull null ]) {
                UITextView *textView = [[UITextView alloc] init];
                textView.text = caption;
                [textView setEditable:NO];
                [textView setFont:[UIFont systemFontOfSize:15]];
                [textView sizeToFit];
                [textView setBackgroundColor:[UIColor clearColor]];
                [textView setContentInset:UIEdgeInsetsMake(0, -8, 0, 0)];
                [scrollView addSubview:textView];

                textView.frame = CGRectMake(10, currentStoryHeight, 300, textView.contentSize.height);
                [textView sizeToFit];
                currentStoryHeight += textView.contentSize.height;
            }
        }
        
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
        
        currentStoryHeight += 50;
        
        UITextView *likeButtonView = [[UITextView alloc] init];        
        likeButtonView.clipsToBounds = YES;
        likeButtonView.layer.cornerRadius = 14.0;
        likeButtonView.layer.borderColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1] CGColor];
        likeButtonView.layer.borderWidth = 2;
        likeButtonView.text = @"Like";
        [likeButtonView setEditable:NO];
        [likeButtonView setFont:[UIFont systemFontOfSize:18]];
        [likeButtonView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]];
        [likeButtonView setContentInset:UIEdgeInsetsMake(-5, 10, 0, 0)];
        [likeView addSubview:likeButtonView];
        likeButtonView.frame = CGRectMake(15, 12, 70, 27);
        
        UITapGestureRecognizer *likeButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeButtonTapped:)];
        [likeButtonView addGestureRecognizer:likeButtonTap];
        
        UITextView *numberOfPeopleView = [[UITextView alloc] init];
        numberOfPeopleView.text = @"#";
        [numberOfPeopleView setFont:[UIFont systemFontOfSize:20]];
        [likeView addSubview:numberOfPeopleView];
        numberOfPeopleView.frame = CGRectMake(90, 5, 20, 27);
        
        UITextView *numberOfPeopleTextView = [[UITextView alloc] init];
        numberOfPeopleTextView.text = @"people likes this story";
        [numberOfPeopleTextView setFont:[UIFont systemFontOfSize:17]];
        [likeView addSubview:numberOfPeopleTextView];
        numberOfPeopleTextView.frame = CGRectMake(120, 5, 200, 27);
        
        [scrollView setContentSize:(CGSizeMake(10, currentStoryHeight))];
        [scrollView setAutoresizesSubviews:NO];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)likeButtonTapped:(UITapGestureRecognizer *)gr 
{   
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableString *path = [NSString stringWithFormat:@"/api/stories/%d/like", [story storyId]];
    NSString *postData =[[NSString alloc] initWithFormat:
                         @"api_key=75c5e6875c4e6931943b88fe5941470b&user_id=%@",appDelegate.currentUserId];
        
    Request *request = [[Request alloc] init];
    NSDictionary *jsonData = [request getDataFrom: path requestData: postData];
     NSLog(@"jsonData %@", jsonData);
    if([request errorMsg] != nil){
        
        return;
    }

}

@end
