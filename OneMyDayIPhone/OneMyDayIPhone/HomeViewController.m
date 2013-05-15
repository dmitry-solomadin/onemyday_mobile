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
    NSMutableArray * stories;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:)
                                                 name:@"AsyncImageLoadDidFail" object:nil];
    
    scrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
    [[self view] addSubview:scrollView];
    [self.scrollView setDelegate:self];
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - scrollView.bounds.size.height, scrollView.frame.size.width, scrollView.bounds.size.height)];
		view.delegate = self;
		[scrollView addSubview:view];
		_refreshHeaderView = view;		
	}
      
    oldFeedHeight = 10.0;
    
    stories = [[StoryStore get] loadStoriesFromDisk];
    __block NSMutableArray *oldStories = stories;
    [[UserStore get] loadUsersFromDisk];
    NSLog(@"stories %@", stories);
    
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
    
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(10, 45, 300, 300);
    indicator.center = CGPointMake(160, 15);
    indicator.hidesWhenStopped = YES;
    [scrollView addSubview: indicator];
    [indicator bringSubviewToFront: scrollView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [indicator startAnimating];
    
    [self refreshView: nil];
    
    // Add this instance of TestClass as an observer of the TestNotification.
    // We tell the notification center to inform us of "TestNotification"
    // notifications using the receiveTestNotification: selector. By
    // specifying object:nil, we tell the notification center that we are not
    // interested in who posted the notification. If you provided an actual
    // object rather than nil, the notification center will only notify you
    // when the notification was posted by that particular object.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView:)
                                             name:@"refreshViewNotification"
                                             object:nil];
	
}

- (void)refreshView:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"refreshViewNotification"])
                        NSLog (@"Successfully received the test notification!");

	
    
    // how we stop refresh from freezing the main UI thread
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        
        // do our long running process here
        //[NSThread sleepForTimeInterval:3];
        long storyId = 0;       
        
        if(stories != NULL && [stories count] > 0) storyId = [[stories objectAtIndex:0] storyId];
        NSLog(@"storyId %ld", storyId);
        NSMutableArray *newStories = [[StoryStore get]
                                      requestStoriesIncludePhotos:YES includeUser:YES higherThanId: storyId withLimit: 11];
        
        // do any UI stuff on the main UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"newStories count is: %d", [newStories count]);
            
            NSLog(@"user count is: %d", [[[UserStore get] getUsers] count]);
            
            if(newStories != NULL && [newStories count] > 0)
            {
                NSMutableArray *oldStories = stories;
                stories = newStories;
                CGFloat currentFeedHeight = 10.0;
                Story *oldStory = nil;
                if(oldStories != NULL && [oldStories count] > 0)oldStory = [oldStories objectAtIndex: 0];
                int storiesCount = [stories count];
                NSLog(@"[[scrollView subviews] count] %d",[[scrollView subviews] count]);                
               
                if(storiesCount == 11 && [[stories objectAtIndex: 10] storyId] != storyId){
                    int oldSubViewsCount = [[scrollView subviews] count] - 1;
                    for (int i = 0; i < oldSubViewsCount; i++) {
                       
                        //if([[[scrollView subviews] objectAtIndex:j] isKindOfClass:[ThumbStoryView class]]){                           
                           
                            [[[scrollView subviews] objectAtIndex:1] removeFromSuperview];                           
                            
                        //} else j++;
                        
                    }
                    oldFeedHeight = 0;
                    NSLog(@"[[scrollView subviews] count] %d",[[scrollView subviews] count]);
                }
                
                for (int i = 0; i < storiesCount; i++) {
                    
                    Story *story = [stories objectAtIndex: i];
                    //NSLog(@"i %d", i);
                    //NSLog(@"story %@", [story title]);
                    //if(oldStory != nil && [oldStory storyId] == [story storyId]) break;                    
                    
                    CGRect frame = CGRectMake(10, currentFeedHeight, 300, 300);
                    ThumbStoryView *thumbStoryView = [[ThumbStoryView alloc] initWithFrame:frame story:story];
                    thumbStoryView.controller = self;
                    [scrollView insertSubview: thumbStoryView atIndex: 0];
                    currentFeedHeight  += 355;
                }
                NSLog(@"[[scrollView subviews] count] %d",[[scrollView subviews] count]);
                
                
                    
               if(storiesCount != 11 || (storiesCount != 11 && [[stories objectAtIndex: 10] storyId] != storyId)){
                   int start = storiesCount + 1;
                    for (int i = start, j = 0; i < [[scrollView subviews] count]; i++) {
                    
                        if([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[ThumbStoryView class]]){                            
                            NSLog(@" i = %d j %d",i,j);
                            ThumbStoryView *tSV = [[scrollView subviews] objectAtIndex:i];
                            CGRect rect = tSV.frame;
                            rect.origin = CGPointMake(tSV.frame.origin.x, tSV.frame.origin.y + currentFeedHeight);
                            tSV.frame = rect;
                            [stories addObject: [oldStories objectAtIndex: j]];
                            j++;
                        }
                    }
                }
                //  update the last update date
                [_refreshHeaderView refreshLastUpdatedDate];
                oldFeedHeight += currentFeedHeight;
                [scrollView setContentSize: CGSizeMake(320, oldFeedHeight)];
                
            }
            
            NSLog(@"stories count is: %d", [stories count]);
            [[StoryStore get] setStories:stories];
            [indicator stopAnimating];
            
            //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
        });
    
}

- (void)handleNotification:(NSNotification *)note
{
    NSLog(@"IMAGE FAILED LOADING");
}

@end
