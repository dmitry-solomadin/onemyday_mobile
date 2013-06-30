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

- (void) addStringToPostData:(NSString *)key andValue:(NSString *)value
{
    if(postData == nil) postData = [NSMutableData alloc];
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"%@\r\n", value] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) addImageToPostData:(NSString *)key andValue:(UIImage *)value
{
    if(postData == nil) postData = [NSMutableData alloc];
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData: [@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData: UIImagePNGRepresentation(value)];
    [postData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString *) errorMsg
{
    return errorMsg;
}

+ (NSString *) operationFailedMsg
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

// TODO this method and getData method look very similar, do we really need both?
/*- (id)sendRequest:(NSString*)path data: (NSString*)post
{
    //NSLog(@"PostData: %@", post);
    
    NSString *urlTxt = [mainUrl stringByAppendingString: path];
    
    NSURL *url = [NSURL URLWithString: urlTxt];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *response = nil;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"Response code: %d", [response statusCode]);
    if ([response statusCode] >= 200 && [response statusCode] < 300) {
        NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        //NSLog(@"Response ==> %@", responseData);
        
        SBJsonParser *jsonParser = [SBJsonParser new];
        NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
        //NSLog(@"POST jsonData: %@",jsonData);
        
        return jsonData;
    } else {        
        if (error){            
            NSLog(@"Error: %@", error);            
            errorMsg = [error localizedDescription];
        } else errorMsg = badConnectionMsg;
    }
    return nil;
}*/

- (id)getDataFrom:(NSString *)path
{    
    NSString *urlTxt = [mainUrl stringByAppendingString: path];        
    NSURL *url = [NSURL URLWithString: urlTxt];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
    
    NSLog(@"url %@", url);
    NSLog(@"post %@", postData);
    
    [request setURL: url];
    
    if(postData != nil){
        
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:30];
        [request setHTTPMethod:@"POST"];        
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        
        // set Content-Type in HTTP header
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        
        /*NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];*/
        
      
        
        /*NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];*/
        
        [postData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                
        [request setHTTPBody:postData];
        
        // set the content-length
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    }  else [request setHTTPMethod:@"GET"];
    
    postData = nil;
    
    NSError *error;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
     NSLog(@"HTTP status code %i", [responseCode statusCode]);
    if ([responseCode statusCode] != 200) {
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        //@try{
            /*if (error && [responseCode statusCode] == 0){
                errorMsg = [error localizedDescription];                
            } else */errorMsg = badConnectionMsg;
        /*} @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
            errorMsg = badConnectionMsg;
        }*/
        return nil;
    } else {
        SBJsonParser *jsonParser = [SBJsonParser new];
        
        NSString *responseData = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
        NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
        
        //NSLog(@"jsonData %@", jsonData);
        return jsonData;
    }    
}

- (id)requestLogin
{
    //NSMutableData *postData = [NSMutableData alloc];
    //[postData appendData:[path dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    NSDictionary *jsonData = [self getDataFrom:@"auth/regular.json"];
    if(jsonData == nil) return nil;
    
    NSString *status = (NSString *) [jsonData objectForKey:@"status"];
    //NSLog(@"%@",status);
    
    if([status isEqualToString: @"no_such_user"]){        
        errorMsg = @"Wrong email or password!";
        //NSLog(@"no_such_user");
        return nil;
    } else if([status isEqualToString: @"ok"]){
        User *user = [[UserStore get] parseUserData: (NSDictionary*) [jsonData objectForKey: @"user"]];
        [[UserStore get] addUser:user];   
        return user;
    } else {
        NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
        if(error_msg != nil) errorMsg = error_msg;
        else errorMsg = operationFailedMsg;
        //NSLog(@"Login Failed! %@",error_msg);
        return nil;
    }   
}

@end
