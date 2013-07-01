//
//  Request.m
//  OneMyDayIPhone
//
//  Created by Admin on 2/9/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "Request.h"
#import "SBJson.h"
#import "AppDelegate.h"
#import "User.h"
#import "UserStore.h"

// TODO do we need this? Check!
@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@implementation Request

NSString *mainUrl = @"http://onemyday.co/";

NSString *badConnectionMsg = @"It appears that you have a bad connection.";
NSString *operationFailedMsg = @"Operation failed";
NSString *errorMsg = nil;
NSMutableData *postData;
NSString *boundary = @"---------------------------14737809831466499882746641449";
NSURLResponse *response;
void (^finish)(NSDictionary *);
void (^progress)(void);

/* SEND SYNC REQUEST */

- (id)send:(NSString *)path
{
    NSMutableURLRequest *request = [self prepareRequest:path];
    NSError *error;
    NSHTTPURLResponse *responseCode = nil;
    NSLog(@"path %@", path);    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    NSLog(@"HTTP status code %i", [responseCode statusCode]);
    if ([responseCode statusCode] != 200) {
        NSLog(@"Error getting %@, HTTP status code %i", path, [responseCode statusCode]);
        errorMsg = badConnectionMsg;
        return nil;
    } else {
        return [self parseResponseData:oResponseData];
    }    
}

/* SEND ASYNC REQUEST */

- (void)sendAsync:(NSString *)path onProgress:(void (^)(void))_progress onFinish:(void (^)(NSDictionary *))_finish
{
    NSMutableURLRequest *request = [self prepareRequest:path];
    
    progress = _progress;
    finish = _finish;
    
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
    [conn start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)_response
{
    response = _response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    int statusCode = [(NSHTTPURLResponse *)response statusCode];
    if (statusCode != 200) {
        //NSLog(@"Error getting %@, HTTP status code %i", path, statusCode);
        errorMsg = badConnectionMsg;
        finish(nil);
    } else {
        NSDictionary *jsonData = [self parseResponseData:data];
        finish(jsonData);
    }
    
}

/* MANAGE POST DATA METHODS */

- (void)addStringToPostData:(NSString *)key andValue:(NSString *)value
{
    if(postData == nil) postData = [NSMutableData alloc];
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"%@\r\n", value] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)addImageToPostData:(NSString *)key andValue:(UIImage *)value
{
    if(postData == nil) postData = [NSMutableData alloc];
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData: [@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData: UIImagePNGRepresentation(value)];
    [postData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}

/* HELPER METHODS */

- (NSMutableURLRequest *)prepareRequest:(NSString *)path
{
    NSString *urlTxt = [mainUrl stringByAppendingString: path];
    NSURL *url = [NSURL URLWithString: urlTxt];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL: url];
    
    if (postData != nil) {
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:30];
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        
        // set Content-Type in HTTP header
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        [postData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:postData];
        
        // set the content-length
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    } else {
        [request setHTTPMethod:@"GET"];
    }
    
    postData = nil;
    return request;
}

- (id)parseResponseData:(NSData *)oResponseData
{
    SBJsonParser *jsonParser = [SBJsonParser new];
    
    NSString *responseData = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
    NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
    //NSLog(@"jsonData %@", jsonData);
    return jsonData;
}

/* MISC METHODS */

- (NSString *)errorMsg
{
    return errorMsg;
}

+ (NSString *)operationFailedMsg
{
    return operationFailedMsg;
}

+ (NSString *)insertParametersIntoUrl:(NSMutableString *)url parameters:(NSArray *)parameters
{
    for (int i = 0; i < [parameters count]; i++) {
        NSString *parameter = [parameters objectAtIndex:i];
        if (i == 0) {
            [url appendString:@"?"];
        } else {
            [url appendString:@"&"];
        }
        [url appendString:parameter];
    }
    return url;
}

@end
