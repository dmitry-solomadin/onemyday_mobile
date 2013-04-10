//
//  ThumbStoryView.h
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 09.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Story;

@interface ThumbStoryView : UIView
@property (nonatomic, strong) Story *story;
@property (nonatomic, weak) id controller;

- (id)initWithFrame:(CGRect)frame story:(Story *)_story;
- (void)setStory:(Story *)_story;

@end
