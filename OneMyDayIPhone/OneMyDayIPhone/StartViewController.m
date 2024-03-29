//
//  StartViewController.m
//  OneMyDayIPhone
//
//  Created by Admin on 4/10/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "StartViewController.h"
#import "LoginViewController.h"
#import "Request.h"
#import "DMOAuthTwitter.h"
#import "DMTwitterCore.h"
#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "UserStore.h"
#import <Accounts/Accounts.h> 


@interface StartViewController ()
{
    BOOL firstTime;
}

@end

@implementation StartViewController

@synthesize facebookButton, twitterButton;

AppDelegate *appDelegate;
UITextField *emailTextField;
NSArray *permissions;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self updateView];
    
    appDelegate = [[UIApplication sharedApplication]delegate];
    if (!appDelegate.session.isOpen) {
        // create a fresh session object
       permissions = [[NSArray alloc] initWithObjects:                                
                                @"email", // to be approved
                                nil];
        appDelegate.session = [[FBSession alloc] initWithPermissions:permissions];        
        
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
}

- (void)viewWillAppear:(BOOL)animated
{
    facebookButton.layer.cornerRadius = 3;
    facebookButton.clipsToBounds = YES;
    
    twitterButton.layer.cornerRadius = 3;
    twitterButton.clipsToBounds = YES;
    
    if (firstTime == true) {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    } else {
        [[self navigationController] setNavigationBarHidden:YES animated:NO];
    }
    
    firstTime = true;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (IBAction)loginOnemday:(id)sender
{
    LoginViewController *loginViewController = [[LoginViewController alloc]
                                                initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
 
    [[self navigationController] pushViewController:loginViewController animated:YES];
} 



// FBSample logic
// handler for button click, logs sessions in or out
- (IBAction)loginFacebook:(id)sender
{    
    NSLog(@"loginFacebook");    
  
    appDelegate.loggedInFlag = 1;
    
    [self fbRenewCredentials];       
    
}

-(void)openFBSession{
    
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      if (!error) {
                                          
                                          switch (status) {
                                                  
                                              case FBSessionStateOpen:
                                              {
                                                  appDelegate.session = session;
                                                  
                                                  [self prepareFBAthorizationRequest];
                                              
                                                  break;
                                              }
                                              case FBSessionStateClosed:
                                                  //need to handle
                                                  NSLog(@"status  FBSessionStateClosed");
                                                  break;
                                              case FBSessionStateClosedLoginFailed:
                                                  //need to handle
                                                   NSLog(@"status FBSessionStateClosedLoginFailed");
                                                  break;
                                              default:
                                                  break;
                                          }
                                          
                                      } else NSLog(@"error 2 %@", error);
                                      
                                  }];
}

-(void)fbRenewCredentials
{
    [FBSession renewSystemCredentials:^(ACAccountCredentialRenewResult result,
                                         NSError *error)
      {
          [self openFBSession]; 
          /*if (result == ACAccountCredentialRenewResultFailed ||
              result == ACAccountCredentialRenewResultRejected)
          {
              NSLog(NSLocalizedString(@"You may need to re-enter your Facebook password in the iPhone Settings App.\n", nil));
          }
          else
          {
              // attempt opening a session again  (after they have updated their account
              // settings I end up here)
              
              [self openFBSession];  // Performs openActiveSessionWithReadPermissions,
              // but this time around the token issued should be good.
          }*/
      }];
}

-(void) prepareFBAthorizationRequest{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            
            NSString *email = [user objectForKey:@"email"];
            
            NSLog(@"!!!!!!!!!!!!!!user.name %@", user.name);
            NSLog(@"username %@", user.username);
            NSLog(@"[user objectForKey:%@", [user objectForKey:@"email"]);
            
            [self socialAuth:user.id withProvider:@"facebook" andToken:[NSString stringWithFormat:@"%@",[appDelegate.session accessTokenData]] andSecret:nil AndEmail:email  andFirstName:user.first_name andLastName:user.last_name andNickName:nil];
            
            
        } else NSLog(@"error 1 %@", error);
        
    }];
}

