//
//  ShowStoryViewController.h
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 10.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Story;

@interface ShowStoryViewController : UIViewController

@property(nonatomic, strong) Story *story;
@property(nonatomic, strong) UIScrollView *scrollView;

- (id)initWithStory:(Story *)_story;
- (void)deleteViewTapped:(UITapGestureRecognizer *)gr;
- (void)likeButtonTapped;
- (void)reportTapped;

@end
