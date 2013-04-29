//
//  EditorStore.h
//  Onemyday
//
//  Created by dmitry.solomadin on 28.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditorStore : NSObject

+ (EditorStore *)get;

- (NSString *)saveImage:(UIImage *)image;
- (void)deleteImageWithKey:(NSString *)key;
- (NSMutableDictionary *)loadAllImages;

@end
