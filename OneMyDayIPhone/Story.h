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
@property (strong) NSString *thumbImageUrl;

- (id)initWithTitle:(NSString*)title andImageUrl: (NSString*)thumbImageUrl;

@end
