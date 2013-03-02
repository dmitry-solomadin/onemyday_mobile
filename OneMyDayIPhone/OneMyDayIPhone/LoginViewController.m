//
//  LoginViewController.m
//  OneMyDayIPhone
//
//  Created by Admin on 2/22/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "LoginViewController.h"
#import "MasterViewController.h"
#import "Request.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize txtEmail;
@synthesize txtPassword;

MasterViewController *allStoriesView;

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.hidesBackButton = YES;
    self.title = @"Authorization";
}


- (void) alertStatus:(NSString *)msg :(NSString *) title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)loginClick:(id)sender {
    @try {
        
        if([[txtEmail text] isEqualToString:@""] || [[txtPassword text] isEqualToString:@""] ) {
            [self alertStatus:@"Please enter both Email and Password" :@"Login Failed!"];
        } else {
            
            NSString *postString =[[NSString alloc] initWithFormat:@"email=%@&password=%@",[txtEmail text],[txtPassword text]];
            NSString *userId = [[Request alloc] loginRequest: postString];
            
            NSLog(@"userId = %@", userId);
            
            /*allStoriesView = [[AllStoriesView alloc]
                              initWithNibName:@"AllStoriesView"
                              bundle:nil];
            [self.view addSubview:allStoriesView.view];*/
            
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [self alertStatus:@"Login Failed." :@"Login Failed!"];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


@end
