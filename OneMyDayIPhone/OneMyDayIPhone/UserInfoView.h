//
//  UserInfoView.h
//  Onemyday
//
//  Created by Admin on 6/17/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserInfoView : UIView

@property (nonatomic, weak) id controller;

- (id)initWithFrame:(CGRect)frame andUser: (User *)user;

@end
