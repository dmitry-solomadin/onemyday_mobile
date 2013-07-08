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
#import "UIApplication+NetworkActivity.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize scrollView;
@synthesize userId;

NSMutableArray * stories;
UIActivityIndicatorView *topIndicator;
UIActivityIndicatorView *bottomIndicator;
bool *oldStoriesLoading;
CGFloat previousY;

#define STORY_HEIGHT_WITH_PADDING 360 // 10px padding at the top

CGFloat feedHeight;
AppDelegate *appDelegate;

+ (void)showWithUser:(int)userId andNavController:(UINavigationController *)navController
{
    ProfileViewController *profileVC = [[ProfileViewController alloc] init];
    [profileVC setUserId:userId];
        
    [navController pushViewController:profileVC animated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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
}

-(void)loadUser
{
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        User *user = [[UserStore get] requestUserWithId: userId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
            if(user != nil) {
                feedHeight = 5;
                CGRect frame = CGRectMake(5, feedHeight, 300, 120);
                
                UserInfoView *userInfoView = [[UserInfoView alloc] initWithFrame: frame andUser:user];
                userInfoView.controller = self;
                
                [scrollView addSubview:userInfoView];
                
                feedHeight += 120;
                
                [self loadStories];
            } else [topIndicator stopAnimating];
        });
    });
    
}

-(void)loadStories
{
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{        
        stories = [[StoryStore get] requestStoriesIncludePhotos:YES includeUser:YES newStories: true lastId: 0 withLimit: 11 userId: [appDelegate currentUserId] authorId: userId searchFor: nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [topIndicator stopAnimating];
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
            
            if(stories != nil) {                
                feedHeight += 20;
                
                for (int i = 0; i < [stories count]; i++) {
                    Story *story = [stories objectAtIndex:i];
                    CGRect frame = CGRectMake(10, feedHeight, 300, 300);
                    ThumbStoryView *thumbStoryView = [[ThumbStoryView alloc] initWithFrame:frame story:story
                                                      navController:[self navigationController]];
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
    
    if(userId == 0) {
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self action:@selector(showSettings:)];    
        self.navigationItem.rightBarButtonItem = settingsButton;
        userId = appDelegate.currentUserId;
    }  
        
    topIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    topIndicator.frame = CGRectMake(10, 45, 100, 100);
    topIndicator.center = CGPointMake(160,150);
    topIndicator.hidesWhenStopped = YES;
    [scrollView addSubview: topIndicator];
    [topIndicator bringSubviewToFront: scrollView];
    [topIndicator startAnimating];
    
    [self loadUser];
    
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
        [sView setContentSize: CGSizeMake(320, feedHeight + 50)];
        [bottomIndicator startAnimating];
        
        [self getOldStories];
    }
}

- (void)getOldStories{
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{        
        long storyId = 0;
        
        if(stories != NULL && [stories count] > 0) storyId = [[stories objectAtIndex:([stories count] - 1)] storyId];
        
        NSMutableArray *newStories = [[StoryStore get] requestStoriesIncludePhotos:YES includeUser:YES newStories: false lastId: storyId withLimit: 10 userId: [appDelegate currentUserId] authorId:userId searchFor: nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [bottomIndicator stopAnimating];
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
            
            [[[scrollView subviews] objectAtIndex:[[scrollView subviews] count]-1] removeFromSuperview];
            
            if (newStories != NULL && [newStories count] > 0) {
                for (int i = 0; i < [newStories count]; i++) {
                    Story *story = [newStories objectAtIndex: i];
                    
                    CGRect frame = CGRectMake(10, feedHeight, 300, 300);
                    ThumbStoryView *thumbStoryView = [[ThumbStoryView alloc] initWithFrame:frame story:story
                                                                             navController:[self navigationController]];
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
            
            //[[StoryStore get] setStories:stories];
            
            oldStoriesLoading = false;
        });
    });
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)sView
{
    previousY = sView.contentOffset.y;
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

- (void)editBtnTap:(NSNumber *)_userId
{
    SignUpViewController  *signUpViewController = [SignUpViewController alloc];
    signUpViewController.userId = [_userId intValue];
    [[self navigationController] pushViewController:signUpViewController animated:YES];
}

@end
