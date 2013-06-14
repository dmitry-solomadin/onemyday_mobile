//
//  AppDelegate.m
//  OneMyDayIPhone
//
//  Created by Admin on 2/16/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "StartViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import "DMTwitterCore.h"
#import "MasterViewController.h"

#import "MBProgressHUD.h"

@class ExploreViewController;

@implementation AppDelegate

@synthesize session;
@synthesize loggedInFlag;

int currentUserId;

NSString *apiKey = @"75c5e6875c4e6931943b88fe5941470b";

+ (UIViewController *)initMasterController
{
    MasterViewController *mvc = [[MasterViewController alloc] init];
    return mvc;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"navbar_bg"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1]];
    
    UIImage* tabBarBackground = [UIImage imageNamed:@"tabbar_bg"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    //[[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbar_selected.png"]];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:0.8 green:0.1 blue:0 alpha:1]];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    StartViewController *svc = [[StartViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:svc];
    
    /*if (session.isOpen) {
        NSLog(@"Welcome to facebook session!");
        loggedInFlag = [NSNumber numberWithInt:1];
        [self goToMasterView:navController];        
    }
    else if ([DMTwitter shared].oauth_token_authorized) {
        NSLog(@"Welcome to twitter session!");
        loggedInFlag = [NSNumber numberWithInt:2];
        [self goToMasterView:navController];        
    }
    else if ([self checkEmail]) {
        NSLog(@"Welcome to email session!");
        loggedInFlag = [NSNumber numberWithInt:3];
        [self goToMasterView:navController];        
    }
    else {
        loggedInFlag = [NSNumber numberWithInt:0];
    }*/
        
    [[self window] setRootViewController:navController];    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)goToMasterView : (UINavigationController *)navController
{    
    UIViewController *masterController = [AppDelegate initMasterController];
    //masterController.modalPresentationStyle = UIModalPresentationFormSheet;
    //masterController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [navController  presentViewController:masterController animated:NO completion:nil];     
}



// FBSample logic
// The native facebook application transitions back to an authenticating application when the user
// chooses to either log in, or cancel. The url passed to this method contains the token in the
// case of a successful login. By passing the url to the handleOpenURL method of a session object
// the session object can parse the URL, and capture the token for use by the rest of the authenticating
// application; the return value of handleOpenURL indicates whether or not the URL was handled by the
// session object, and does not reflect whether or not the login was successful; the session object's
// state, as well as its arguments passed to the state completion handler indicate whether the login
// was successful; note that if the session is nil or closed when handleOpenURL is called, the expression
// will be boolean NO, meaning the URL was not handled by the authenticating application
- (BOOL)application:(UIApplication *)application openURL:(NSURL *) url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSLog(@"loggedInFlag  %@!",loggedInFlag);
    // attempt to extract a token from the url
    if([loggedInFlag intValue]==1)return [self.session handleOpenURL:url];
    else if([loggedInFlag intValue]==2)return [[DMTwitter shared].currentLoginController handleTokenRequestResponseURL:url];
    else return [self.session handleOpenURL:url];
}



// FBSample logic
// Whether it is in applicationWillTerminate, in applicationDidEnterBackground, or in some other part
// of your application, it is important that you close an active session when it is no longer useful
// to your application; if a session is not properly closed, a retain cycle may occur between the block
// and an object that holds a reference to the session object; close releases the handler, breaking any
// inadvertant retain cycles
- (void)applicationWillTerminate:(UIApplication *)application {
    // FBSample logic
    // if the app is going away, we close the session if it is open
    // this is a good idea because things may be hanging off the session, that need
    // releasing (completion block, etc.) and other components in the app may be awaiting
    // close notification in order to do cleanup
    [self.session close];
}
// FBSample logic
// It is possible for the user to switch back to your application, from the native Facebook application,
// when the user is part-way through a login; You can check for the FBSessionStateCreatedOpenening
// state in applicationDidBecomeActive, to identify this situation and close the session; a more sophisticated
// application may choose to notify the user that they switched away from the Facebook application without
// completely logging in
- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
}

- (bool) checkEmail
{
    NSData *saved_credentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    if (saved_credentials != nil){          
        currentUserId = [[NSKeyedUnarchiver unarchiveObjectWithData: saved_credentials] intValue];
        return true;
    }
    else return false;
}

- (void) alertStatus:(NSString *)msg :(NSString *) title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (NSString *) apiKey
{
    return apiKey;
}

- (int) currentUserId
{
    return currentUserId;
}

- (void) setCurrentUserId:(int)_currentUserId
{
    currentUserId = _currentUserId;
}

@end
