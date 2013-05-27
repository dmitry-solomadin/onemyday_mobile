//
//  Request.h
//  OneMyDayIPhone
//
//  Created by Admin on 2/9/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Request : NSObject

+ (NSString *)insertParametersIntoUrl:(NSMutableString *)url parameters:(NSArray *)parameters;

- (id)sendRequest:(NSString *)path data:(NSString *)post;
- (id)getDataFrom:(NSString *)path;
- (id)requestLoginWithPath:(NSString*)path;
- (NSString *) errorMsg;
- (NSString *) operationFailedMsg;

@end
