//
//  LoginViewController.h
//  OneMyDayIPhone
//
//  Created by Admin on 2/22/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

- (IBAction)loginClick:(id)sender;
- (IBAction)facebookLogin:(id)sender;

@end
