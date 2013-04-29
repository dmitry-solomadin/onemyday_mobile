//
//  EditorStore.m
//  Onemyday
//
//  Created by dmitry.solomadin on 28.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "EditorStore.h"

@implementation EditorStore

+ (EditorStore *)get
{
    static EditorStore *store = nil;
    if (!store) {
        store = [[super allocWithZone:nil] init];
    }
    
    return store;
}

- (NSMutableDictionary *)loadAllImages
{
    NSMutableDictionary *keyToImage = [[NSMutableDictionary alloc] init];
    for (NSString *key in [self loadAllKeys]) {
        UIImage *image = [self loadImageByKey:key];
        if (image) {
            [keyToImage setObject:image forKey:key];
        }
    }
    return keyToImage;
}

- (UIImage *)loadImageByKey:(NSString *)key
{
    NSString *path = [self imagePathForKey:key];
    return [UIImage imageWithContentsOfFile:path];
}

- (NSString *)saveImage:(UIImage *)image
{
    NSString *imageKey = [self generateAndSaveKey];
    NSData *imageData = UIImagePNGRepresentation(image);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self imagePathForKey:imageKey];
    
    [fileManager createFileAtPath:path contents:imageData attributes:nil];
    return imageKey;
}

- (void)deleteImageWithKey:(NSString *)key
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self imagePathForKey:key];
    
    [fileManager removeItemAtPath:path error:NULL];
    [self deleteKey:key];
}

- (NSString *)generateAndSaveKey
{
    NSString *key = [self generateImageKey];
    [self saveKey:key];
    return key;
}

- (NSMutableArray *)loadAllKeys
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"editor_image_keys"];
}

- (void)saveKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *editorImageKeys = [userDefaults objectForKey:@"editor_image_keys"];
    if (editorImageKeys == nil) {
        editorImageKeys = [[NSMutableArray alloc] init];
    } else {
        editorImageKeys = [NSMutableArray arrayWithArray:editorImageKeys];
    }
    [editorImageKeys addObject:key];
    [userDefaults setObject:editorImageKeys forKey:@"editor_image_keys"];
    [userDefaults synchronize];
}

- (void)deleteKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *editorImageKeys = [userDefaults objectForKey:@"editor_image_keys"];
    if (editorImageKeys) {
        editorImageKeys = [NSMutableArray arrayWithArray:editorImageKeys];
        [editorImageKeys removeObject:key];
    }
    [userDefaults setObject:editorImageKeys forKey:@"editor_image_keys"];
    [userDefaults synchronize];
}

- (NSString *)generateImageKey
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
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:key];
}

@end
