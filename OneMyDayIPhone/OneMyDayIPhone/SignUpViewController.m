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
#import "PopupError.h"
#import "LoginViewController.h"
#import "WebViewViewController.h"

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
PopupError *popupError;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 0, 320, 320)];
    [[self view] addSubview:scrollView];
    
    // add popup error
    popupError = [[PopupError alloc] initWithView:scrollView];
    
    NSString *buttonTitle;
    NSLog(@"userId %d", userId);
    if(userId != 0) user = [[UserStore get] findById: userId];    
    if(user == nil)buttonTitle = NSLocalizedString(@"Join", nil);
    else buttonTitle = NSLocalizedString(@"Save", nil);
    
    UIBarButtonItem *joinButton = [[UIBarButtonItem alloc] initWithTitle:buttonTitle
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self action:@selector(join:)];
    
    [joinButton setTintColor:[UIColor colorWithRed:0.08 green:0.78 blue:0.08 alpha:0.5]];
    self.navigationItem.rightBarButtonItem = joinButton;    
    scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey"]];
    
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
        [noAvatarTop setText:NSLocalizedString(@"Your", nil)];
        [noAvatarTop setBackgroundColor:[UIColor clearColor]];
        [noAvatarTop setTextAlignment:NSTextAlignmentCenter];
        [noAvatarTop setTextColor:[UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1]];
        [noAvatarTop setShadowColor:[UIColor whiteColor]];
        [noAvatarTop setShadowOffset:CGSizeMake(0, 1)];
        [noAvatarTop setFont:[UIFont boldSystemFontOfSize:15]];
        UILabel *noAvatarBottom = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 80, 18)];
        [noAvatarBottom setText:NSLocalizedString(@"Avatar", nil)];
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
    
    [scrollView addSubview:avatarView];
    [scrollView addSubview:avatarShadowView];
    [scrollView bringSubviewToFront:avatarShadowView];
    
    //Avatar hidden button
    UIButton *imageBtn = [[UIButton alloc] initWithFrame: CGRectMake(10, 20, 80, 80)];
    imageBtn.tag = 1;
    [imageBtn addTarget:self action:@selector(imageTap:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:imageBtn];
    [scrollView bringSubviewToFront:imageBtn];
    
    emailField = [[UITextField alloc] initWithFrame:CGRectMake(100, 20, 210, 35)];
    [emailField setPlaceholder:NSLocalizedString(@"Email", nil)];
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
    [scrollView addSubview:emailField];
    
    passField = [[UITextField alloc] initWithFrame:CGRectMake(100, 64, 210, 35)];
    [passField setPlaceholder:NSLocalizedString(@"Password", nil)];
    [passField setFont:[UIFont systemFontOfSize:15]];
    [passField setText:@""];
    passField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    passField.leftViewMode = UITextFieldViewModeAlways;
    [passField setBackground:fieldBGImage];
    passField.secureTextEntry = YES;
    passField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [scrollView addSubview:passField];
    passField.delegate = self;
    
    nameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 110, 300, 35)];
    [nameField setPlaceholder:NSLocalizedString(@"Name", nil)];
    [nameField setFont:[UIFont systemFontOfSize:15]];
    nameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    nameField.leftViewMode = UITextFieldViewModeAlways;
    [nameField setBackground:fieldBGImage];
    if(user != nil)[nameField setText:[user name]];
    else [nameField setText:@""];
    nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [scrollView addSubview:nameField];
    nameField.delegate = self;
    
    // gender switcher
    NSArray *itemArray = [NSArray arrayWithObjects: NSLocalizedString(@"Male", nil), NSLocalizedString(@"Female", nil), NSLocalizedString(@"Not sure", nil), nil];
    UISegmentedControl *genderSwitcher = [[UISegmentedControl alloc] initWithItems:itemArray];
    genderSwitcher.frame = CGRectMake(10, 155, 300, 35);
    genderSwitcher.segmentedControlStyle = UISegmentedControlStylePlain;
    genderSwitcher.selectedSegmentIndex = 0;
    [genderSwitcher addTarget:self action:@selector(genderSwitched:) forControlEvents:UIControlEventValueChanged];    
    [scrollView addSubview:genderSwitcher];
    
    // agree to terms text
    UITextView *termsTextLabel = [[UITextView alloc] initWithFrame:CGRectMake(10, 185, 300, 40)];
    [termsTextLabel setBackgroundColor:[UIColor clearColor]];
    termsTextLabel.contentInset = UIEdgeInsetsMake(0, -8, 0, 0);
    [termsTextLabel setScrollEnabled:NO];
    [termsTextLabel setEditable:NO];
    [termsTextLabel setTextColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1]];
    NSString *termsText = NSLocalizedString(@"By signing up you are indicating that you have read and agree to Terms of use", nil);
    NSMutableAttributedString *termsTextAttr = [[NSMutableAttributedString alloc] initWithString:termsText];
    NSRange termsRange = [termsText rangeOfString:NSLocalizedString(@"Terms of use1", nil)];
    [termsTextAttr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.4 green:0.4 blue:0.55 alpha:1] range:termsRange];
    termsTextLabel.attributedText = termsTextAttr;
    termsTextLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
    termsTextLabel.layer.shadowOffset = CGSizeMake(0, 1.0f);
    termsTextLabel.layer.shadowOpacity = 1.0f;
    termsTextLabel.layer.shadowRadius = 1.0f;
    [scrollView addSubview:termsTextLabel];
    
    UIButton *termsButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 185, 300, 40)];
    [termsButton addTarget:self action:@selector(termsPressed:) forControlEvents:UIControlEventTouchDown];    
    [scrollView addSubview:termsButton];
    
    [scrollView setContentSize:CGSizeMake(320, 350)];
    
    [emailField becomeFirstResponder];
}

