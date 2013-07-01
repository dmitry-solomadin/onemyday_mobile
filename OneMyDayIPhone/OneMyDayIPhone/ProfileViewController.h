//
//  ProfileViewController.h
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 11.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController

- (void)showSettings:(UIBarButtonItem *)sender;

@property (nonatomic, strong) UIScrollView *scrollView;
@property int userId;

@end
