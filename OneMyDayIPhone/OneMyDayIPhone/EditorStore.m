//
//  EditorStore.m
//  Onemyday
//
//  Created by dmitry.solomadin on 28.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "EditorStore.h"
#import "OrderedDictionary.h"

@implementation EditorStore

+ (EditorStore *)get
{
    static EditorStore *store = nil;
    if (!store) {
        store = [[super allocWithZone:nil] init];
    }
    
    return store;
}

/* --- Load from store methods --- */

- (OrderedDictionary *)loadAllItems
{
    OrderedDictionary *keyToItem = [[OrderedDictionary alloc] init];
    NSMutableArray *keys = [[NSUserDefaults standardUserDefaults] objectForKey:@"editor_item_keys"];
    for (NSString *key in keys) {
        UIImage *image = [self loadImageByKey:key];
        if (image) {
            [keyToItem setObject:image forKey:key];
            continue;
        }
        NSString *text = [self loadTextByKey:key];
        if (text) {
            [keyToItem setObject:text forKey:key];
            continue;
        }
    }
    return keyToItem;
}

- (UIImage *)loadImageByKey:(NSString *)key
{
    NSString *path = [self imagePathForKey:key];
    return [UIImage imageWithContentsOfFile:path];
}

- (NSString *)loadTextByKey:(NSString *)key
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"editor_key_to_text"] objectForKey:key];
}

- (NSString *)loadTitle
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"editor_story_title"];
}

/* --- Save to store methods --- */

- (NSString *)saveImage:(UIImage *)image
{
    NSString *imageKey = [self generateAndSaveImageKey];
    NSData *imageData = UIImagePNGRepresentation(image);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self imagePathForKey:imageKey];
    
    [fileManager createFileAtPath:path contents:imageData attributes:nil];
    return imageKey;
}

- (NSString *)saveText:(NSString *)text
{
    NSString *key = [self generateKey];
    
    [self saveKey:key];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *editorKeyToText = [userDefaults objectForKey:@"editor_key_to_text"];
    if (editorKeyToText == nil) {
        editorKeyToText = [[NSMutableDictionary alloc] init];
    } else {
        editorKeyToText = [NSMutableDictionary dictionaryWithDictionary:editorKeyToText];
    }
    [editorKeyToText setObject:text forKey:key];
    [userDefaults setObject:editorKeyToText forKey:@"editor_key_to_text"];
    [userDefaults synchronize];
    
    return key;
}

- (void)saveTitle:(NSString *)title
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:title forKey:@"editor_story_title"];
    [userDefaults synchronize];
}

- (NSString *)changeText:(NSString *)text withKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *editorKeyToText = [userDefaults objectForKey:@"editor_key_to_text"];
    if (editorKeyToText == nil) {
        editorKeyToText = [[NSMutableDictionary alloc] init];
    } else {
        editorKeyToText = [NSMutableDictionary dictionaryWithDictionary:editorKeyToText];
    }
    [editorKeyToText setObject:text forKey:key];
    [userDefaults setObject:editorKeyToText forKey:@"editor_key_to_text"];
    [userDefaults synchronize];
    
    return key;
}

- (NSString *)generateAndSaveImageKey
{
    NSString *key = [self generateKey];
    [self saveKey:key];
    return key;
}

- (void)saveKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *editorItemKeys = [userDefaults objectForKey:@"editor_item_keys"];
    if (editorItemKeys == nil) {
        editorItemKeys = [[NSMutableArray alloc] init];
    } else {
        editorItemKeys = [NSMutableArray arrayWithArray:editorItemKeys];
    }
    [editorItemKeys addObject:key];
    [userDefaults setObject:editorItemKeys forKey:@"editor_item_keys"];
    [userDefaults synchronize];
}

- (void)changeKeyPositionOldPosition:(int)oldPos newPosition:(int)newPos
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *editorItemKeys = [userDefaults objectForKey:@"editor_item_keys"];
    if (editorItemKeys == nil) {
        editorItemKeys = [[NSMutableArray alloc] init];
    } else {
        editorItemKeys = [NSMutableArray arrayWithArray:editorItemKeys];
    }
    NSString *key = [editorItemKeys objectAtIndex:oldPos];
    [editorItemKeys removeObjectAtIndex:oldPos];
    [editorItemKeys insertObject:key atIndex:newPos];
    [userDefaults setObject:editorItemKeys forKey:@"editor_item_keys"];
    [userDefaults synchronize];
}

/* --- Delete from store methods --- */

- (void)deleteImageWithKey:(NSString *)key
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self imagePathForKey:key];
    
    [fileManager removeItemAtPath:path error:NULL];
    [self deleteKey:key];
}

- (void)deleteTextWithKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *editorKeyToText = [userDefaults objectForKey:@"editor_key_to_text"];
    if (editorKeyToText) {
        editorKeyToText = [NSMutableDictionary dictionaryWithDictionary:editorKeyToText];
        [editorKeyToText removeObjectForKey:key];
    }
    [userDefaults setObject:editorKeyToText forKey:@"editor_key_to_text"];
    [userDefaults synchronize];
    [self deleteKey:key];
}

- (void)deleteKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *editorItemKeys = [userDefaults objectForKey:@"editor_item_keys"];
    if (editorItemKeys) {
        editorItemKeys = [NSMutableArray arrayWithArray:editorItemKeys];
        [editorItemKeys removeObject:key];
    }
    [userDefaults setObject:editorItemKeys forKey:@"editor_item_keys"];
    [userDefaults synchronize];
}

/* --- Misc store methods --- */

- (NSString *)generateKey
{
    CFUUIDRef uniqueId = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, uniqueId);
    NSString *key = (__bridge NSString *)uniqueIdString;
    CFRelease(uniqueId);
    CFRelease(uniqueIdString);
    return key;
}

- (NSString *)imagePathForKey:(NSString *)key
{
    NSFileManager *fileManager = [NSFileManager defaultManager]; 
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    NSMutableString *cache_location = [[NSMutableString alloc] initWithString:@"/editor_cache"];
    [fileManager createDirectoryAtPath:cache_location withIntermediateDirectories:NO attributes:nil error:nil];
    [cache_location appendString:key];
    return [documentDirectory stringByAppendingPathComponent:cache_location];
}

@end