- (IBAction)loginTwitter:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    appDelegate.loggedInFlag = 2;
    
    [[DMTwitter shared] newLoginSessionFrom:self.navigationController
                                   progress:^(DMOTwitterLoginStatus currentStatus) {
                                       NSLog(@"current status = %@",[StartViewController readableCurrentLoginStatus:currentStatus]);
                                   } completition:^(NSString *screenName, NSString *user_id, NSError *error) {
                                       if (error != nil) {
                                           NSLog(@"Twitter login failed: %@",error);
                                       } else {
                                           NSLog(@"Welcome %@!",screenName);
                                           NSLog(@"user_id %@!",user_id);
                                           
                                           NSString *email = [NSString stringWithFormat:@"twitter_%@@onemyday.co", user_id];
                                                                                      
                                           [self socialAuth:[DMTwitter shared].user_id withProvider:@"twitter" andToken:[DMTwitter shared].oauth_token andSecret:[DMTwitter shared].oauth_token_secret AndEmail:email  andFirstName:nil andLastName:nil  andNickName:[DMTwitter shared].screen_name];
                                       }
                                      
                                   }];
    
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
    // get the app delegate, so that we can reference the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    if(appDelegate.loggedInFlag == 0) [appDelegate checkAuthorization];

    if(appDelegate.loggedInFlag != 0){
        if (appDelegate.loggedInFlag == 1 && appDelegate.session.isOpen) {
            NSLog(@"Welcome to facebook session!");            
         
            /*[FBSession setActiveSession: appDelegate.session];
            [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                if (!error) {
                    NSLog(@"user.name %@", user.name);
                    NSLog(@"user.name %@", user.username);
                    NSLog(@"[user objectForKey:%@", [user objectForKey:@"email"]);
                    NSLog(@"[appDelegate.session accessTokenData]; %@", [appDelegate.session accessTokenData]);
                } else NSLog(@"error %@", error);
            }];*/
            //appDelegate.loggedInFlag = [NSNumber numberWithInt:1];
            [self goToMasterView];
        } else if (appDelegate.loggedInFlag == 2 && [DMTwitter shared].oauth_token_authorized) {
            NSLog(@"Welcome to twitter session!");
            NSLog(@"[DMTwitter shared] oauth_token_secret%@", [DMTwitter shared].oauth_token_secret);
            NSLog(@"[DMTwitter shared] oauth_token%@", [DMTwitter shared].oauth_token);
            //appDelegate.loggedInFlag = [NSNumber numberWithInt:2];
            [self goToMasterView];
        } else if (appDelegate.loggedInFlag == 3) {
            NSLog(@"Welcome to email session!");
            //appDelegate.loggedInFlag = [NSNumber numberWithInt:3];
            [self goToMasterView];
            
        }
    }

}

- (void)goToMasterView
{
    UIViewController *masterController = [AppDelegate initMasterController];
    [self presentViewController:masterController animated:NO completion:nil];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)socialAuth:(NSString *)uid withProvider:(NSString *)provider andToken:(NSString *)token andSecret:(NSString *)secret AndEmail:(NSString *)email andFirstName:(NSString *)firstName andLastName:(NSString *)lastName andNickName:(NSString *)nickame
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        double startTime = [[NSDate date] timeIntervalSince1970];    
        
        Request *request = [[Request alloc] init];
        [request addStringToPostData:@"omniauth[info][image]" andValue: @"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS0s8HhPj8boXWYuyXedcz6g9MP2TNeOqKKDvrv5Fc4YPiwkWw4iA"];
        [request addStringToPostData:@"api_key" andValue: appDelegate.apiKey];
        [request addStringToPostData:@"omniauth[uid]" andValue: uid];
        [request addStringToPostData:@"omniauth[provider]" andValue: provider];
        [request addStringToPostData:@"omniauth[credentials][token]" andValue:token];
        if(secret != nil)[request addStringToPostData:@"omniauth[credentials][secret]" andValue:secret];
        [request addStringToPostData:@"omniauth[info][email]" andValue: email];
        if(firstName != nil)[request addStringToPostData:@"omniauth[info][first_name]" andValue: firstName];
        if(lastName != nil)[request addStringToPostData:@"omniauth[info][last_name]" andValue: lastName];
        if(nickame != nil)[request addStringToPostData:@"omniauth[info][nickname]" andValue: nickame];
        [request addStringToPostData:@"ios_device_token" andValue:appDelegate.deviceToken];
        //[request addStringToPostData:@"existing_user_id" andValue:[NSString stringWithFormat:@"%d",9]];
        
        NSDictionary *jsonData = [request send:@"/api/sessions/social_auth.json"];
        
        double stopTime = [[NSDate date] timeIntervalSince1970];
        
        double time = 2000 - (stopTime - startTime);
        
        if(time > 0) sleep(time / 1000);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if(jsonData != nil) {
                NSString *status = [jsonData objectForKey:@"status"];
                
                if([status isEqualToString: @"ok"]) {
                    [UIApplication sharedApplication].applicationIconBadgeNumber = [[jsonData objectForKey:@"unseen_activities_count"] intValue];
                    User *user = [[UserStore get] parseUserData: (NSDictionary*) [jsonData objectForKey:@"user"]];
                    [[UserStore get] addUser:user];
                    if([provider isEqualToString:@"twitter"]){
                        // store our auth data so we can use later in other sessions
                        [[DMTwitter shared] saveCredentials];
                        [appDelegate saveCredentials:[user userId] loggedInWith:2];
                        /*[[self.navigationController presentedViewController] dismissViewControllerAnimated:YES completion:^(){
                            [self updateView];
                        }];*/
                        [self updateView];
                    } else {
                        [appDelegate saveCredentials:[user userId] loggedInWith:1]; //logged with faceboock
                        [self updateView];
                    }  
                }
            }
        });
    });
}

/*- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
 
    if (buttonIndex == [alertView cancelButtonIndex]) {
        NSLog(@"The cancel button was clicked for alertView");
    } else {
        [self socialAuth:[DMTwitter shared].user_id withProvider:@"twitter" andToken:[DMTwitter shared].oauth_token andSecret:[DMTwitter shared].oauth_token_secret AndEmail:[emailTextField text]  andFirstName:nil andLastName:nil  andNickName:[DMTwitter shared].screen_name];
    }
    // else do your stuff for the rest of the buttons (firstOtherButtonIndex, secondOtherButtonIndex, etc)
}*/


@end
