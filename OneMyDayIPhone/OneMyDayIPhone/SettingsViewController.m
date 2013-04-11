//
//  SettingsViewController.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 11.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "SettingsViewController.h"

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
