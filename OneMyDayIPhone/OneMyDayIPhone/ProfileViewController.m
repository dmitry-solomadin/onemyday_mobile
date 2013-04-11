//
//  ProfileViewController.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 11.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "ProfileViewController.h"
#import "SettingsViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
