//
//  StoryStore.h
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 10.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Story;

@interface StoryStore : NSObject
{
    NSMutableArray *stories;
}

+ (StoryStore *)get;

- (id)initWithStories:(NSMutableArray *)_stories;
- (NSArray *)getStories;
- (Story *)findById:(int)storyId;

@end
