//
//  ExploreViewController.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 11.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "ExploreViewController.h"
#import "Story.h"
#import "ThumbStoryView.h"
#import "ShowStoryViewController.h"
#import "StoryStore.h"
#import "UserStore.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "ProfileViewController.h"
#import "UIApplication+NetworkActivity.h"

@interface ExploreViewController ()

@end

@implementation ExploreViewController
{
    NSMutableArray *stories;
    AppDelegate *appDelegate;
    UITextField *textField;
    UIButton *cancelButton;
    CGFloat currentFeedHeight;
    UILabel *noStoriesText;
}

@synthesize scrollView;

#define STORY_HEIGHT_WITH_PADDING 360 // 10px padding at the top

- (void)viewWillAppear:(BOOL)animated
{
    scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    noStoriesText.frame = CGRectMake(0, (([[self view] bounds].size.height + 55) / 2) - 20, 320, 20);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentFeedHeight = 10;
    
	appDelegate = [[UIApplication sharedApplication] delegate];
    
    scrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
    [[self view] addSubview:scrollView];
    [self.scrollView setDelegate:self];
    
    // Add top search field background rect
    UIView *searchFieldRect = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
    UIColor *highColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.000];
    UIColor *lowColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.000];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setFrame:[searchFieldRect bounds]];
    [gradient setColors:[NSArray arrayWithObjects:(id)[highColor CGColor], (id)[lowColor CGColor], nil]];
    [searchFieldRect.layer insertSublayer:gradient atIndex:0];
    searchFieldRect.layer.masksToBounds = NO;
    searchFieldRect.layer.shadowOffset = CGSizeMake(0, 1);
    searchFieldRect.layer.shadowRadius = 1;
    searchFieldRect.layer.shadowOpacity = 0.5;
    [scrollView addSubview:searchFieldRect];

    // Add top search field
    textField = [[UITextField alloc] initWithFrame:CGRectMake(10, currentFeedHeight , 300, 37)];
    textField.tag = 1;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    UIImage *fieldBGImage = [[UIImage imageNamed:@"text_field"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    [textField setBackground:fieldBGImage];
    [textField setPlaceholder:NSLocalizedString(@"use # to search by tags", nil)];
    [textField setText:@""];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.delegate = self;
    [textField setReturnKeyType:UIReturnKeyDone];
    [scrollView addSubview:textField];
    
    // Add cancel button
    cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(320, 10, 70, 36)];
    [cancelButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cancel_button"]]];
    [cancelButton addTarget:self action:@selector(cancelButtonTap:) forControlEvents:UIControlEventTouchDown];
    [scrollView addSubview:cancelButton];
    
    // Add no stories text
    noStoriesText = [[UILabel alloc] init];
    [noStoriesText setText:NSLocalizedString(@"No stories found", nil)];
    [noStoriesText setTextColor:[UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1]];
    [noStoriesText setBackgroundColor:[UIColor clearColor]];
    [noStoriesText setFont:[UIFont systemFontOfSize:22]];
    [noStoriesText setShadowColor:[UIColor whiteColor]];
    [noStoriesText setShadowOffset:CGSizeMake(0, 1)];
    [noStoriesText setTextAlignment:NSTextAlignmentCenter];
    noStoriesText.hidden = YES;
    [scrollView addSubview:noStoriesText];
    
    currentFeedHeight += 55;
}

- (void)refreshView
{
    noStoriesText.hidden = YES;
    UIActivityIndicatorView *topIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    topIndicator.frame = CGRectMake(10, 50, 100, 100);
    topIndicator.center = CGPointMake(160, 75);
    topIndicator.hidesWhenStopped = YES;
    [scrollView addSubview: topIndicator];
    [topIndicator bringSubviewToFront: scrollView];
    [topIndicator startAnimating];
    
    int oldSubViewsCount = [[scrollView subviews] count] - 1;
    NSMutableArray *subviewsToRemove = [[NSMutableArray alloc] init];
    for (int i = 0; i < oldSubViewsCount; i++) {
        if([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[ThumbStoryView class]]) {
            [subviewsToRemove addObject:[[scrollView subviews] objectAtIndex:i]];
        }
    }
    for (UIView *subviewToRemove in subviewsToRemove) {
        [subviewToRemove removeFromSuperview];
    }
    currentFeedHeight = 65;
    
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        
        NSString *searchText = [textField text];        
        NSMutableArray *newStories = [[StoryStore get] requestStoriesIncludePhotos:YES includeUser:YES newStories: true lastId: 0 withLimit: 100 userId: [appDelegate currentUserId] authorId:0 searchFor:searchText];

        dispatch_async(dispatch_get_main_queue(), ^{
            [topIndicator stopAnimating];
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
            
            if (newStories != NULL && [newStories count] > 0) {
                 stories = newStories;                
                 
                 int storiesCount = [stories count];
                 
                 //draw new stories
                 for (int i = 0; i < storiesCount; i++) {
                     Story *story = [stories objectAtIndex: i];
                     CGRect frame = CGRectMake(10, currentFeedHeight, 300, 300);
                     ThumbStoryView *thumbStoryView = [[ThumbStoryView alloc] initWithFrame:frame story:story
                                                                              navController:[self navigationController]];
                     thumbStoryView.controller = self;
                     [scrollView insertSubview:thumbStoryView atIndex:0];
                     currentFeedHeight += STORY_HEIGHT_WITH_PADDING;
                 }
               
                 [scrollView setContentSize: CGSizeMake(320, currentFeedHeight)];
            } else {
                noStoriesText.hidden = NO;
            }
        });
    });
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self showCancel];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([textField isFirstResponder] && (textField != touch.view)) {
        [textField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)txtField
{
    [self hideCancel];
    if(![[txtField text] isEqualToString:@""])[self refreshView];
    [txtField resignFirstResponder];
    return YES;
}

- (void)cancelButtonTap:(id)sender
{
    [self hideCancel];
    [textField resignFirstResponder];
}

- (void)showCancel
{
    [UIView animateWithDuration:0.25 delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         NSLog(@"here");
                         textField.frame = CGRectMake(textField.frame.origin.x, textField.frame.origin.y,
                                                      textField.frame.size.width - 80, textField.frame.size.height);
                         cancelButton.frame = CGRectMake(cancelButton.frame.origin.x - 80, cancelButton.frame.origin.y,
                                                         cancelButton.frame.size.width, cancelButton.frame.size.height);
                     }
                     completion:nil
     ];
}

- (void)hideCancel
{
    [UIView animateWithDuration:0.25 delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         textField.frame = CGRectMake(textField.frame.origin.x, textField.frame.origin.y,
                                                      textField.frame.size.width + 80, textField.frame.size.height);
                         cancelButton.frame = CGRectMake(cancelButton.frame.origin.x + 80, cancelButton.frame.origin.y,
                                                         cancelButton.frame.size.width, cancelButton.frame.size.height);
                     }
                     completion:nil
     ];
}

- (void)storyTap:(NSNumber *)storyId
{
    Story *story;
    int id = [storyId intValue];
    for(int i = 0; i < [stories count]; i++){
        Story *s = [stories objectAtIndex:i];
        if([s storyId] == id){
            story = s;
            break;
        }
    }    
    ShowStoryViewController *showStoryViewController = [[ShowStoryViewController alloc] initWithStory:story];
    [[self navigationController] pushViewController:showStoryViewController animated:YES];
}

@end
