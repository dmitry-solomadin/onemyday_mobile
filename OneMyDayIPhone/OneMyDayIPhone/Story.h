//
//  Story.h
//  OneMyDayIPhone
//
//  Created by Admin on 2/9/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Story : NSObject

@property (strong) NSString *title;
@property (strong) NSArray *photos;

- (id)initWithTitle:(NSString*)title andPhotos: (NSArray*)photos;
- (id)extractPhotoUrlType:(NSString*)type atIndex:(int)index;

@end
