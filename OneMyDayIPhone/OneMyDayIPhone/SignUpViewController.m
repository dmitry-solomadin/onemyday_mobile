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

@interface SignUpViewController ()

@end

@implementation SignUpViewController

@synthesize userId;

AsyncImageView *avatarView;
UILabel *maleLabel;
UILabel *femaleLabel;
UILabel *notSpecifiedLabel;
NSString *sex = @"not_specified";
UITextField *nameField;
UITextField *emailField;
UITextField *passField;
AppDelegate *appDelegate;
UIImage *blankImage;
User *user;

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
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *buttonTitle;
    NSLog(@"userId %d", userId);
    if(userId != 0) user = [[UserStore get] findById: userId];    
    if(user == nil)buttonTitle = @"Join";
    else buttonTitle = @"Edit";
    
    UIBarButtonItem *joinButton = [[UIBarButtonItem alloc] initWithTitle:buttonTitle
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self action:@selector(join:)];
    
    [joinButton setTintColor:[UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1.0]];
    self.navigationItem.rightBarButtonItem = joinButton;
    
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey"]];
    
    
    
    // User avatar  
    avatarView = [[AsyncImageView alloc]  initWithFrame: CGRectMake(20, 20, 80, 80)];
    blankImage = [UIImage imageNamed:@"blankPhoto.png"];
    if(user != nil) {        
        NSURL *avatarUrl = [user extractAvatarUrlType:@"small_url"];
        if ([UserStore isAvatarEmpty:[avatarUrl absoluteString]]) {
            [avatarView setImage:[UIImage imageNamed:@"no-avatar"]];
        } else {
            [avatarView setImageURL:avatarUrl];
        }
    }
    else [avatarView setImage:blankImage];
        
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *path;

    path = [UIBezierPath bezierPathWithRoundedRect: avatarView.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){10.0, 10.}]; 
  
    maskLayer.path = path.CGPath;
    
    avatarView.layer.mask = maskLayer;
    
    // Make a transparent, stroked layer which will dispay the stroke.
    CAShapeLayer *strokeLayer = [CAShapeLayer layer];
    strokeLayer.path = path.CGPath;
    strokeLayer.fillColor = [UIColor clearColor].CGColor;
    strokeLayer.strokeColor = [[UIColor blackColor] CGColor];
    strokeLayer.lineWidth = 3;
    [strokeLayer setLineDashPattern: [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
      [NSNumber numberWithInt:5], nil]];
    
    // Transparent view that will contain the stroke layer
    UIView *strokeView = [[UIView alloc] initWithFrame:avatarView.bounds];
    strokeView.userInteractionEnabled = NO; // in case your container view contains controls
    [strokeView.layer addSublayer:strokeLayer];
    
    [avatarView addSubview:strokeView];    
       
    [self.view addSubview:avatarView];
    
    //Avatar hidden button
    UIButton *imageBtn = [[UIButton alloc] initWithFrame: CGRectMake(20, 20, 80, 80)];
    imageBtn.tag = 1;
    [imageBtn addTarget:self action:@selector(imageTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageBtn];
    [self.view bringSubviewToFront:imageBtn];
    
    emailField = [[UITextField alloc] init];
    emailField.clipsToBounds = YES;
    emailField.tag = 1;
    emailField.layer.borderColor = [[UIColor blackColor] CGColor];
    emailField.layer.borderWidth = 2;
    [emailField setPlaceholder:@"Email"];
    if(user != nil)[emailField setText:[user email]];
    else [emailField setText:@""];
    emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //textField.textAlignment = UITextAlignmentLeft;
    [emailField setKeyboardAppearance:UIKeyboardAppearanceAlert];
    [emailField setTextColor:[UIColor blackColor]];
    [emailField setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:emailField];
    emailField.frame = CGRectMake(120, 20 , 180, 35);
    emailField.delegate = self;
    emailField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);    
    
    passField = [[UITextField alloc] init];
    passField.clipsToBounds = YES;
    passField.tag = 1;  
    passField.layer.borderColor = [[UIColor blackColor] CGColor];
    passField.layer.borderWidth = 2;
    [passField setPlaceholder:@"Password"];
    [passField setText:@""];
    passField.secureTextEntry = YES;
    passField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  
    [passField setKeyboardAppearance:UIKeyboardAppearanceAlert];
    [passField setTextColor:[UIColor blackColor]];
    [passField setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:passField];
    passField.frame = CGRectMake(120, 64 , 180, 35);
    passField.delegate = self;
    passField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    nameField = [[UITextField alloc] init];
    nameField.clipsToBounds = YES;
    nameField.tag = 1;
    //textField.layer.cornerRadius = 4.0;
    nameField.layer.borderColor = [[UIColor blackColor] CGColor];
    nameField.layer.borderWidth = 2;
    //textField.Bounds = [self textRectForBounds:textField.bounds];
    [nameField setPlaceholder:@"Name"];
    if(user != nil)[nameField setText:[user name]];
    else [nameField setText:@""];
    nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //textField.textAlignment = UITextAlignmentLeft;
    [nameField setKeyboardAppearance:UIKeyboardAppearanceAlert];
    [nameField setTextColor:[UIColor blackColor]];
    [nameField setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:nameField];
    nameField.frame = CGRectMake(20, 110 , 280, 35);
    nameField.delegate = self;
    nameField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    UITextView *containerView = [[UITextView alloc] init];    
    containerView.clipsToBounds = YES;
    containerView.layer.cornerRadius = 15.0;
    containerView.layer.borderColor = [[UIColor blackColor] CGColor];
    containerView.layer.borderWidth = 2;
    [containerView setEditable:NO];
    [containerView setFont:[UIFont systemFontOfSize:15]];
    [containerView setBackgroundColor:[UIColor whiteColor]];
    [containerView setContentInset:UIEdgeInsetsMake(0, -8, 0, 0)];
    containerView.frame =  CGRectMake(20, 155 , 280, 35);
    
    maleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 35)];
    [maleLabel setText:@"Male"];
    [maleLabel setTextAlignment:NSTextAlignmentCenter];
    if(user != nil && [user gender] != nil && [[user gender] isEqualToString:@"male"]){
        [maleLabel setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1]];
        sex = @"male";
    }else  [maleLabel setBackgroundColor:[UIColor whiteColor]];
    [maleLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    [maleLabel setTextColor:[UIColor blackColor]];
    maleLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    maleLabel.layer.borderWidth = 2;    
    [containerView addSubview:maleLabel];
    
    UIButton *maleLabelBtn = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 100, 35)];
    maleLabelBtn.tag = 1;
    [maleLabelBtn addTarget:self action:@selector(maleLabelTap:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:maleLabelBtn];
    [containerView bringSubviewToFront:maleLabelBtn];
    
    femaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(98, 0, 100, 35)];
    [femaleLabel setText:@"Female"];
    [femaleLabel setTextAlignment:NSTextAlignmentCenter];
    if(user != nil && [user gender] != nil && [[user gender] isEqualToString:@"female"]){
        [femaleLabel setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1]];
        sex = @"female";
    }else  [femaleLabel setBackgroundColor:[UIColor whiteColor]];
    [femaleLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    [femaleLabel setTextColor:[UIColor blackColor]];
    femaleLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    femaleLabel.layer.borderWidth = 2;    
    [containerView addSubview:femaleLabel];
    
    UIButton *femaleLabelBtn = [[UIButton alloc] initWithFrame: CGRectMake(98, 0, 100, 35)];
    femaleLabelBtn.tag = 1;
    [femaleLabelBtn addTarget:self action:@selector(femaleLabelTap:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:femaleLabelBtn];
    [containerView bringSubviewToFront:femaleLabelBtn];
    
    notSpecifiedLabel = [[UILabel alloc] initWithFrame:CGRectMake(196, 0, 100, 35)];
    [notSpecifiedLabel setText:@"Not sure"];
    [notSpecifiedLabel setTextAlignment:NSTextAlignmentCenter];
    if((user != nil && [user gender] != nil && [[user gender] isEqualToString:@"not_specified"]) || user == nil || (user != nil && [user gender] == nil)){
        [notSpecifiedLabel setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1]];
        sex = @"not_specified";
    }else  [notSpecifiedLabel setBackgroundColor:[UIColor whiteColor]];
    [notSpecifiedLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    [notSpecifiedLabel setTextColor:[UIColor blackColor]];
    notSpecifiedLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    notSpecifiedLabel.layer.borderWidth = 2;
    [containerView addSubview:notSpecifiedLabel];
    
    UIButton *notSpecifiedLabelBtn = [[UIButton alloc] initWithFrame: CGRectMake(196, 0, 100, 35)];
    notSpecifiedLabelBtn.tag = 1;
    [notSpecifiedLabelBtn addTarget:self action:@selector(notSpecifiedLabelTap:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:notSpecifiedLabelBtn];
    [containerView bringSubviewToFront:notSpecifiedLabelBtn];
    
    [self.view addSubview:containerView];
    
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
    [self dismissViewControllerAnimated:YES completion:nil];
    //[[picker parentViewController] dismissModalViewControllerAnimated:YES];
}

- (void)maleLabelTap:(UIButton *)sender
{
    [maleLabel setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1]];
    [femaleLabel setBackgroundColor:[UIColor whiteColor]];
    [notSpecifiedLabel setBackgroundColor:[UIColor whiteColor]];
    sex = @"male";
}

- (void)femaleLabelTap:(UIButton *)sender
{
    [femaleLabel setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1]];
    [maleLabel setBackgroundColor:[UIColor whiteColor]];
    [notSpecifiedLabel setBackgroundColor:[UIColor whiteColor]];
    sex = @"female";
}

