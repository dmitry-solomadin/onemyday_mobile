//
//  NewMasterViewController.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 09.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "HomeViewController.h"
#import "Request.h"
#import "Story.h"
#import "ThumbStoryView.h"
#import "ShowStoryViewController.h"
#import "StoryStore.h"
#import "UserStore.h"

@interface HomeViewController ()
{
    NSArray * stories;
    UIActivityIndicatorView *indicator;
}
@end

@implementation HomeViewController
@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)storyTap:(NSNumber *)storyId
{
    Story *story = [[StoryStore get] findById:[storyId intValue]];
    ShowStoryViewController *showStoryViewController = [[ShowStoryViewController alloc] initWithStory:story];
    [[self navigationController] pushViewController:showStoryViewController animated:YES];
}

- (void)viewDidLoad
{     
    [super viewDidLoad];
    
    
    
    scrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
    [[self view] addSubview:scrollView];    
      
    __block CGFloat oldFeedHeight = 10.0;
    
    __block NSArray * oldStories = [[StoryStore get] loadStoriesFromDisk];
    [[UserStore get] loadUsersFromDisk];
    
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(10, 45, 300, 300);
    indicator.center = CGPointMake(160, 15);
    indicator.hidesWhenStopped = YES;
    [scrollView addSubview: indicator];
    [indicator bringSubviewToFront: scrollView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    [indicator startAnimating];                    
    
    for (int i = 0; i < [oldStories count]; i++) {
        Story *story = [oldStories objectAtIndex:i];
        CGRect frame = CGRectMake(10, oldFeedHeight, 300, 300);
        ThumbStoryView *thumbStoryView = [[ThumbStoryView alloc] initWithFrame:frame story:story];
        thumbStoryView.controller = self;
                
        [scrollView addSubview:thumbStoryView];
        oldFeedHeight += 355;        
    }       
        
    [scrollView setContentSize:(CGSizeMake(320, oldFeedHeight))];
            
    NSLog(@"oldStories count is: %d", [oldStories count]);
        
    NSLog(@"oldUser count is: %d", [[[UserStore get] getUsers] count]);
        
    // how we stop refresh from freezing the main UI thread
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
            
            // do our long running process here
            [NSThread sleepForTimeInterval:3];
            
            stories = [[StoryStore get] requestStoriesIncludePhotos:YES includeUser:YES];
            
            // do any UI stuff on the main UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                //self.myLabel.text = @"After!";
                
                NSLog(@"stories count is: %d", [stories count]);
                
                NSLog(@"user count is: %d", [[[UserStore get] getUsers] count]);                
               
               
                if([stories count] > 0)
                {                    
                    CGFloat currentFeedHeight = 10.0;
                    Story *oldStory = [oldStories objectAtIndex: 0];
                    int newStoriesCount = 0;
                    
                    for (int i = 0; i < [stories count]; i++) {
                        
                        Story *story = [stories objectAtIndex: i];
                        
                        if([oldStory storyId] == [story storyId]) break;
                       
                        newStoriesCount++;
                        CGRect frame = CGRectMake(10, currentFeedHeight, 300, 300);
                        ThumbStoryView *thumbStoryView = [[ThumbStoryView alloc] initWithFrame:frame story:story];
                        thumbStoryView.controller = self;
                        [scrollView insertSubview: thumbStoryView atIndex: 0];
                        currentFeedHeight  += 355;
                    }
                    
                    if(newStoriesCount > 0)
                    {
                        for (int i = newStoriesCount; i < [[scrollView subviews] count]; i++ ) {
                        
                            if([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[ThumbStoryView class]])
                            {
                                ThumbStoryView *tSV = [[scrollView subviews] objectAtIndex:i];
                                CGRect rect = tSV.frame;
                                rect.origin = CGPointMake(tSV.frame.origin.x, tSV.frame.origin.y + currentFeedHeight);
                                tSV.frame = rect;
                            }
                        }
                    }
                
                    [scrollView setContentSize: CGSizeMake(320, currentFeedHeight + oldFeedHeight)];
                                    
                }
                
            [indicator stopAnimating];
                
            //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                               
              
            });
        });        
       
    
    
}
@end
