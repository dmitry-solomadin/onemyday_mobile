//
//  MasterViewController.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 17.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "MasterViewController.h"
#import "HomeViewController.h"
#import "ExploreViewController.h"
#import "EditorViewController.h"
#import "ActivityViewController.h"
#import "ProfileViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cool_bg"]];
        
        HomeViewController *hvc = [[HomeViewController alloc] init];
        UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:hvc];
        homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Home", nil) image:[UIImage imageNamed:@"home.png"] tag:0];
        
        ExploreViewController *evc = [[ExploreViewController alloc] init];
        UINavigationController *exploreNav = [[UINavigationController alloc] initWithRootViewController:evc];
        exploreNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Explore", nil) image:[UIImage imageNamed:@"globe.png"] tag:0];
        //[exploreNav.tabBarItem setEnabled:NO];
        
        UIViewController* photoVC = [[UIViewController alloc] init];
        photoVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0];
        
        ActivityViewController *avc = [[ActivityViewController alloc] init];
        UINavigationController *activityNav = [[UINavigationController alloc] initWithRootViewController:avc];
        activityNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Activity", nil) image:[UIImage imageNamed:@"heart.png"] tag:0];
        
        ProfileViewController *profileVC = [[ProfileViewController alloc] init];
        UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:profileVC];
        profileNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Profile", nil) image:[UIImage imageNamed:@"man.png"] tag:0];
        
        NSArray* controllers = [NSArray arrayWithObjects:homeNav, exploreNav, photoVC, activityNav, profileNav, nil];
        self.viewControllers = controllers;
        
        // Add custom 'Tell a story' button
        [self addCenterButtonWithImage:[UIImage imageNamed:@"capture-button.png"] highlightImage:nil];
        EditorViewController *editorViewController = [[EditorViewController alloc] init];
        editorNavController = [[UINavigationController alloc] initWithRootViewController:editorViewController];
    }
    return self;
}

- (void)addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0) {
        button.center = self.tabBar.center;
    } else {
        CGPoint center = self.tabBar.center;
        center.y = center.y - (heightDifference / 2.0);
        button.center = center;
    }
    
    [button addTarget:self action:@selector(tellStoryTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

- (void)tellStoryTap:(UIButton *)sender
{
    [self presentViewController:editorNavController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
