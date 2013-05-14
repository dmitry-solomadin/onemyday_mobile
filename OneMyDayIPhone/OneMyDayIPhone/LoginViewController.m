//
//  LoginViewController.m
//  OneMyDayIPhone
//
//  Created by Admin on 2/22/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "Request.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize txtEmail, txtPassword;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey"]];

        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
        txtEmail.leftView = paddingView;
        txtEmail.leftViewMode = UITextFieldViewModeAlways;
        
        UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
        txtPassword.leftView = paddingView2;
        txtPassword.leftViewMode = UITextFieldViewModeAlways;
        
        UIImage *fieldBGImage = [[UIImage imageNamed:@"text_field"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
        [txtEmail setBackground:fieldBGImage];
        [txtPassword setBackground:fieldBGImage];
    }
    return self;
}

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
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
               
                [self loginTask];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    UIViewController *masterController = [AppDelegate initMasterController];
                    [self presentViewController:masterController animated:YES completion:nil];
                });
            });             
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [self alertStatus:@"Login Failed." :@"Login Failed!"];
    }
}

- (void)loginTask
{
    double startTime = [[NSDate date] timeIntervalSince1970];
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    appDelegate.loggedInFlag = [NSNumber numberWithInt:3];
    
    NSString *postString =[[NSString alloc] initWithFormat:@"email=%@&password=%@",[txtEmail text],[txtPassword text]];
    NSString *userId = [[Request alloc] requestLoginWithPath: postString];
    
    NSLog(@"userId = %@", userId);
    
    [self saveCredentials:userId];
    
    double stopTime = [[NSDate date] timeIntervalSince1970];
    
    double time = 2000 - (stopTime - startTime);
    
    //NSLog(@"time %f",time);
    
    if(time > 0) sleep(time / 1000);   
}

- (void)viewWillAppear:(BOOL)animated
{
    [txtEmail becomeFirstResponder];
}

- (void) saveCredentials: userId {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:userId]
                                              forKey:@"user_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
