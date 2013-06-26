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
#import "User.h"
#import "UserStore.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize txtEmail, txtPassword;

AppDelegate *appDelegate;
User *user;
Request *request;
User *user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey"]];
        
        appDelegate = [[UIApplication sharedApplication] delegate];

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

- (IBAction)loginClick:(id)sender {
    @try {
        if([[txtEmail text] isEqualToString:@""]) {
            
            [appDelegate alertStatus:@"" :@"Please enter Email" ];
            
        } else if([[txtPassword text] isEqualToString:@""] ) {
            
            [appDelegate alertStatus:@"" :@"Please enter Password" ];
            
        } else {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
               
                [self loginTask];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    //NSLog(@"request errorMsg] %@", [request errorMsg]);
                    if(user != nil){
                        UIViewController *masterController = [AppDelegate initMasterController];
                        [self presentViewController:masterController animated:YES completion:nil];
                    } else if([request errorMsg] != nil){
                        [appDelegate alertStatus:@"" :[request errorMsg]];                        
                    } else {
                        [appDelegate alertStatus:@"" :[request operationFailedMsg]];
                    }
                });
            });             
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [appDelegate alertStatus:@"" :@"Login Failed!"];
    }
}

- (void)loginTask
{
    double startTime = [[NSDate date] timeIntervalSince1970];
    
    request = [[Request alloc] init];
    NSString *postString =[[NSString alloc] initWithFormat:@"email=%@&password=%@",[txtEmail text],[txtPassword text]];
    user = [request requestLoginWithPath: postString];
    if(user != nil){       
        NSLog(@"Login user %d", [user userId]);
        [self saveCredentials:[user userId]];
        appDelegate.loggedInFlag = [NSNumber numberWithInt:3];
        [appDelegate setCurrentUserId: [user userId]];
        [[UserStore get] addUser:user];
        NSLog(@"[appDelegate setCurrentUserId %d", [appDelegate currentUserId]);
    }
    
    double stopTime = [[NSDate date] timeIntervalSince1970];
    
    double time = 2000 - (stopTime - startTime);
    
    if(time > 0) sleep(time / 1000);   
}

- (void)viewWillAppear:(BOOL)animated
{
    [txtEmail becomeFirstResponder];
}

- (void) saveCredentials: (int) userId {
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",userId] forKey:@"user_id"];
    //[[NSUserDefaults standardUserDefaults] setInteger: userId forKey:@"user_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
