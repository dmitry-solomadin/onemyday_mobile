//
//  Story.h
//  OneMyDayIPhone
//
//  Created by Admin on 2/9/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Story : NSObject

@property (strong) NSString *text;
@property (strong) UIImage *image;

- (id)initWithText:(NSString*)text;

@end
