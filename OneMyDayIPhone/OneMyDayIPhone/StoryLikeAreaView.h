//
//  StoryLikeAreaView.h
//  Onemyday
//
//  Created by dmitry.solomadin on 23.07.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowStoryViewController.h"

@interface StoryLikeAreaView : UIView

@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UIButton *button;
- (IBAction)likeButtonTapped:(id)sender;
- (IBAction)reportTapped:(id)sender;
@property (weak, nonatomic) ShowStoryViewController *controller;

@end
