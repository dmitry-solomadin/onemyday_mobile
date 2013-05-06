//
//  EditorStore.h
//  Onemyday
//
//  Created by dmitry.solomadin on 28.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditorStore : NSObject

typedef enum {
    photoItemType, textItemType
} ItemType;

+ (EditorStore *)get;

- (NSMutableDictionary *)loadAllItems;

- (NSString *)saveImage:(UIImage *)image;
- (void)deleteImageWithKey:(NSString *)key;

- (NSString *)saveText:(NSString *)text;
- (NSString *)changeText:(NSString *)text withKey:(NSString *)key;
- (void)deleteTextWithKey:(NSString *)key;

@end
