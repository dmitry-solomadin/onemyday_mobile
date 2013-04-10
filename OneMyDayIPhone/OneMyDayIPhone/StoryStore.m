//
//  StoryStore.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 10.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "StoryStore.h"
#import "Story.h"

@implementation StoryStore

+ (StoryStore *)get
{
    static StoryStore *store = nil;
    if (!store) {
        store = [[super allocWithZone:nil] init];
    }
    
    return store;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self get];
}

- (id)initWithStories:(NSMutableArray *)_stories
{
    self = [super init];
    if (self) {
        stories = _stories;
    }
    
    return self;
}

- (NSArray *)getStories;
{
    return stories;
}

- (Story *)findById:(int)storyId
{
    NSLog(@"storyId is %d", storyId);
    for (Story *story in stories) {
        NSLog(@"storyId inner is %d", story.storyId);
        if (story.storyId == storyId) {
            return story;
        }
    }
    return nil;
}

@end
