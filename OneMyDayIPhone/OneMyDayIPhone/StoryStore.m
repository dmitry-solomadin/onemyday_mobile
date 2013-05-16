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
#import "User.h"
#import "Request.h"


@implementation StoryStore

NSString *path = @"~/Documents/stories";
NSString *imagesDirectory = @"images_cache";
int cacheLimit = 10;
int numOfCachedImages = 0;

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

- (NSMutableArray *)getStories;
{
    return stories;
}

- (void)setStories:(NSMutableArray *)_stories
{
    stories = _stories;
}

- (NSMutableArray *)getCachedStories;
{
    return cachedStories;
}

- (void)setCachedStories:(NSMutableArray *)_cachedStories
{
    cachedStories = _cachedStories;
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

- (id)requestStoriesIncludePhotos:(BOOL)includePhotos includeUser:(BOOL)includeUser newStories:(BOOL)newStories
                      lastId: (long) lastId withLimit: (int) limit
{    
    NSMutableString *path = [[NSMutableString alloc] initWithString:@"/search_stories.json"];
    NSMutableArray *parameters = [[NSMutableArray alloc] init];
    if (includePhotos) {
        [parameters addObject:@"p=true"];
    }
    if (includeUser) {
        [parameters addObject:@"u=true"];
    }
    [parameters addObject:@"ft=2"];
    [parameters addObject:@"page=all"];
    if(newStories){
        NSLog(@"new id = %ld",lastId);
        [parameters addObject:[NSString stringWithFormat:@"higher_than_id=%ld",lastId]];
    }
    else{
        NSLog(@"old id = %ld",lastId);
        [parameters addObject:[NSString stringWithFormat:@"lower_than_id=%ld",lastId]];
    }
    [parameters addObject:[NSString stringWithFormat:@"limit=%d",limit]];
    [Request insertParametersIntoUrl:path parameters:parameters];

    Request *request = [[Request alloc] init];
    NSArray *jsonData = [request getDataFrom: path];
    NSMutableArray *allStories = [NSMutableArray array];
    NSMutableArray *cacheStories = [NSMutableArray array];
     
    for (int i = 0; i < [jsonData  count]; i++) {
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
       
        [allStories addObject: newStory];
        if(newStories && i < cacheLimit)[cacheStories addObject: newStory];
        
        if (includeUser) {
            User *user = [[UserStore get] parseUserData: (NSDictionary*) [story objectForKey: @"user"]];
            [[UserStore get] addUser:user];            
        }
    }
    
    if (newStories) {
        NSMutableArray *oldCachedStories = [self getCachedStories];     
        
        if ([cacheStories count] > 0) {
            if([cachedStories count] < 10) {
                int storiesLeftForCache = 10 - [cacheStories count];
                for(int i = 0;i < storiesLeftForCache;i++){
                    Story *story = [oldCachedStories objectAtIndex:i];
                    if(story != nil)[cacheStories addObject: story];
                    else break;
                }
            }

            [self delOldCachedInfo: cacheStories];
            [self saveStoriesToDisk: cacheStories];
        }
    }
    
    [[UserStore get] saveUsersToDisk];
    
    return allStories;
}

- (void)saveStoriesToDisk: (NSMutableArray *)cacheStories {
    
    path = [path stringByExpandingTildeInPath];
    
    NSMutableDictionary *rootObject;
    rootObject = [NSMutableDictionary dictionary];
    
    [rootObject setValue: cacheStories forKey: @"stories"];
    
    [NSKeyedArchiver archiveRootObject: rootObject toFile: path];
    
    [self setCachedStories: cacheStories];
}

- (id)loadStoriesFromDisk {
   
    path = [path stringByExpandingTildeInPath];
    
    NSMutableDictionary *rootObject;
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile: path];
    
    NSMutableArray *loadedStories = [rootObject valueForKey: @"stories"];
    
    [self setStories:loadedStories];
    [self setCachedStories: loadedStories];
    
    return loadedStories;
}

- (void)saveImage:(UIImage*)image withName:(NSString*)imageName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    imageName = [imageName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSData *imageData = UIImagePNGRepresentation(image);
    NSFileManager *fileManager = [NSFileManager defaultManager];    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent: imagesDirectory];
    fullPath = [documentsDirectory stringByAppendingPathComponent: imageName];
    
    bool result = [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
    //[fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
    //NSLog(@"imagesDirectory %@",imagesDirectory);
    //NSLog(@"documentsDirectory  %@",documentsDirectory);
    NSLog(@"store result %d",result);
}

- (UIImage*)loadImage:(NSString*)imageName {    
    
    imageName = [imageName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
   
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent: imagesDirectory];
    fullPath = [documentsDirectory stringByAppendingPathComponent: imageName];
    
    return [UIImage imageWithContentsOfFile:fullPath];
}

- (void)delOldCachedInfo: (NSArray *) cacheStories {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent: imagesDirectory];
    
    numOfCachedImages = 0;
    
    NSFileManager *fm = [NSFileManager defaultManager];   
    NSError *error = nil;
  
    for (NSString *file in [fm contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
       
        bool exists = false;
        for(int j = 0; j < [cacheStories count]; j++)
        {          
            Story *story = [cacheStories objectAtIndex:j];
            //NSLog(@"j: %d" , j);
            NSString *photoName = [story extractPhotoStringType:@"thumb_url" atIndex:0];
            User *author = [[UserStore get] findById:[story authorId]];
            NSString *avatarName = [author extractAvatarStringType:@"small_url"];
            photoName = [photoName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
            avatarName = [avatarName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
            
            if ([file isEqualToString:photoName])
            {
                exists = true;                
                //NSLog(@"exists: %@ or %@" , photoName, avatarName);
                numOfCachedImages++;
                break;
            }
            else if ([file isEqualToString:avatarName])
            {
                exists = true;
                //NSLog(@"exists: %@ or %@" , photoName, avatarName);
                
                break;
            }
            
        }
        
        if(!exists)
        {
            NSLog(@"delete file: %@" , file);
            bool success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, file] error:&error];
        
            if (!success || error)
            {                
                NSLog(@"error %@", error);
            }
            else
            {
                NSLog(@"delete success");
            }
        }
    }    
    
}

- (bool)checkImageLimit: (NSString*)imageURL
{
    if([self isAvatar: imageURL])
    {
        bool result = false;
        NSMutableArray *cStories = [self getCachedStories];
        for(int i = 0; i < [cStories count]; i++)
        {
            User *author = [[UserStore get] findById:[[cStories objectAtIndex: i] authorId]];
            NSString *avatarName = [author extractAvatarStringType:@"small_url"];
            if ([avatarName  isEqualToString:imageURL])
            {
                result = true;
                break;
            }
        }
        return result;
    }
    else
    {
        if(numOfCachedImages < cacheLimit)
        {
            numOfCachedImages++;
            //NSLog(@"numOfCachedImages %d", numOfCachedImages);
            return true;
        }
        else return false;
    }
}

- (bool)isAvatar: (NSString *)AvatarURL
{
    if ([AvatarURL rangeOfString:@"avatars" options:NSCaseInsensitiveSearch].location != NSNotFound){
        return true;
    }
    else return false;    
}

@end
