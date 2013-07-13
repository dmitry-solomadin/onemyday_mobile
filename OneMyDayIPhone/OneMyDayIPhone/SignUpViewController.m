//
//  SignUpViewController.m
//  Onemyday
//
//  Created by Admin on 6/26/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Request.h"
#import "AppDelegate.h"
#import "UserStore.h"
#import "User.h"
#import "AsyncImageView.h"
#import "YIInnerShadowView.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

@synthesize userId;

AsyncImageView *avatarView;
NSString *sex = @"not_specified";
UITextField *nameField;
UITextField *emailField;
UITextField *passField;
AppDelegate *appDelegate;
BOOL noAvatar = true;
User *user;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *buttonTitle;
    NSLog(@"userId %d", userId);
    if(userId != 0) user = [[UserStore get] findById: userId];    
    if(user == nil)buttonTitle = @"Join";
    else buttonTitle = @"Edit";
    
    UIBarButtonItem *joinButton = [[UIBarButtonItem alloc] initWithTitle:buttonTitle
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self action:@selector(join:)];
    
    [joinButton setTintColor:[UIColor colorWithRed:0.08 green:0.78 blue:0.08 alpha:0.5]];
    self.navigationItem.rightBarButtonItem = joinButton;    
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey"]];
    
    // User avatar 
    YIInnerShadowView *avatarShadowView = [[YIInnerShadowView alloc] initWithFrame: CGRectMake(10, 20, 80, 80)];
    avatarShadowView.shadowRadius = 2;
    avatarShadowView.shadowColor = [UIColor blackColor];
    avatarShadowView.shadowMask = YIInnerShadowMaskAll;
    avatarShadowView.cornerRadius = 5;
    avatarView = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 20, 80, 80)];
    avatarView.layer.cornerRadius = 5;
    avatarView.clipsToBounds = YES;
    [avatarView setBackgroundColor:[UIColor clearColor]];
    avatarView.showActivityIndicator = NO;
    if(user != nil) {
        NSURL *avatarUrl = [user extractAvatarUrlType:@"small_url"];
        if ([UserStore isAvatarEmpty:[avatarUrl absoluteString]]) {
            [avatarView setImage:[UIImage imageNamed:@"no-avatar"]];
        } else {
            [avatarView setImageURL:avatarUrl];
        }
        noAvatar = false;
    } else {
        UILabel *noAvatarTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, 80, 18)];
        [noAvatarTop setText:@"Your"];
        [noAvatarTop setBackgroundColor:[UIColor clearColor]];
        [noAvatarTop setTextAlignment:NSTextAlignmentCenter];
        [noAvatarTop setTextColor:[UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1]];
        [noAvatarTop setShadowColor:[UIColor whiteColor]];
        [noAvatarTop setShadowOffset:CGSizeMake(0, 1)];
        [noAvatarTop setFont:[UIFont boldSystemFontOfSize:15]];
        UILabel *noAvatarBottom = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 80, 18)];
        [noAvatarBottom setText:@"Avatar"];
        [noAvatarBottom setBackgroundColor:[UIColor clearColor]];
        [noAvatarBottom setTextAlignment:NSTextAlignmentCenter];
        [noAvatarBottom setTextColor:[UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1]];
        [noAvatarBottom setShadowColor:[UIColor whiteColor]];
        [noAvatarBottom setShadowOffset:CGSizeMake(0, 1)];
        [noAvatarBottom setFont:[UIFont boldSystemFontOfSize:15]];
        [avatarView setBackgroundColor:[UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1]];
        [avatarView addSubview:noAvatarTop];
        [avatarView addSubview:noAvatarBottom];
        noAvatar = true;
    }
    
    [self.view addSubview:avatarView];
    [self.view addSubview:avatarShadowView];
    [self.view bringSubviewToFront:avatarShadowView];    
    
    //Avatar hidden button
    UIButton *imageBtn = [[UIButton alloc] initWithFrame: CGRectMake(10, 20, 80, 80)];
    imageBtn.tag = 1;
    [imageBtn addTarget:self action:@selector(imageTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageBtn];
    [self.view bringSubviewToFront:imageBtn];
    
    emailField = [[UITextField alloc] initWithFrame:CGRectMake(100, 20, 210, 35)];
    [emailField setPlaceholder:@"Email"];
    [emailField setKeyboardType:UIKeyboardTypeEmailAddress];
    [emailField setFont:[UIFont systemFontOfSize:15]];
    [emailField setDelegate:self];
    emailField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    emailField.leftViewMode = UITextFieldViewModeAlways;
    UIImage *fieldBGImage = [[UIImage imageNamed:@"text_field"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    [emailField setBackground:fieldBGImage];
    if(user != nil)[emailField setText:[user email]];
    else [emailField setText:@""];
    emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:emailField];
    
    passField = [[UITextField alloc] initWithFrame:CGRectMake(100, 64, 210, 35)];
    [passField setPlaceholder:@"Password"];
    [passField setFont:[UIFont systemFontOfSize:15]];
    [passField setText:@""];
    passField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    passField.leftViewMode = UITextFieldViewModeAlways;
    [passField setBackground:fieldBGImage];
    passField.secureTextEntry = YES;
    passField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:passField];
    passField.delegate = self;
    
    nameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 110, 300, 35)];
    [nameField setPlaceholder:@"Name"];
    [nameField setFont:[UIFont systemFontOfSize:15]];
    nameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    nameField.leftViewMode = UITextFieldViewModeAlways;
    [nameField setBackground:fieldBGImage];
    if(user != nil)[nameField setText:[user name]];
    else [nameField setText:@""];
    nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:nameField];
    nameField.delegate = self;
    
    // gender switcher
    NSArray *itemArray = [NSArray arrayWithObjects: @"Male", @"Female", @"Not sure", nil];
    UISegmentedControl *genderSwitcher = [[UISegmentedControl alloc] initWithItems:itemArray];
    genderSwitcher.frame = CGRectMake(10, 155, 300, 35);
    genderSwitcher.segmentedControlStyle = UISegmentedControlStylePlain;
    genderSwitcher.selectedSegmentIndex = 0;
    [genderSwitcher addTarget:self action:@selector(genderSwitched:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:genderSwitcher];
    
    [emailField becomeFirstResponder];    
}

