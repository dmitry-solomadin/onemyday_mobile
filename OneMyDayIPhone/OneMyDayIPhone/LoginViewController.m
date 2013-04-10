//
//  LoginViewController.m
//  OneMyDayIPhone
//
//  Created by Admin on 2/22/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "LoginViewController.h"
#import "NewMasterViewController.h"
#import "Request.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize txtEmail, txtPassword;

- (void) alertStatus:(NSString *)msg :(NSString *) title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
            
            NewMasterViewController *mvc = [[NewMasterViewController alloc] init];
            [self presentViewController:mvc animated:YES completion:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            //[self.navigationController popToRootViewControllerAnimated:NO];
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [self alertStatus:@"Login Failed." :@"Login Failed!"];
    }
}



// TODO. Not sure we need this
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

@end
