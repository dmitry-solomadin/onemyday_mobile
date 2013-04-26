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
}
@end

@implementation HomeViewController
@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //stories = [[StoryStore get] loadStoriesFromDisk];
        //[[UserStore get] loadUsersFromDisk];
        stories = [[StoryStore get] requestStoriesIncludePhotos:YES includeUser:YES];
        NSLog(@"user count is: %d", [[[UserStore get] getUsers] count]);
        NSLog(@"stories count is: %d", [stories count]);
        
        [[self view] setFrame: self.view.window.bounds];
        
        scrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
        [[self view] addSubview:scrollView];
        
        CGFloat currentFeedHeight = 10.0;
        for (int i = 0; i < [stories count]; i++) {
            Story *story = [stories objectAtIndex:i];
            CGRect frame = CGRectMake(10, currentFeedHeight, 300, 300);
            ThumbStoryView *thumbStoryView = [[ThumbStoryView alloc] initWithFrame:frame story:story];
            thumbStoryView.controller = self;
            
            [scrollView addSubview:thumbStoryView];
            currentFeedHeight += 355;
        }
        
        [scrollView setContentSize:(CGSizeMake(320, currentFeedHeight))];
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

@end
