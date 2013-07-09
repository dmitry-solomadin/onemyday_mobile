//
//  ActivityViewController.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 11.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "ActivityViewController.h"
#import "Request.h"
#import "StoryStore.h"
#import "ActivityView.h"
#import <QuartzCore/QuartzCore.h>
#import "ShowStoryViewController.h"
#import "ProfileViewController.h"
#import "AppDelegate.h"

@interface ActivityViewController ()

@end

@implementation ActivityViewController

@synthesize scrollView;

CGFloat currentHeight = 5.0;
UIActivityIndicatorView *bottomIndicator;
bool *oldActivitiesLoading;
CGFloat previousY;
AppDelegate *appDelegate;
UILabel *noActivitiesText;

- (void)viewWillAppear:(BOOL)animated
{
    scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    noActivitiesText.frame = CGRectMake(0, ([[self view] bounds].size.height / 2) - 20, 320, 20);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    scrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
    [[self view] addSubview: scrollView];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    [self.scrollView setDelegate:self];
    
    // Add no activities text    
    noActivitiesText = [[UILabel alloc] init];
    [noActivitiesText setText:@"No activities yet"];
    [noActivitiesText setTextColor:[UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1]];
    [noActivitiesText setBackgroundColor:[UIColor clearColor]];
    [noActivitiesText setFont:[UIFont systemFontOfSize:22]];
    [noActivitiesText setShadowColor:[UIColor whiteColor]];
    [noActivitiesText setShadowOffset:CGSizeMake(0, 1)];
    [noActivitiesText setTextAlignment:NSTextAlignmentCenter];
    noActivitiesText.hidden = YES;
    [scrollView addSubview:noActivitiesText];
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - scrollView.bounds.size.height, scrollView.frame.size.width, scrollView.bounds.size.height)];
		view.delegate = self;
		[scrollView addSubview:view];
		_refreshHeaderView = view;
	}
    [self getAvtivities];
}

