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
#import "SignUpViewController.h"
#import "PopupError.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize txtEmail, txtPassword;

AppDelegate *appDelegate;
User *user;
NSString *loginErrorMsg;
PopupError *popupError;

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
        
        [txtEmail setText:@"prolagaev@gmail.com"];
        [txtPassword setText:@"2345671"];
        
        // add popup error
        popupError = [[PopupError alloc] initWithView:self.view];
    }
    return self;
}

- (IBAction)loginClick:(id)sender {
    @try {
        if([[txtEmail text] isEqualToString:@""]) {
            [popupError setTextAndShow:NSLocalizedString(@"Please enter Email", nil)];       
        } else if([[txtPassword text] isEqualToString:@""] ) {
            [popupError setTextAndShow:NSLocalizedString(@"Please enter Password", nil)];
        } else if([[txtPassword text] length] < 6 || ![LoginViewController validateEmail:[txtEmail text]]) {
            [popupError setTextAndShow:NSLocalizedString(@"Wrong email or password!", nil)];
        } else {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
               
                [self loginTask];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    if(user != nil){
                        [self goToMaster];
                    } else if(loginErrorMsg != nil){
                         [popupError setTextAndShow:loginErrorMsg];                      
                    } else {
                        [popupError setTextAndShow:[Request operationFailedMsg]];                        
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

-(void)goToMaster
{
    UIViewController *masterController = [AppDelegate initMasterController];
    [self presentViewController:masterController animated:YES completion:nil];
}

- (void)loginTask
{
    double startTime = [[NSDate date] timeIntervalSince1970];
    
    user = [self requestLogin];
    if(user != nil){
        [appDelegate saveCredentials:[user userId] loggedInWith:3];     
        [[UserStore get] addUser:user];
    }
    
    double stopTime = [[NSDate date] timeIntervalSince1970];
    
    double time = 2000 - (stopTime - startTime);
    
    if(time > 0) sleep(time / 1000);   
}

- (id)requestLogin
{
    Request *request = [[Request alloc] init];
    [request addStringToPostData:@"email" andValue:[txtEmail text]];
    [request addStringToPostData:@"password" andValue:[txtPassword text]];
    NSString *deviceToken = [[NSString alloc] initWithData:appDelegate.deviceToken
                                              encoding:NSUTF8StringEncoding];
    [request addStringToPostData:@"ios_device_token" andValue:deviceToken];
    
    NSDictionary *jsonData = [request send:@"auth/regular.json"];
    if(jsonData == nil) return nil;
    
    NSString *status = (NSString *) [jsonData objectForKey:@"status"];
    if([status isEqualToString: @"no_such_user"]){
        loginErrorMsg = NSLocalizedString(@"Wrong email or password!", nil);
        return nil;
    } else if([status isEqualToString: @"wrong_password"]){
        loginErrorMsg = NSLocalizedString(@"Wrong password", nil);
        return nil;
    } else if([status isEqualToString: @"ok"]){
        User *user = [[UserStore get] parseUserData: (NSDictionary*) [jsonData objectForKey: @"user"]];
        [[UserStore get] addUser:user];
        return user;
    } else {
        NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
        if(error_msg != nil) loginErrorMsg = error_msg;
        else loginErrorMsg = [Request operationFailedMsg];
        return nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if(appDelegate.loggedInFlag == 3){
        [self goToMaster];
    }
    else [txtEmail becomeFirstResponder];
}

- (IBAction)signUp:(id)sender {
    SignUpViewController  *signUpViewController = [SignUpViewController alloc];    
    [[self navigationController] pushViewController:signUpViewController animated:YES];
}

+ (bool) validateEmail:(NSString *) email{   
    NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:email options:0 range:NSMakeRange(0, [email length])];
    NSLog(@"%i", regExMatches);
    if (regExMatches == 0) {
        return NO;
    } else
        return YES;   
}

@end