- (void)termsPressed:(id)sender
{
    WebViewViewController *webViewViewController = [[WebViewViewController alloc] initWithNibName:nil bundle:nil];
    [webViewViewController setUrl:@"http://onemyday.co/terms"];
    [[self navigationController] pushViewController:webViewViewController animated:YES];
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
    
    NSDictionary *jsonData;
    NSString *requestString;
    if(user == nil)requestString = @"/users.json";       
    else requestString = [NSString stringWithFormat: @"/api/users/%d/update.json", [user userId]];
    
    jsonData = [request send:requestString];
    
    double stopTime = [[NSDate date] timeIntervalSince1970];
    double time = 2000 - (stopTime - startTime);
    if(time > 0) sleep(time / 1000);
    
    return jsonData;
}

- (void)join:(id)sender
{
    if([[emailField text] isEqualToString:@""]) {
        [popupError setTextAndShow:NSLocalizedString(@"Please enter Email", nil)];  
    } else if([[nameField text] isEqualToString:@""]) {
        [popupError setTextAndShow:NSLocalizedString(@"Please enter your name", nil)];
    } else if(![[passField text] isEqualToString:@""] && [[passField text] length] < 6) {
        [popupError setTextAndShow:NSLocalizedString(@"Password should have more than 6 characters", nil)];
    } else if (![LoginViewController validateEmail:[emailField text]]) {
        [popupError setTextAndShow:NSLocalizedString(@"Please enter valid email", nil)];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSDictionary *jsonData = [self registerTask];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                NSString *status = (NSString *) [jsonData objectForKey:@"status"];
                NSString *success = (NSString *) [jsonData objectForKey:@"success"];                
                NSDictionary *errors = (NSDictionary *) [jsonData objectForKey:@"errors"];                        
                
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
                       
                        [popupError setTextAndShow:msg];                        
                        break;
                    }
                    
                } else if(status != nil && [status isEqualToString: @"ok"]){
                    
                    User *newUser = [[UserStore get] parseUserData: (NSDictionary*) [jsonData objectForKey: @"user"]];
                    [[UserStore get] addOrReplaceUser:newUser];
                    
                    if(user == nil){
                        
                        [appDelegate saveCredentials:[newUser userId] loggedInWith:3];
                        appDelegate.loggedInFlag = 3;
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        
                        /*UIViewController *masterController = [AppDelegate initMasterController];
                        [self presentViewController:masterController animated:YES completion:nil];*/
                    }
                    
                } else {                  
                    [popupError setTextAndShow:[Request operationFailedMsg]];
                }
                
            });
        });
    }
}


@end
