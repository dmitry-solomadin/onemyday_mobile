//
//  StoryCommentView.h
//  Onemyday
//
//  Created by Admin on 6/2/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface StoryCommentView : UIView

@property (nonatomic, weak) id controller;
@property bool first;
@property bool last;

- (id)initWithFrame:(CGRect)frame andComment:(Comment *)comment andIsFirst:(bool)first
          andIsLast:(bool)last andNavController:(UINavigationController *)navController;
- (void)removeRoundedCorners;
- (void)setAllRoundedCorners;
- (void)setTopRoundedCorners;
- (void)setBottomRoundedCorners;

@end
