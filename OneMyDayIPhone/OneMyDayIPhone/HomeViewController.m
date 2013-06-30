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
#import "AppDelegate.h"
#import "ProfileViewController.h"

@interface HomeViewController ()
{
    NSMutableArray * stories;
    UIActivityIndicatorView *topIndicator;
    UIActivityIndicatorView *bottomIndicator;
    bool *oldStoriesLoading;
    CGFloat previousY;
}
@end

@implementation HomeViewController
@synthesize scrollView;

AppDelegate *appDelegate;

#define STORY_HEIGHT_WITH_PADDING 360 // 10px padding at the top

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
    oldStoriesLoading = false;
}

- (void)storyTap:(NSNumber *)storyId
{
    Story *story = [[StoryStore get] findById:[storyId intValue]];
    ShowStoryViewController *showStoryViewController = [[ShowStoryViewController alloc] initWithStory:story andProfileAuthorId: 0];
    [[self navigationController] pushViewController:showStoryViewController animated:YES];
}

/*- (void)authorTap:(NSNumber *)authorId
{
    appDelegate.authorId = [authorId intValue];
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:4];  
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    scrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
    [[self view] addSubview:scrollView];
    [self.scrollView setDelegate:self];
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - scrollView.bounds.size.height, scrollView.frame.size.width, scrollView.bounds.size.height)];
		view.delegate = self;
		[scrollView addSubview:view];
		_refreshHeaderView = view;		
	}
      
    oldFeedHeight = 40.0;
    
    stories = [[StoryStore get] loadStoriesFromDisk];
    __block NSMutableArray *oldStories = stories;
    [[UserStore get] loadUsersFromDisk];
    
    //draw old stories
    for (int i = 0; i < [oldStories count]; i++) {
        Story *story = [oldStories objectAtIndex:i];
        CGRect frame = CGRectMake(10, oldFeedHeight, 300, 300);
        ThumbStoryView *thumbStoryView = [[ThumbStoryView alloc] initWithFrame:frame story:story];
        thumbStoryView.controller = self;
        
        //Author hidden button
        UIButton *authorBtn = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 200, 40)];
        authorBtn.tag = [story authorId];
        [authorBtn addTarget:self action:@selector(authorOfStorieTap:) forControlEvents:UIControlEventTouchUpInside];
        [thumbStoryView addSubview:authorBtn];
        [thumbStoryView bringSubviewToFront:authorBtn];
        
        [scrollView addSubview:thumbStoryView];
        oldFeedHeight += STORY_HEIGHT_WITH_PADDING;
    }       
        
    [scrollView setContentSize:(CGSizeMake(320, oldFeedHeight))];
            
    NSLog(@"oldStories count is: %d", [oldStories count]);    
    NSLog(@"oldUser count is: %d", [[[UserStore get] getUsers] count]);
    
    topIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    topIndicator.frame = CGRectMake(10, 45, 100, 100);
    topIndicator.center = CGPointMake(160, 22);
    topIndicator.hidesWhenStopped = YES;
    [scrollView addSubview: topIndicator];
    [topIndicator bringSubviewToFront: scrollView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [topIndicator startAnimating];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:)
                                                 name:@"refreshViewNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshViewNotification"
     object:self];*/
    
    [self refreshView:0];
}

//methodCallPointer == 0 - cal from viewDidLoad; 1 - from pull to refresh
- (void)refreshView:(int) methodCallPointer
{    
    // how we stop refresh from freezing the main UI thread
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        // do our long running process here
        //[NSThread sleepForTimeInterval:3];
        long storyId = 0;       
        
        if(stories != NULL && [stories count] > 0) storyId = [[stories objectAtIndex:0] storyId];
        
        NSMutableArray *newStories = [[StoryStore get] requestStoriesIncludePhotos:YES includeUser:YES newStories: true lastId: storyId withLimit: 11 userId: [appDelegate currentUserId] authorId:0  serchFor: nil];
        
        // do any UI stuff on the main UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"newStories count is: %d", [newStories count]);
            
            NSLog(@"user count is: %d", [[[UserStore get] getUsers] count]);
            
            [topIndicator stopAnimating];            
            
            //move old stories to top after removing the wheel
            if(methodCallPointer == 0 && stories != NULL && [stories count] > 0)
            {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.2];
                oldFeedHeight = 10.0;
                for (int i = 0; i < [[scrollView subviews] count]; i++) {
                    if([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[ThumbStoryView class]]){                        
                        ThumbStoryView *tSV = [[scrollView subviews] objectAtIndex:i];
                        CGRect rect = tSV.frame;
                        rect.origin = CGPointMake(tSV.frame.origin.x, oldFeedHeight);
                        tSV.frame = rect;
                        oldFeedHeight += STORY_HEIGHT_WITH_PADDING;
                    }
                }
                [scrollView setContentSize: CGSizeMake(320, oldFeedHeight)];
                [UIView commitAnimations];
            }
         
            /*if([[StoryStore get] requestErrorMsg] != nil ){
                NSLog(@"[StoryStore get] requestErrorMsg] %@", [[StoryStore get] requestErrorMsg]);
                [appDelegate alertStatus:@"" :[[StoryStore get] requestErrorMsg]];
                [[StoryStore get] setRequestErrorMsg: nil];
                
            } else */if(newStories != NULL && [newStories count] > 0){
                
                NSMutableArray *oldStories = stories;
                stories = newStories;
                CGFloat currentFeedHeight = 10.0;
               
                int storiesCount = [stories count];                              
               
                //if old stories are too old (last new story id > first old story id) remove old stories
                if(storiesCount == 11 && [[stories objectAtIndex: 10] storyId] != storyId){
                    int oldSubViewsCount = [[scrollView subviews] count] - 1;
                    for (int i = 0; i < oldSubViewsCount; i++) {
                        [[[scrollView subviews] objectAtIndex:1] removeFromSuperview];
                    }
                    oldFeedHeight = 0;                 
                }
                
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
               
               //move old stories to the bottom   
               if (storiesCount != 11 || (storiesCount == 11 && [[stories objectAtIndex: 10] storyId] == storyId)) {
                   int start = storiesCount + 1;
                    for (int i = start, j = 0; i < [[scrollView subviews] count]; i++) {
                        if([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[ThumbStoryView class]]){
                            ThumbStoryView *tSV = [[scrollView subviews] objectAtIndex:i];
                            CGRect rect = tSV.frame;
                            rect.origin = CGPointMake(tSV.frame.origin.x, tSV.frame.origin.y + currentFeedHeight);
                            tSV.frame = rect;
                            [stories addObject: [oldStories objectAtIndex: j]];
                            j++;
                        }
                    }
                }
                
                //update the last update date
                [_refreshHeaderView refreshLastUpdatedDate];
                
                oldFeedHeight += currentFeedHeight;
                [scrollView setContentSize: CGSizeMake(320, oldFeedHeight)];
                [[StoryStore get] setStories:stories];  
            }        
        });
     });
}

