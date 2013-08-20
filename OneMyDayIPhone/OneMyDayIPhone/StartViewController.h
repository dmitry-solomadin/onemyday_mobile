//
//  StartViewController.h
//  OneMyDayIPhone
//
//  Created by Admin on 4/10/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface StartViewController : UIViewController{
    MBProgressHUD *HUD;
}

- (IBAction)loginOnemday:(id)sender;

- (IBAction)loginFacebook:(id)sender;

- (IBAction)loginTwitter:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton; 

// get the app delegate so that we can access the session property
//@property (strong, nonatomic) AppDelegate *appDelegate;

@end
