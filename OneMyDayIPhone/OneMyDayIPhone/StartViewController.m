//
//  StartViewController.m
//  OneMyDayIPhone
//
//  Created by Admin on 4/10/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "StartViewController.h"
#import "LoginViewController.h"

#import "DMOAuthTwitter.h"
#import "DMTwitterCore.h"
#import <QuartzCore/QuartzCore.h>

@interface StartViewController ()

@end

@implementation StartViewController

@synthesize facebookButton, twitterButton;

//@synthesize appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateView];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (!appDelegate.session.isOpen) {
        // create a fresh session object
        appDelegate.session = [[FBSession alloc] init];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
                // we recurse here, in order to update buttons and labels
                [self updateView];
            }];
        }
    }
    
    facebookButton.layer.cornerRadius = 3;
    facebookButton.clipsToBounds = YES;
    
    twitterButton.layer.cornerRadius = 3;
    twitterButton.clipsToBounds = YES;
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginOnemday:(id)sender
{
    LoginViewController  *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    
    [[self navigationController] pushViewController:loginViewController animated:YES];
}


// FBSample logic
// handler for button click, logs sessions in or out
- (IBAction)loginFacebook:(id)sender
{    
    NSLog(@"loginFacebook");
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    appDelegate.loggedInFlag = [NSNumber numberWithInt:1];
    
    // this button's job is to flip-flop the session from open to closed
    //if (!appDelegate.session.isOpen) {
        
   
        if (appDelegate.session.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            appDelegate.session = [[FBSession alloc] init];
        }
    
        //NSLog(@"appDelegate.session.isOpen: %c", appDelegate.session.isOpen);
        
        // if the session isn't open, let's open it now and present the login UX to the user
        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            // and here we make sure to update our UX according to the new session state
            //NSLog(@"error: %@", error);
            
            [self updateView];
        }];
    //}

}

- (IBAction)loginTwitter:(id)sender
{
    /*if ([DMTwitter shared].oauth_token_authorized) {
        // already logged, execute logout
        //[[DMTwitter shared] logout];
        //[btn_loginLogout setTitle:@"Twitter Login" forState:UIControlStateNormal];
        //[lbl_welcome setText:@"Press \"Twitter Login!\" to start!"];
        //tw_userData.text = @"";
    } else {*/
        // prompt login
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    appDelegate.loggedInFlag = [NSNumber numberWithInt:2];
    
    
    
        [[DMTwitter shared] newLoginSessionFrom:self.navigationController
                                       progress:^(DMOTwitterLoginStatus currentStatus) {
                                           NSLog(@"current status = %@",[StartViewController readableCurrentLoginStatus:currentStatus]);
                                       } completition:^(NSString *screenName, NSString *user_id, NSError *error) {
                                           
                                           if (error != nil) {
                                               NSLog(@"Twitter login failed: %@",error);
                                           } else {
                                               NSLog(@"Welcome %@!",screenName);
                                               
                                               /*[btn_loginLogout setTitle:@"Twitter Logout" forState:UIControlStateNormal];
                                               [lbl_welcome setText:[NSString stringWithFormat:@"Welcome %@!",screenName]];
                                               [tw_userData setText:@"Loading your user info..."];*/
                                               
                                               // store our auth data so we can use later in other sessions
                                               [[DMTwitter shared] saveCredentials];
                                               
                                               [[self.navigationController presentedViewController] dismissViewControllerAnimated:YES completion:^(){
                                                    [self updateView];
                                                }];
                                               
                                              
                                             
                                               
                                               /*NSLog(@"Now getting more data...");
                                               // you can use this call in order to validate your credentials
                                               // or get more user's info data
                                               [[DMTwitter shared] validateTwitterCredentialsWithCompletition:^(BOOL credentialsAreValid, NSDictionary *userData) {
                                                   if (credentialsAreValid)
                                                       [self updateView];
                                                   else
                                                       
                                               }];*/
                                           }
                                       }];
   
    
    //}
    
}



+ (NSString *) readableCurrentLoginStatus:(DMOTwitterLoginStatus) cstatus {
    switch (cstatus) {
        case DMOTwitterLoginStatus_PromptUserData:
            return @"Prompt for user data and request token to server";
        case DMOTwitterLoginStatus_RequestingToken:
            return @"Requesting token for current user's auth data...";
        case DMOTwitterLoginStatus_TokenReceived:
            return @"Token received from server";
        case DMOTwitterLoginStatus_VerifyingToken:
            return @"Verifying token...";
        case DMOTwitterLoginStatus_TokenVerified:
            return @"Token verified";
        default:
            return @"[unknown]";
    }
}


// FBSample logic
// main helper method to update the UI to reflect the current state of the session.
- (void)updateView
{
    NSLog(@"updateView !");
    // get the app delegate, so that we can reference the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        NSLog(@"Welcome to facebook session!");
        appDelegate.loggedInFlag = [NSNumber numberWithInt:1];
        [self goToMasterView];
        
    }
    else if ([DMTwitter shared].oauth_token_authorized) {
        NSLog(@"Welcome to twitter session!");
        appDelegate.loggedInFlag = [NSNumber numberWithInt:2];
        [self goToMasterView];
        
    }
    else if ([self checkEmail]) {
        NSLog(@"Welcome to email session!");
        appDelegate.loggedInFlag = [NSNumber numberWithInt:3];
        [self goToMasterView];
        
    }

}

- (void)goToMasterView
{
    UIViewController *masterController = [AppDelegate initMasterController];
    [self presentViewController:masterController animated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (bool)checkEmail
{
    NSData *saved_credentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];    
    if (saved_credentials != nil)return true;
    else return false;
}
@end
