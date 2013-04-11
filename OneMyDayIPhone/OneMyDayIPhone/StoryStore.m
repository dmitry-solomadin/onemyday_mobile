//
//  StoryStore.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 10.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "StoryStore.h"
#import "UserStore.h"
#import "Story.h"
#import "Request.h"

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

- (NSArray *)getStories;
{
    return stories;
}

- (void)setStories:(NSMutableArray *)_stories
{
    stories = _stories;
}

- (Story *)findById:(int)storyId
{
    for (Story *story in stories) {
        if (story.storyId == storyId) {
            return story;
        }
    }
    return nil;
}

- (id)requestStoriesIncludePhotos:(BOOL)includePhotos includeUser:(BOOL)includeUser
{
    NSMutableString *path = [[NSMutableString alloc] initWithString:@"/stories.json"];
    NSMutableArray *parameters = [[NSMutableArray alloc] init];
    if (includePhotos) {
        [parameters addObject:@"p=true"];
    }
    if (includeUser) {
        [parameters addObject:@"u=true"];
    }
    [Request insertParametersIntoUrl:path parameters:parameters];

    Request *request = [[Request alloc] init];
    NSDictionary *jsonData = [request getDataFrom: path];
    NSMutableArray *allStories = [NSMutableArray array];
    
    for (NSDictionary *story in jsonData) {
        int storyId = [(NSString *) [story objectForKey:@"id"] intValue];
        int authorId = [(NSString *) [story objectForKey:@"user_id"] intValue];
        NSString *title = (NSString *) [story objectForKey:@"title"];
        NSDictionary *photos = (NSDictionary*) [story objectForKey:@"story_photos"];
        
        NSMutableArray *photoArray  = [[NSMutableArray alloc] init];
        
        for (NSDictionary *photo in photos) {
            [photoArray addObject:photo];
        }
        
        [allStories addObject:[[Story alloc] initWithId: storyId andTitle:title andAuthor:authorId andPhotos: (NSArray*)photos]];
        
        if (includeUser) {
            User *user = [[UserStore get] parseUserData: (NSDictionary*) [story objectForKey:@"user"]];
            [[UserStore get] addUser:user];
        }
    }
    
    [[StoryStore get] setStories:allStories];
    
    return allStories;
}

@end
