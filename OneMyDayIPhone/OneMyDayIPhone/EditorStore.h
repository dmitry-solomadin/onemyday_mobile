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

- (void)changeKeyPositionOldPosition:(int)oldPos newPosition:(int)newPos;

- (NSString *)saveImage:(UIImage *)image;
- (void)deleteImageWithKey:(NSString *)key;
- (UIImage *)getImageWithKey:(NSString *)key;

- (NSString *)saveText:(NSString *)text;
- (NSString *)changeText:(NSString *)text withKey:(NSString *)key;
- (void)deleteTextWithKey:(NSString *)key;
- (NSString *)getTextWithKey:(NSString *)key;

- (void)saveTitle:(NSString *)title;
- (NSString *)loadTitle;

@end
