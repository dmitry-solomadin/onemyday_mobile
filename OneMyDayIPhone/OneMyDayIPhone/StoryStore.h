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
    NSMutableArray *cachedStories;
}

@property (strong, nonatomic) NSNumber *numOfCachedImages;

+ (StoryStore *)get;

- (void)setStories:(NSMutableArray *)_stories;
- (NSArray *)getStories;
- (Story *)findById:(int)storyId;
- (id)requestStoriesIncludePhotos:(BOOL)includePhotos includeUser:(BOOL)includeUser newStories:(BOOL)newStories lastId: (long) lastId withLimit: (int) limit userId: (NSString *)userId;
- (id)loadStoriesFromDisk;
- (bool)checkImageLimit: (NSString*)imageURL;
- (void)saveImage:(UIImage*)image withName:(NSString*)imageName;
- (UIImage*)loadImage:(NSString*)imageName;
- (NSString *)requestErrorMsg;
- (void)setRequestErrorMsg: msg;
- (NSMutableArray *)getCachedStories;
- (void)saveStoriesToDisk: (NSMutableArray *)cacheStories;

@end