- (void)imageTap:(UIButton *)sender
{ 
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    avatarView.image = image;
    noAvatar = false;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)genderSwitched:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    if (selectedSegment == 0){
        sex = @"male";
    } else if (selectedSegment == 1) {
        sex = @"female";
    } else if (selectedSegment == 2) {
        sex = @"not_specified";
    }
}

- (NSDictionary *)registerTask
{
    double startTime = [[NSDate date] timeIntervalSince1970];
    
    Request *request = [[Request alloc] init];
    [request addStringToPostData:@"user[email]" andValue:[emailField text]];
    [request addStringToPostData:@"user[password]" andValue:[passField text]];
    [request addStringToPostData:@"user[gender]" andValue:sex];
    [request addStringToPostData:@"user[name]" andValue:[nameField text]];     
    if (user != nil) [request addStringToPostData:@"api_key" andValue: appDelegate.apiKey];
    if (!noAvatar) [request addImageToPostData:@"user[avatar]" andValue:avatarView.image];
    
    NSDictionary *something;
    NSString *requestString;
    if(user == nil)requestString = @"/users.json";       
    else requestString = [NSString stringWithFormat: @"/api/users/%d/update.json", [user userId]];
    
    something = [request send:requestString];
    if (something != nil) {
        NSLog(@"something %@", something);
    }
    
    double stopTime = [[NSDate date] timeIntervalSince1970];
    double time = 2000 - (stopTime - startTime);
    if(time > 0) sleep(time / 1000);
    
    return something;
}

- (void)join:(id)sender
{
    if([[emailField text] isEqualToString:@""]) {
        [appDelegate alertStatus:@"" :@"Please enter Email" ];        
    } else if([[passField text] isEqualToString:@""] ) {
        [appDelegate alertStatus:@"" :@"Please enter Password" ];
    }  else if([[nameField text] isEqualToString:@""] ) {
        [appDelegate alertStatus:@"" :@"Please enter your name" ];
    } else {        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSDictionary *something = [self registerTask];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                NSString *status = (NSString *) [something objectForKey:@"status"];
                NSString *success = (NSString *) [something objectForKey:@"success"];                
                NSDictionary *errors = (NSDictionary *) [something objectForKey:@"errors"];                        
                
                if(errors != nil){
                    for(NSString *error in errors){
                        NSMutableString *msg = [NSMutableString string];
                        
                        if([[errors objectForKey:error] isKindOfClass:[NSArray class]]){
                            NSArray *errorMSg = [errors objectForKey:error];                            
                            
                            for(int i = 0; i < [errorMSg count]; i++){
                                [msg appendString:[errorMSg objectAtIndex:i]];
                            }
                        } else if([[errors objectForKey:error] isKindOfClass:[NSString class]]){
                            msg = [errors objectForKey:error];
                        }
                        
                        [appDelegate alertStatus:@"" : msg];
                        
                        break;
                    }
                    
                } else if(status != nil && [status isEqualToString: @"ok"]){
                    User *newUser = [[UserStore get] parseUserData: (NSDictionary*) [something objectForKey: @"user"]];
                    [[UserStore get] addUser:newUser];
                    [appDelegate saveCredentials:[newUser userId] loggedInWith:3];
                    appDelegate.loggedInFlag = 3;                   
                    
                    //[self dismissViewControllerAnimated:YES completion:nil];
                    
                    UIViewController *masterController = [AppDelegate initMasterController];
                    [self presentViewController:masterController animated:YES completion:nil];
                    
                } else if(success != nil && success) {
                    
                     /*User *newUser = [[UserStore get] parseUserData: (NSDictionary*) [something objectForKey: @"user"]];
                    
                     [user setAvatarUrls:[newUser avatarUrls]];
                     [user setEmail:[newUser email]];
                     [user setGender:[newUser gender]];
                     [user setName:[newUser name]];
                    
                    NSLog(@"user %@ %@ %@ ",[user email],[user gender],  [user name]);*/
                    
                    /*self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:4];*/
                    
                     [self dismissViewControllerAnimated:YES completion:nil];
                    
                    //UIViewController *masterController = [AppDelegate initMasterController];
                    //[self presentViewController:masterController animated:YES completion:nil];
                    
                } else {
                    [appDelegate alertStatus:@"" :[Request operationFailedMsg]];
                }
                
            });
        });
    }
}

@end
