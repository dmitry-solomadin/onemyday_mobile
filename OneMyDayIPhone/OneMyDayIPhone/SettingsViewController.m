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
    
    if([appDelegate.loggedInFlag intValue]==1)
    {
        NSLog(@"Logging out facebook");
        [appDelegate.session closeAndClearTokenInformation];
    }
    
    else if ([appDelegate.loggedInFlag intValue]==2)
    {
        NSLog(@"Logging out twitter");
        [[DMTwitter shared] logout];
    }
    
    else if ([appDelegate.loggedInFlag intValue]==3)
    {
        NSLog(@"Logging out email");
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_id"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    appDelegate.loggedInFlag = [NSNumber numberWithInt:0];
    
    //StartViewController  *startViewController = [[StartViewController alloc] initWithNibName:@"StartViewController" bundle:nil];
    //[self presentViewController:startViewController animated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
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