- (void)reloadTableViewDataSource
{
	_reloading = YES;
    [self refreshView:1];
}

- (void)doneLoadingTableViewData
{
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)sView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:sView];
    CGFloat direction = scrollView.contentOffset.y - previousY;
    CGFloat pixLeft = oldFeedHeight - scrollView.contentOffset.y;

    if(!oldStoriesLoading && pixLeft <= 500 && pixLeft >= 400 && direction > 0) {
        oldStoriesLoading = true;
        
        bottomIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        bottomIndicator.frame = CGRectMake(10, 45, 100, 100);
        bottomIndicator.center = CGPointMake(160, oldFeedHeight + 20);
        bottomIndicator.hidesWhenStopped = YES;
        [sView addSubview: bottomIndicator];
        [bottomIndicator bringSubviewToFront: sView];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [sView setContentSize: CGSizeMake(320, oldFeedHeight + 50)];
        [bottomIndicator startAnimating];
        
        [self getOldStories];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)sView
{
    previousY = sView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)sView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:sView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading; // should return if data source model is reloading	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

- (void)getOldStories{
	
	// how we stop refresh from freezing the main UI thread
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        
        // do our long running process here
        //[NSThread sleepForTimeInterval:3];
        long storyId = 0;
        
        if(stories != NULL && [stories count] > 0) storyId = [[stories objectAtIndex:([stories count] - 1)] storyId];
        
        NSMutableArray *newStories = [[StoryStore get] requestStoriesIncludePhotos:YES includeUser:YES newStories: false lastId: storyId withLimit: 10 userId: [appDelegate currentUserId] authorId:0 serchFor: nil];
        
        // do any UI stuff on the main UI thread
        dispatch_async(dispatch_get_main_queue(), ^{            
            NSLog(@"newStories count is: %d", [newStories count]);
            NSLog(@"user count is: %d", [[[UserStore get] getUsers] count]);
            
            [bottomIndicator stopAnimating];
            
            [[[scrollView subviews] objectAtIndex:[[scrollView subviews] count]-1] removeFromSuperview];
                        
            /*if([[StoryStore get] requestErrorMsg] != nil && newStories == NULL){
                [appDelegate alertStatus:@"" :[[StoryStore get] requestErrorMsg]];
                [[StoryStore get] setRequestErrorMsg: nil];
                
            } else*/if (newStories != NULL && [newStories count] > 0) {
                for (int i = 0; i < [newStories count]; i++) {
                    Story *story = [newStories objectAtIndex: i];
                    
                    CGRect frame = CGRectMake(10, oldFeedHeight, 300, 300);
                    ThumbStoryView *thumbStoryView = [[ThumbStoryView alloc] initWithFrame:frame story:story];
                    thumbStoryView.controller = self;
                    
                    //Author hidden button
                    UIButton *authorBtn = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 200, 40)];
                    authorBtn.tag = [story authorId];
                    [authorBtn addTarget:self action:@selector(authorOfStorieTap:) forControlEvents:UIControlEventTouchUpInside];
                    [thumbStoryView addSubview:authorBtn];
                    [thumbStoryView bringSubviewToFront:authorBtn];
                    
                    [scrollView addSubview: thumbStoryView];
                    oldFeedHeight += STORY_HEIGHT_WITH_PADDING;
                    
                    [stories addObject:story];
                }                                              
            }
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            [scrollView setContentSize: CGSizeMake(320, oldFeedHeight)];
            [UIView commitAnimations];
            
            NSLog(@"stories count is: %d", [stories count]);
            [[StoryStore get] setStories:stories];
            
            oldStoriesLoading = false;
        });
    });
}

- (void)authorOfStorieTap:(UIButton *)sender
{
    appDelegate.authorId = sender.tag;
    //self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:4];
    ProfileViewController *profileVC = [[ProfileViewController alloc] init];
    [[self navigationController] pushViewController:profileVC animated:YES];
    ///UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:profileVC];
}

@end

