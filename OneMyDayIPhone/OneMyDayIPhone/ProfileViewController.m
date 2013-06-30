//
//  ProfileViewController.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 11.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "User.h"
#import "UserStore.h"
#import "UserInfoView.h" 
#import "Request.h"
#import "Story.h"
#import "StoryStore.h"
#import "AppDelegate.h"
#import "ThumbStoryView.h"
#import "ShowStoryViewController.h"
#import "SignUpViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize scrollView;

NSMutableArray * stories;
UIActivityIndicatorView *topIndicator;
UIActivityIndicatorView *bottomIndicator;
bool *oldStoriesLoading;
CGFloat previousY;
int userId;

#define STORY_HEIGHT_WITH_PADDING 360 // 10px padding at the top

CGFloat feedHeight;
AppDelegate *appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self action:@selector(showSettings:)];
        self.navigationItem.rightBarButtonItem = settingsButton;
    }
    return self;
}

- (void)showSettings:(UIBarButtonItem *)sender
{
    SettingsViewController *svc = [[SettingsViewController alloc] init];
    [[self navigationController] pushViewController:svc animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.   
  
}

-(void)loadStories
{
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        
        //NSLog(@"user %d", userId);
        
        stories = [[StoryStore get] requestStoriesIncludePhotos:YES includeUser:YES newStories: true lastId: 0 withLimit: 11 userId: [appDelegate currentUserId] authorId: userId searchFor: nil];
        
        // do any UI stuff on the main UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //NSLog(@"newStories count is: %d", [stories count]);
            
            //NSLog(@"user count is: %d", [[[UserStore get] getUsers] count]);
            
            [topIndicator stopAnimating];
            
            if(stories != nil){
                
                feedHeight += 20;
                
                for (int i = 0; i < [stories count]; i++) {
                    Story *story = [stories objectAtIndex:i];
                    CGRect frame = CGRectMake(10, feedHeight, 300, 300);
                    ThumbStoryView *thumbStoryView = [[ThumbStoryView alloc] initWithFrame:frame story:story];
                    thumbStoryView.controller = self;
                    
                    [scrollView addSubview:thumbStoryView];
                    feedHeight += STORY_HEIGHT_WITH_PADDING;
                }
                
                [scrollView setContentSize:(CGSizeMake(320, feedHeight))];
            }
            
                    
        });
    });

}

- (void)viewWillDisappear:(BOOL)animated{
    [scrollView removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated
{
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    scrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
    [[self view] addSubview:scrollView];
    [self.scrollView setDelegate: self];
    
    //NSLog(@"appDelegate.authorId: %d", appDelegate.authorId);
    
    if(appDelegate.authorId != 0){
        userId = appDelegate.authorId;
        appDelegate.authorId = 0;
    } else userId = appDelegate.currentUserId;
    
    //NSLog(@"q %d",userId);
    
    User *user = [[UserStore get] findById: userId];
    
    //if(user == nil)[[UserStore get] requestUserWithId: userId];
    
    //NSLog(@"user %@",user);
    
     //NSLog(@"userid %d",[user userId]);
    
     NSLog(@"userName %@",[user name]);
    
    feedHeight = 5;
    
    CGRect frame = CGRectMake(5, feedHeight, 300, 120);
    
    UserInfoView *userInfoView = [[UserInfoView alloc] initWithFrame: frame andUser:user];
    
    userInfoView.controller = self;
    
    [scrollView addSubview:userInfoView];
    
    feedHeight += 120;
    
    topIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    topIndicator.frame = CGRectMake(10, 45, 100, 100);
    topIndicator.center = CGPointMake(160,150);
    topIndicator.hidesWhenStopped = YES;
    [scrollView addSubview: topIndicator];
    [topIndicator bringSubviewToFront: scrollView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [topIndicator startAnimating];
    
    userId = [user userId];
    
    //NSLog(@"userId p %d",userId);
    
    [self loadStories];
    
    scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    oldStoriesLoading = false;
}


- (void)scrollViewDidScroll:(UIScrollView *)sView
{
    CGFloat direction = scrollView.contentOffset.y - previousY;
    CGFloat pixLeft = feedHeight - scrollView.contentOffset.y;
    
    if(!oldStoriesLoading && pixLeft <= 500 && pixLeft >= 400 && direction > 0 && [stories count] > 9) {
        oldStoriesLoading = true;
        
        bottomIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        bottomIndicator.frame = CGRectMake(10, 45, 100, 100);
        bottomIndicator.center = CGPointMake(160, feedHeight + 20);
        bottomIndicator.hidesWhenStopped = YES;
        [sView addSubview: bottomIndicator];
        [bottomIndicator bringSubviewToFront: sView];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [sView setContentSize: CGSizeMake(320, feedHeight + 50)];
        [bottomIndicator startAnimating];
        
        [self getOldStories];
    }
}

- (void)getOldStories{
	
	// how we stop refresh from freezing the main UI thread
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        
        // do our long running process here
        //[NSThread sleepForTimeInterval:3];
        long storyId = 0;
        
        if(stories != NULL && [stories count] > 0) storyId = [[stories objectAtIndex:([stories count] - 1)] storyId];
        
        NSMutableArray *newStories = [[StoryStore get] requestStoriesIncludePhotos:YES includeUser:YES newStories: false lastId: storyId withLimit: 10 userId: [appDelegate currentUserId] authorId:userId searchFor: nil];
        
        // do any UI stuff on the main UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"newStories count is: %d", [newStories count]);
            NSLog(@"user count is: %d", [[[UserStore get] getUsers] count]);
            
            [bottomIndicator stopAnimating];
            
            [[[scrollView subviews] objectAtIndex:[[scrollView subviews] count]-1] removeFromSuperview];
            
            /*if([[StoryStore get] requestErrorMsg] != nil && newStories == NULL){
                [appDelegate alertStatus:@"" :[[StoryStore get] requestErrorMsg]];
                [[StoryStore get] setRequestErrorMsg: nil];
                
            } else*/ if (newStories != NULL && [newStories count] > 0) {
                for (int i = 0; i < [newStories count]; i++) {
                    Story *story = [newStories objectAtIndex: i];
                    
                    CGRect frame = CGRectMake(10, feedHeight, 300, 300);
                    ThumbStoryView *thumbStoryView = [[ThumbStoryView alloc] initWithFrame:frame story:story];
                    thumbStoryView.controller = self;
                    [scrollView addSubview: thumbStoryView];
                    feedHeight += STORY_HEIGHT_WITH_PADDING;
                    
                    [stories addObject:story];
                }
            }
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            [scrollView setContentSize: CGSizeMake(320, feedHeight)];
            [UIView commitAnimations];            
            
            [[StoryStore get] setStories:stories];
            
            oldStoriesLoading = false;
        });
    });
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)sView
{
    previousY = sView.contentOffset.y;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)storyTap:(NSNumber *)storyId
{
    Story *story = [[StoryStore get] findById:[storyId intValue]];
    ShowStoryViewController *showStoryViewController = [[ShowStoryViewController alloc]
                                                        initWithStory:story andProfileAuthorId: userId];
    [[self navigationController] pushViewController:showStoryViewController animated:YES];
}

- (void)editBtnTap:(NSNumber *)_userId
{
    //NSLog(@"authorId %@", _userId);
    SignUpViewController  *signUpViewController = [SignUpViewController alloc];
    signUpViewController.userId = [_userId intValue];
    [[self navigationController] pushViewController:signUpViewController animated:YES];
}

@end
