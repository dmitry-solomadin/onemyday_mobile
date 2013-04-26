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

@synthesize cacheLimit;
@synthesize numOfCachedImages;

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
    NSArray *jsonData = [request getDataFrom: path];
    NSMutableArray *allStories = [NSMutableArray array];
    NSMutableArray *cacheStories = [NSMutableArray array];
    NSMutableArray *cacheUsers = [NSMutableArray array];
     
    for (int i=0; i < [jsonData  count]; i++) {
        NSDictionary *story = [jsonData objectAtIndex:i];
        int storyId = [(NSString *) [story objectForKey:@"id"] intValue];
        int authorId = [(NSString *) [story objectForKey:@"user_id"] intValue];
        NSString *title = (NSString *) [story objectForKey:@"title"];
        NSDictionary *photos = (NSDictionary*) [story objectForKey:@"story_photos"];
        
        NSMutableArray *photoArray  = [[NSMutableArray alloc] init];
        
        for (NSDictionary *photo in photos) {
            [photoArray addObject:photo];
        }
        
        Story *newStory = [[Story alloc] initWithId: storyId andTitle:title andAuthor:authorId andPhotos: (NSArray*)photos];
        [allStories addObject:newStory];
        if(i < [cacheLimit intValue])[cacheStories addObject:newStory];
        
        if (includeUser) {
            User *user = [[UserStore get] parseUserData: (NSDictionary*) [story objectForKey:@"user"]];
            [[UserStore get] addUser:user];
            if(i < [cacheLimit intValue])[cacheUsers addObject:user];
        }
    }
    
    [[StoryStore get] setStories:allStories];
    
    [self saveStoriesToDisk:cacheStories];
    [[UserStore get] saveUsersToDisk:cacheUsers];
    //[self loadDataFromDisk];
    
    return allStories;
}

- (void)saveStoriesToDisk: (NSMutableArray *)allStories {
    NSString *path = @"~/Documents/data";
    path = [path stringByExpandingTildeInPath];
    
    NSMutableDictionary *rootObject;
    rootObject = [NSMutableDictionary dictionary];
    
    [rootObject setValue:allStories forKey:@"stories"];
    
    [NSKeyedArchiver archiveRootObject:rootObject toFile:path];
}

- (id)loadStoriesFromDisk {
    NSString *path = @"~/Documents/data";
    path = [path stringByExpandingTildeInPath];
    
    NSMutableDictionary *rootObject;
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    /*if ([rootObject valueForKey:@"stories"]) {
        return [rootObject valueForKey:@"stories"];
    }
    ruturn nil;
     */
    return [rootObject valueForKey:@"stories"];
}

- (void)saveImage:(UIImage*)image withName:(NSString*)imageName {
    //convert image into .png format.
    NSData *imageData = UIImagePNGRepresentation(image);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%@.png", imageName]];
    
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
    numOfCachedImages = [NSNumber numberWithInt:[numOfCachedImages intValue]+1];
    NSLog(@"image saved");  
}

- (UIImage*)loadImage:(NSString*)imageName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%@.png", imageName]];
    NSLog(@"image loaded");
    return [UIImage imageWithContentsOfFile:fullPath];
    
}

- (bool*)checkImageLimit{
    if([cacheLimit intValue]==0)cacheLimit = [NSNumber numberWithInt:10];
    if([numOfCachedImages intValue]<[cacheLimit intValue])return true;
    else return false;    
}

@end