- (void)notSpecifiedLabelTap:(UIButton *)sender
{
    [notSpecifiedLabel setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1]];
    [maleLabel setBackgroundColor:[UIColor whiteColor]];
    [femaleLabel setBackgroundColor:[UIColor whiteColor]];
    sex = @"not_specified";
}

- (NSDictionary *)registerTask
{
    double startTime = [[NSDate date] timeIntervalSince1970];
    
    Request *request = [[Request alloc] init];
    //NSString *postString =[[NSString alloc] initWithFormat:@"user[email]=%@&user[password]=%@&user[name]=%@&user[gender]=%@",[emailField text],[passField text], [nameField text], sex];
    
    [request addStringToPostData:@"user[email]" andValue:[emailField text]];
    [request addStringToPostData:@"user[password]" andValue:[passField text]];
    [request addStringToPostData:@"user[gender]" andValue:sex];
    [request addStringToPostData:@"user[name]" andValue:[nameField text]];     
    if(user != nil)[request addStringToPostData:@"api_key" andValue: appDelegate.apiKey];
    //[postData appendData:[postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    if(![self isBlankImage:avatarView.image])[request addImageToPostData:@"user[avatar]" andValue:avatarView.image];
    
    NSDictionary *something;
    NSString *requestString;
    if(user == nil)requestString = @"/users.json";       
    else requestString = [NSString stringWithFormat: @"/api/users/%d/update.json", [user userId]];
    
    something = [request getDataFrom:requestString];
    
    if(something != nil){      
       
        NSLog(@"something %@", something);       
        
    }
    
    double stopTime = [[NSDate date] timeIntervalSince1970];
    
    double time = 2000 - (stopTime - startTime);
    
    if(time > 0) sleep(time / 1000);
    
    return something;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                        }
                        else if([[errors objectForKey:error] isKindOfClass:[NSString class]]){
                            msg = [errors objectForKey:error];
                        }
                        
                        [appDelegate alertStatus:@"" : msg];
                        
                        break;
                    }
                    
                } else if(status != nil && [status isEqualToString: @"ok"]){
                    
                    User *newUser = [[UserStore get] parseUserData: (NSDictionary*) [something objectForKey: @"user"]];
                    [[UserStore get] addUser:newUser];
                    [appDelegate saveCredentials:[newUser userId]];
                    appDelegate.loggedInFlag = [NSNumber numberWithInt:3];
                    [appDelegate setCurrentUserId: [newUser userId]];
                    
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

 - (BOOL)isBlankImage:(UIImage *)image
{
    NSData *data1 = UIImagePNGRepresentation(blankImage);
    NSData *data2 = UIImagePNGRepresentation(image);   
    return [data1 isEqual:data2];
}

@end