- (void)getAvtivities
{
    noActivitiesText.hidden = YES;
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{        
        int activityId = 0;
        
        for (int i = 0; i < [[scrollView subviews] count]; i++) {
            if([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[ActivityView class]]){
                ActivityView *aV = [[scrollView subviews] objectAtIndex:i];
                activityId = aV.tag;
                break;
            }
        }        
        
        Request *request = [[Request alloc] init];
        NSMutableString *path = [NSString stringWithFormat:@"/users/%d/activities.json?limit=11&higher_than_id=%d", appDelegate.currentUserId,activityId];
        NSArray *activities = [request send:path];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([activities count] == 0) {
                noActivitiesText.hidden = NO;
            }
            
            if (activities != nil) {
                int activitiesCount = [activities count];
                
                //if old activities are too old (last new activity id > first old activity id) remove old activities
                if(activitiesCount == 11 && [[[activities objectAtIndex: 10]  objectForKey:@"id"] intValue] != activityId){
                    int oldSubViewsCount = [[scrollView subviews] count] - 1;
                    for (int i = 0; i < oldSubViewsCount; i++) {
                        [[[scrollView subviews] objectAtIndex:1] removeFromSuperview];
                    }
                    currentHeight = 0;
                }
                
                for (int i = 0; i < activitiesCount; i++) {
                    NSDictionary *activity = [activities objectAtIndex:i];
                 
                    CGRect frame = CGRectMake(10, currentHeight, 300, 60);
                    ActivityView *activityView = [[ActivityView alloc] initWithFrame:frame
                                                                         andActivity:activity];
                    activityView.controller = self;
                  
                    if (activityView != nil) {
                        [scrollView addSubview: activityView];
                        currentHeight += (activityView.frame.size.height + 4); // to remove 2px border
                    }                                    
                }
                
                //move old activities to the bottom
                if (activitiesCount != 11 || (activitiesCount == 11 && [(NSString *) [[activities objectAtIndex: 10]  objectForKey:@"id"] intValue] == activityId)) {
                    int start = activitiesCount + 1;
                    for (int i = start, j = 0; i < [[scrollView subviews] count]; i++) {
                        if([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[ActivityView class]]){
                            ActivityView *aV = [[scrollView subviews] objectAtIndex:i];
                            CGRect rect = aV.frame;
                            rect.origin = CGPointMake(aV.frame.origin.x, aV.frame.origin.y + currentHeight);
                            aV.frame = rect;                         
                            j++;
                        }
                    }
                }
                
                //update the last update date
                [_refreshHeaderView refreshLastUpdatedDate];                
              
                [scrollView setContentSize: CGSizeMake(320, currentHeight)];
            }     
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)storyTap:(NSNumber *)storyId
{
    Story *story = [[StoryStore get] findById:[storyId intValue]];
    ShowStoryViewController *showStoryViewController = [[ShowStoryViewController alloc] initWithStory:story];
    [[self navigationController] pushViewController:showStoryViewController animated:YES];
}

- (void)authorOfStoryTap:(NSNumber *)authorId
{   
    ProfileViewController *profileVC = [[ProfileViewController alloc] init];
    [profileVC setUserId:[authorId intValue]];
    [[self navigationController] pushViewController:profileVC animated:YES];  
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

- (void)reloadTableViewDataSource
{
	 _reloading = YES;
     [self getAvtivities];
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
    CGFloat pixLeft = currentHeight - scrollView.contentOffset.y;

    if(!oldActivitiesLoading && pixLeft <= 500 && pixLeft >= 400 && direction > 0) {
        oldActivitiesLoading = true;
        
        bottomIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        bottomIndicator.frame = CGRectMake(10, 45, 100, 100);
        bottomIndicator.center = CGPointMake(160, currentHeight + 20);
        bottomIndicator.hidesWhenStopped = YES;
        [sView addSubview: bottomIndicator];
        [bottomIndicator bringSubviewToFront: sView];
        [sView setContentSize: CGSizeMake(320, currentHeight + 50)];
        [bottomIndicator startAnimating];
        
        [self getOldActivities];
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

- (void)getOldActivities{
	
	// how we stop refresh from freezing the main UI thread
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        
        int activityId = 0;
        
        int subViewsCount = [[scrollView subviews] count] - 1;
        
        for (int i = subViewsCount ; i > 0; i--) {
            if([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[ActivityView class]]){
                ActivityView *aV = [[scrollView subviews] objectAtIndex:i];
                activityId = aV.tag;
                break;
            }
        }
        
        Request *request = [[Request alloc] init];
        NSMutableString *path = [NSString stringWithFormat:@"/users/1/activities.json?limit=11&lower_than_id=%d",activityId];
        NSArray *activities = [request send: path];
        [NSThread sleepForTimeInterval:3];
        // do any UI stuff on the main UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [bottomIndicator stopAnimating];
            
            [[[scrollView subviews] objectAtIndex:[[scrollView subviews] count]-1] removeFromSuperview];
            
            if(activities != nil){
                
                int activitiesCount = [activities count];
                
                //if old activities are too old (last new activity id > first old activity id) remove old activities
                if(activitiesCount == 11 && [[[activities objectAtIndex: 10]  objectForKey:@"id"] intValue] != activityId){
                    int oldSubViewsCount = [[scrollView subviews] count] - 1;
                    for (int i = 0; i < oldSubViewsCount; i++) {
                        [[[scrollView subviews] objectAtIndex:1] removeFromSuperview];
                    }
                    currentHeight = 0;
                }
                
                for (int i = 0; i < activitiesCount; i++) {
                    NSDictionary *activity = [activities objectAtIndex:i];
                    
                    CGRect frame = CGRectMake(10, currentHeight, 300, 60);
                    ActivityView *activityView = [[ActivityView alloc] initWithFrame:frame
                                                                         andActivity:activity];
                    activityView.controller = self;
                    
                    if(activityView != nil){
                        [scrollView addSubview: activityView];
                        currentHeight += (activityView.frame.size.height + 4); // to remove 2px border
                    }
                }            [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                [scrollView setContentSize: CGSizeMake(320, currentHeight)];
                [UIView commitAnimations];
            }
            
            oldActivitiesLoading = false;
        });
    });
}

@end
