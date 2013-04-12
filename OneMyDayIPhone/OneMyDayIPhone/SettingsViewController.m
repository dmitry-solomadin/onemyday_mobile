//
//  SettingsViewController.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 11.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "StartViewController.h"

#import "DMTwitterCore.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log out"
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self action:@selector(logOut:)];
        
        [logOutButton setTintColor:[UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1.0]];
        self.navigationItem.rightBarButtonItem = logOutButton;
    }
    return self;
}

- (void)logOut:(id)sender
{
    NSLog(@"Logging out...");
    // get the app delegate so that we can access the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    if (appDelegate.session.isOpen)[appDelegate.session closeAndClearTokenInformation];
    
    else if ([DMTwitter shared].oauth_token_authorized)[[DMTwitter shared] logout];
    
    StartViewController  *startViewController = [[StartViewController alloc] initWithNibName:@"StartViewController" bundle:nil];
    
    [[self navigationController] pushViewController:startViewController animated:YES];
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
