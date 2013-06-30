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

@interface ExploreViewController ()

@end

@implementation ExploreViewController

@synthesize scrollView;

NSMutableArray * stories;
AppDelegate *appDelegate;
UITextField *textField;
CGFloat currentFeedHeight = 10.0;

#define STORY_HEIGHT_WITH_PADDING 360 // 10px padding at the top

- (void)viewWillAppear:(BOOL)animated
{
    scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	appDelegate = [[UIApplication sharedApplication] delegate];
    
    scrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
    [[self view] addSubview:scrollView];
    [self.scrollView setDelegate:self];   
        
    textField = [[UITextField alloc] init];
    textField.clipsToBounds = YES;
    textField.tag = 1;
    textField.layer.cornerRadius = 10.0;
    textField.layer.borderColor = [[UIColor blackColor] CGColor];
    textField.layer.borderWidth = 2;
    //textField.Bounds = [self textRectForBounds:textField.bounds];
    [textField setPlaceholder:@"use # to search by tags"];
    [textField setText:@""];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //textField.textAlignment = UITextAlignmentLeft;
    [textField setKeyboardAppearance:UIKeyboardAppearanceAlert];
    [textField setTextColor:[UIColor blackColor]];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [scrollView addSubview:textField];
    textField.frame = CGRectMake(10, currentFeedHeight , 300, 35);
    textField.delegate = self;
    textField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    [textField setReturnKeyType:UIReturnKeyDone];
    
    currentFeedHeight += 50;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshView
{    
    UIActivityIndicatorView *topIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    topIndicator.frame = CGRectMake(10, 45, 100, 100);
    topIndicator.center = CGPointMake(160, 70);
    topIndicator.hidesWhenStopped = YES;
    [scrollView addSubview: topIndicator];
    [topIndicator bringSubviewToFront: scrollView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [topIndicator startAnimating];
    
    int oldSubViewsCount = [[scrollView subviews] count] - 1;
    for (int i = 0; i < oldSubViewsCount; i++) {
        if([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[ThumbStoryView class]])[[[scrollView subviews] objectAtIndex:i] removeFromSuperview];
    }
    currentFeedHeight = 60;
    
    // how we stop refresh from freezing the main UI thread
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        // do our long running process here   
        
        [NSThread sleepForTimeInterval:3];     
        
        NSMutableArray *newStories = [[StoryStore get] requestStoriesIncludePhotos:YES includeUser:YES newStories: true lastId: 0 withLimit: 100 userId: [appDelegate currentUserId] authorId:0 searchFor:[textField text]];
        
        // do any UI stuff on the main UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"newStories count is: %d", [newStories count]);
            
            NSLog(@"user count is: %d", [[[UserStore get] getUsers] count]);
            
            [topIndicator stopAnimating];
            
            if(newStories != NULL && [newStories count] > 0){
                 
                 NSMutableArray *oldStories = stories;
                 stories = newStories;                
                 
                 int storiesCount = [stories count];
                 
                 //draw new stories
                 for (int i = 0; i < storiesCount; i++) {
                     Story *story = [stories objectAtIndex: i];
                     CGRect frame = CGRectMake(10, currentFeedHeight, 300, 300);
                     ThumbStoryView *thumbStoryView = [[ThumbStoryView alloc] initWithFrame:frame story:story];
                     thumbStoryView.controller = self;
                     //Author hidden button
                     UIButton *authorBtn = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 200, 40)];
                     authorBtn.tag = [story authorId];
                     [authorBtn addTarget:self action:@selector(authorOfStorieTap:) forControlEvents:UIControlEventTouchUpInside];
                     [thumbStoryView addSubview:authorBtn];
                     [thumbStoryView bringSubviewToFront:authorBtn];
                     [scrollView insertSubview: thumbStoryView atIndex: 0];
                     currentFeedHeight  += STORY_HEIGHT_WITH_PADDING;
                 }                   
               
                 [scrollView setContentSize: CGSizeMake(320, currentFeedHeight)];
                 [[StoryStore get] setStories:stories];
             }        
        });
    });
}

/*- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
   
}*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([textField isFirstResponder] && (textField != touch.view))
    {
        [textField resignFirstResponder];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(![[textField text] isEqualToString:@""])[self refreshView];
    [textField resignFirstResponder];
    return YES;
}

- (void)authorOfStorieTap:(UIButton *)sender
{
    appDelegate.authorId = sender.tag; 
    ProfileViewController *profileVC = [[ProfileViewController alloc] init];
    [[self navigationController] pushViewController:profileVC animated:YES];  
}

- (void)storyTap:(NSNumber *)storyId
{
    Story *story = [[StoryStore get] findById:[storyId intValue]];
    ShowStoryViewController *showStoryViewController = [[ShowStoryViewController alloc] initWithStory:story andProfileAuthorId: 0];
    [[self navigationController] pushViewController:showStoryViewController animated:YES];
}

@end
