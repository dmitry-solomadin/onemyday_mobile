//
//  ActivityView.h
//  Onemyday
//
//  Created by Admin on 6/27/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityView : UIView

@property (nonatomic, weak) id controller;

- (id)initWithFrame:(CGRect)frame andActivity: (NSDictionary *) activity;

@end
