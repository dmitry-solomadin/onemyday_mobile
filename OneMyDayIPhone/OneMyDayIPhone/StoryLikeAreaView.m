//
//  StoryLikeAreaView.m
//  Onemyday
//
//  Created by dmitry.solomadin on 23.07.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "StoryLikeAreaView.h"

@implementation StoryLikeAreaView
@synthesize controller;

- (IBAction)likeButtonTapped:(id)sender {
    [controller likeButtonTapped];
}

- (IBAction)reportTapped:(id)sender {
    [controller reportTapped];
}
@end
