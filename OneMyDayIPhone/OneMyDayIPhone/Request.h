//
//  Request.h
//  OneMyDayIPhone
//
//  Created by Admin on 2/9/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Request : NSObject

- (id)requestLoginWithPath:(NSString*)path;
- (id)requestStoriesWithPath:(NSString*)path;

@end
