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


@interface StartViewController ()

@end

@implementation StartViewController

@synthesize facebookButton, twitterButton;

AppDelegate *appDelegate;
UITextField *emailTextField;

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
    
    appDelegate = [[UIApplication sharedApplication]delegate];
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
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    facebookButton.layer.cornerRadius = 3;
    facebookButton.clipsToBounds = YES;
    
    twitterButton.layer.cornerRadius = 3;
    twitterButton.clipsToBounds = YES;
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
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
            /*NSArray *permissions = [[NSArray alloc] initWithObjects:
                                    @"user_location", // you need to have this permission
                                    @"email", // to be approved
                                    nil];
            appDelegate.session = [appDelegate.session initWithPermissions:permissions];*/
        }
   
    
    
        //NSLog(@"appDelegate.session.isOpen: %c", appDelegate.session.isOpen);
        
        // if the session isn't open, let's open it now and present the login UX to the user
        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            // and here we make sure to update our UX according to the new session state
            //NSLog(@"error: %@", error);
            if (!error) {
            
                [FBSession setActiveSession: appDelegate.session];
                [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                    if (!error) {                                       
                    
                        NSString *email = [user objectForKey:@"email"];
                        if(email != nil){
                            [self socialAuth:user.id withProvider:@"facebook" andToken:[NSString stringWithFormat:@"%@",[appDelegate.session accessTokenData]] andSecret:nil AndEmail:email  andFirstName:user.first_name andLastName:user.last_name andNickName:nil];
                        } else {
                            NSArray *permissions = [[NSArray alloc] initWithObjects:
                                                @"user_location", // you need to have this permission
                                                @"email", // to be approved
                                                nil];
                            [FBSession openActiveSessionWithReadPermissions:permissions
                                                           allowLoginUI:true
                                                      completionHandler:^(FBSession *session,
                                                                          FBSessionState state,
                                                                          NSError *error) {
                                                          
                                                          NSLog(@"error: %@", error);
                                                          //appDelegate.session = session;
                                                          [FBSession setActiveSession: appDelegate.session];
                                                          [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                                                              if (!error) {
                                                                  
                                                                  NSLog(@"!!!!!!!!!!!!!!user.name %@", user.name);
                                                                  NSLog(@"user.name %@", user.username);
                                                                  NSLog(@"[user objectForKey:%@", [user objectForKey:@"email"]);
                                                                  NSLog(@"[appDelegate.session accessTokenData]; %@", [appDelegate.session accessTokenData]);
                                                                  
                                                                  NSString *email = [user objectForKey:@"email"];
                                                                  if(email != nil)[self socialAuth:user.id withProvider:@"facebook" andToken:[NSString stringWithFormat:@"%@",[appDelegate.session accessTokenData]] andSecret:nil AndEmail:email  andFirstName:user.first_name andLastName:user.last_name andNickName:nil];
                                                                  
                                                              } else NSLog(@"error %@", error);
                                                          }];
                                                          
                                                          
                                                          
                                                      }];
                    }
                    
                } else NSLog(@"error %@", error);
            }];

           } else NSLog(@"error %@", error);  
            
            

            
            
            
            /*[FBSession setActiveSession: appDelegate.session];
            [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                if (!error) {
                    NSLog(@"!!!!!!!!!!!!!!user.name %@", user.name);
                    NSLog(@"user.name %@", user.username);
                    NSLog(@"[user objectForKey:%@", [user objectForKey:@"email"]);
                    NSLog(@"[appDelegate.session accessTokenData]; %@", [appDelegate.session accessTokenData]);
                    
                    [self socialAuth:user.id withProvider:@"facebook" andToken:[NSString stringWithFormat:@"%@",[appDelegate.session accessTokenData]] andSecret:nil AndEmail:[user objectForKey:@"email"]   andFirstName:user.first_name andLastName:user.last_name andNickName:nil];
                    
                } else NSLog(@"error %@", error);
            }];*/
            
            
            
            //[self updateView];
    
    
    
    
    
    
    
        }];
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
                                               
                                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter your email:" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                                               alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                                               emailTextField = [alertView textFieldAtIndex:0];
                                               [alertView show];
                                               
                                               
                                               
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
    //NSLog(@"updateView !");
    // get the app delegate, so that we can reference the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        NSLog(@"Welcome to facebook session!");
         
        /*NSArray *permissions = [NSArray arrayWithObjects:@"email", nil];
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session,
           FBSessionState state, NSError *error) {
             
             //[self sessionStateChanged:session state:state error:error];
         }];*/
        [FBSession setActiveSession: appDelegate.session];
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
            if (!error) {                
                NSLog(@"user.name %@", user.name);
                NSLog(@"user.name %@", user.username);
                NSLog(@"[user objectForKey:%@", [user objectForKey:@"email"]);
                NSLog(@"[appDelegate.session accessTokenData]; %@", [appDelegate.session accessTokenData]);
            } else NSLog(@"error %@", error);
        }];
        appDelegate.loggedInFlag = [NSNumber numberWithInt:1];
        [self goToMasterView];
        
    }
    else if ([DMTwitter shared].oauth_token_authorized) {
        NSLog(@"Welcome to twitter session!");
        NSLog(@"[DMTwitter shared] oauth_token_secret%@", [DMTwitter shared].oauth_token_secret);
        NSLog(@"[DMTwitter shared] oauth_token%@", [DMTwitter shared].oauth_token);
        appDelegate.loggedInFlag = [NSNumber numberWithInt:2];
        [self goToMasterView];
        
    }
    else if ([appDelegate checkEmail]) {
        NSLog(@"Welcome to email session!");
        appDelegate.loggedInFlag = [NSNumber numberWithInt:3];
        [self goToMasterView];
        
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
    Request *request = [[Request alloc] init]; 
    /*api_key — (required)
    omniauth[uid] — uid (required)
    omniauth[provider] — social provider: 'facebook' or 'twitter' (required)
    omniauth[credentials][token] — oauth token (required)
    omniauth[credentials][secret] — oauth secret (required for twitter)
    omniauth[info][email] — User email (required)
    omniauth[info][image] — User profile image (required)
    omniauth[info][first_name] — User first name, will transform into name (optional)
    omniauth[info][last_name] — User last name, will transform into name (optional)
    omniauth[info][nickname] — Us*/
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
    //[request addStringToPostData:@"existing_user_id" andValue:[NSString stringWithFormat:@"%d",9]];
    
     NSLog(@"email:%@", email);
    
    NSDictionary *jsonData;  
    
    jsonData = [request send:@"/api/sessions/social_auth.json"];
    
    if(jsonData != nil){
        
        NSLog(@"something %@", jsonData);
        
        //NSString *message = [jsonData objectForKey:@"message"];
        //NSLog(@"message %@", message);
        
        NSString *status = [jsonData objectForKey:@"status"];
       
        if([status isEqualToString: @"ok"]){
            
            if([provider isEqualToString:@"twitter"]){
                // store our auth data so we can use later in other sessions
                [[DMTwitter shared] saveCredentials];
                //appDelegate.loggedInFlag = [NSNumber numberWithInt:2];
            } //else appDelegate.loggedInFlag = [NSNumber numberWithInt:1]; //logged with faceboock
            
            User *user = [[UserStore get] parseUserData: (NSDictionary*) [jsonData objectForKey: @"user"]];
            [[UserStore get] addUser:user];            
            [appDelegate setCurrentUserId:[user userId]];
            
            [self updateView];
        }
        
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        NSLog(@"The cancel button was clicked for alertView");
    } else {
        [self socialAuth:[DMTwitter shared].user_id withProvider:@"twitter" andToken:[DMTwitter shared].oauth_token andSecret:[DMTwitter shared].oauth_token_secret AndEmail:[emailTextField text]  andFirstName:nil andLastName:nil  andNickName:[DMTwitter shared].screen_name];
    }
    // else do your stuff for the rest of the buttons (firstOtherButtonIndex, secondOtherButtonIndex, etc)
}


@end
