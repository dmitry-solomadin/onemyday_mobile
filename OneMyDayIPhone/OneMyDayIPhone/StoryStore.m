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
NSString *requestErrorMsg = nil;

- (NSString *) requestErrorMsg
{
    return requestErrorMsg;
}

- (void) setRequestErrorMsg: msg
{
    requestErrorMsg = msg;
}

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

- (NSMutableArray *)getCachedStories
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
lastId: (long) lastId withLimit: (int) limit userId: (int) userId authorId: (int)authorId searchFor: (NSString *)text
{    
    NSMutableString *path = [[NSMutableString alloc] initWithString:@"/search_stories.json"];
    NSMutableArray *parameters = [[NSMutableArray alloc] init];
    if (includePhotos) {
        [parameters addObject:@"p=true"];
    }
    if (includeUser) {
        [parameters addObject:@"u=true"];
    }
    if(authorId != 0)[parameters addObject:[NSString stringWithFormat: @"author_id=%d", authorId]];
    [parameters addObject:@"ft=2"];
    [parameters addObject:@"page=all"];
    [parameters addObject:[NSString stringWithFormat:@"requesting_user_id=%d",userId]];
    if(text != nil)[parameters addObject:[NSString stringWithFormat:@"q=%@",text]];
    else if (newStories) [parameters addObject:[NSString stringWithFormat:@"higher_than_id=%ld",lastId]];
    else [parameters addObject:[NSString stringWithFormat:@"lower_than_id=%ld",lastId]];
    [parameters addObject:[NSString stringWithFormat:@"limit=%d",limit]];
    [Request insertParametersIntoUrl:path parameters:parameters];

    Request *request = [[Request alloc] init];
    NSArray *jsonData = [request send:path];
 
    /*if([request errorMsg] != nil){
        NSLog(@"[[request errorMsg] %@", [request errorMsg]);
        requestErrorMsg = [request errorMsg];        
        return nil;  
    }*/
        
    NSMutableArray *allStories = [NSMutableArray array];
    NSMutableArray *cacheStories = [NSMutableArray array];
    NSLog(@"jsonData %@", jsonData);
    for (int i = 0; i < [jsonData  count]; i++) {
        NSDictionary *story = [jsonData objectAtIndex:i];
        int storyId = [(NSString *) [story objectForKey:@"id"] intValue];
        int authorId = [(NSString *) [story objectForKey:@"user_id"] intValue];
        NSString *title = (NSString *) [story objectForKey:@"title"];
        NSDictionary *photos = (NSDictionary*) [story objectForKey:@"story_photos"];
        NSDate *createdAt = [StoryStore parseRFC3339Date:[story objectForKey:@"created_at"]];
        int isLikedByUser = [(NSString *) [story objectForKey:@"is_liked_by_user"] intValue];     
        int likesCount = [(NSString *) [story objectForKey:@"likes_count"] intValue];
        int viewsCount = [(NSString *) [story objectForKey:@"views_count"] intValue];
        int commentsCount = [(NSString *) [story objectForKey:@"comments_count"] intValue];
        
        NSMutableArray *photoArray  = [[NSMutableArray alloc] init];
        
        for (NSDictionary *photo in photos) {
            [photoArray addObject:photo];
        }
        
        Story *newStory = [[Story alloc] initWithId: storyId andTitle:title andAuthor:authorId
                                          andPhotos: (NSArray*)photos andCreatedAt:createdAt  andViewsCount:viewsCount
                                   andCommentsCount:commentsCount andLikesCount:likesCount isLikedByUser:isLikedByUser];
       
        [allStories addObject: newStory];
        if(newStories && i < cacheLimit)[cacheStories addObject: newStory];
        
        if (includeUser) {
            User *user = [[UserStore get] parseUserData: (NSDictionary*) [story objectForKey: @"user"]];
            [[UserStore get] addUser:user];            
        }
    }

    if (newStories && authorId == 0) {
        NSMutableArray *oldCachedStories = [self getCachedStories];     
        
        if ([cacheStories count] > 0) {            
            if([cacheStories count] < cacheLimit) {
                int storiesLeftForCache = cacheLimit - [cacheStories count];               
                for(int i = 0;i < storiesLeftForCache;i++){
                    Story *story = [oldCachedStories objectAtIndex:i];                    
                    if(story != nil)[cacheStories addObject: story];
                    else break;
                }
            }           
            [self delOldCachedImages: cacheStories];
            [self saveStoriesToDisk: cacheStories];
        } else numOfCachedImages = cacheLimit;
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
    NSError *error;
    if (![fileManager createDirectoryAtPath:fullPath 
                                   withIntermediateDirectories:NO attributes:nil error:&error]){
        //NSLog(@"Create directory error: %@", error);
    }
    fullPath = [fullPath stringByAppendingPathComponent: imageName];
    //NSLog(@"fullPath save %@",fullPath);
    bool result = [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];

    //NSLog(@"store result %d",result);
}

- (UIImage*)loadImage:(NSString*)imageName {    
    
    imageName = [imageName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
   
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent: imagesDirectory];   
    fullPath = [fullPath stringByAppendingPathComponent: imageName];
     //NSLog(@"fullPath load %@",fullPath);
    return [UIImage imageWithContentsOfFile:fullPath];
}

- (void)delOldCachedImages: (NSArray *) cacheStories {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent: imagesDirectory];
    
    numOfCachedImages = 0;
    
    NSFileManager *fm = [NSFileManager defaultManager];   
    NSError *error = nil;
    //NSLog(@"fullPath del %@",documentsDirectory);
    for (NSString *file in [fm contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
       
        bool exists = false;
        for(int j = 0; j < [cacheStories count]; j++) {          
            Story *story = [cacheStories objectAtIndex:j];
            //NSLog(@"j: %d" , j);
            NSString *photoName = [story extractPhotoStringType:@"thumb_url" atIndex:0];
            User *author = [[UserStore get] findById:[story authorId]];
            NSString *avatarName = [author extractAvatarStringType:@"small_url"];
            photoName = [photoName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
            avatarName = [avatarName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
            
            if ([file isEqualToString:photoName]) {
                exists = true;                
                numOfCachedImages++;
                break;
            }
            else if ([file isEqualToString:avatarName]) {
                exists = true;
                break;
            }
        }
        
        if(!exists) {
            //NSLog(@"delete file: %@" , file);
            bool success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, file] error:&error];
        
            if (!success || error) {
                NSLog(@"error %@", error);
            } else {
                //NSLog(@"delete success");
            }
        }
    }    
    
}

- (bool)checkImageLimit: (NSString*)imageURL
{    
    if ([self isAvatar: imageURL]) {
        bool result = false;
        NSMutableArray *cStories = [self getCachedStories];
        for (int i = 0; i < [cStories count]; i++) {
            User *author = [[UserStore get] findById:[[cStories objectAtIndex: i] authorId]];
            NSString *avatarName = [author extractAvatarStringType:@"small_url"];
            if ([avatarName  isEqualToString:imageURL]) {
                result = true;
                break;
            }
        }
        return result;
    } else {
        if (numOfCachedImages < cacheLimit) {
            numOfCachedImages++;
            //NSLog(@"numOfCachedImages 2 %d", numOfCachedImages);
            return true;
        }
        else return false;
    }
}

- (bool)isAvatar: (NSString *)AvatarURL
{
    if ([AvatarURL rangeOfString:@"avatars" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return true;
    }
    else return false;    
}

+ (NSDate *)parseRFC3339Date:(NSString *)dateString
{
    NSDateFormatter *rfc3339TimestampFormatterWithTimeZone = [[NSDateFormatter alloc] init];
    [rfc3339TimestampFormatterWithTimeZone setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [rfc3339TimestampFormatterWithTimeZone setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDate *theDate = nil;
    NSError *error = nil;
    if (![rfc3339TimestampFormatterWithTimeZone getObjectValue:&theDate forString:dateString range:nil error:&error]) {
        NSLog(@"Date '%@' could not be parsed: %@", dateString, error);
    }
    
    return theDate;
}

@end
