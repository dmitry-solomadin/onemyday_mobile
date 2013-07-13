//
//  LoginViewController.h
//  OneMyDayIPhone
//
//  Created by Admin on 2/22/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface LoginViewController : UIViewController{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

+ (bool) validateEmail:(NSString *) email;

- (IBAction)loginClick:(id)sender;
- (IBAction)signUp:(id)sender;

@end
