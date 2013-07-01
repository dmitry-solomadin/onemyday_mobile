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
+ (NSString *)operationFailedMsg;

- (id)send:(NSString *)path;
- (void)sendAsync:(NSString *)path onProgress:(void (^)(float))progress onFinish:(void (^)(NSDictionary *))finish;

- (void) addImageToPostData:(NSString *)key andValue:(UIImage *)value;
- (void) addStringToPostData:(NSString *)key andValue:(NSString *)value;

- (NSString *)errorMsg;

@end
