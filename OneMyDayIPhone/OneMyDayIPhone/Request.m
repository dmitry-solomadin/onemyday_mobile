//
//  Request.m
//  OneMyDayIPhone
//
//  Created by Admin on 2/9/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "Request.h"
#import "SBJson.h"
#import "Story.h"
#import "MasterViewController.h"

@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@implementation Request

NSString *mainUrl = @"http://onemyday.co/";


- (id)sendRequest:(NSString*)path data: (NSString*)post{
    
    NSLog(@"PostData: %@",post);
    
    NSString *urlTxt = [mainUrl stringByAppendingString: path];
    
    NSURL *url=[NSURL URLWithString: urlTxt];
    
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
    if ([response statusCode] >=200 && [response statusCode] <300)
    {
        NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
        
        SBJsonParser *jsonParser = [SBJsonParser new];
        NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
        NSLog(@"POST jsonData: %@",jsonData);
        
        return jsonData;
        
    } else {
        if (error) NSLog(@"Error: %@", error);
        //[self alertStatus:@"Connection Failed" :@"Login Failed!"];
    }
    return @"Error";
}

- (id) getDataFrom:(NSString *)path{
    
    NSString *url = [mainUrl stringByAppendingString: path];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return nil;
    }else{
        SBJsonParser *jsonParser = [SBJsonParser new];
        NSString *responseData  = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
        NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
        NSLog(@"GET jsonData: %@",jsonData);
        return jsonData;
    }
    
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

- (id)loginRequest:(NSString*)post {
    
    NSDictionary *jsonData = [self sendRequest: @"auth/regular.json" data: post];
    NSString *status = (NSString *) [jsonData objectForKey:@"status"];
    NSLog(@"%@",status);
    
    if([status isEqualToString: @"ok"])
    {
        NSString *userId = (NSString *) [jsonData objectForKey:@"user_id"];
        NSLog(@"Login SUCCESS userId = %@",userId);
        return userId;        
    } else {
        NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
        NSLog(@"Login Failed! %@",error_msg);
        return error_msg;
    }    
}

- (id)storiesRequest:(NSString*)path {
    
    NSDictionary *jsonData = [self getDataFrom: path];
    NSMutableArray *allStories = [NSMutableArray array];
    
    for (NSDictionary *story in jsonData) {
        NSLog(@"story %@",story);
        NSString *title = (NSString *) [story objectForKey:@"title"];
        NSLog(@"title %@",title);
        NSDictionary *photos = (NSDictionary*) [story objectForKey:@"story_photos"];
        
        
        NSMutableArray *photoArray  = [[NSMutableArray alloc] init];
        
        for (NSDictionary *photo in photos) {
            [photoArray addObject:photo];
        }
        //NSArray * photoArray = [photos allValues];
        [allStories addObject:[[Story alloc] initWithTitle:title andPhotos: (NSArray*)photos]];
        
        
        /*for (NSDictionary *photo  in storyPhotos) {
            NSDictionary *photo_urls = (NSDictionary *) [photo objectForKey:@"photo_urls"];
            //NSLog(@"photo_urls %@",photo_urls);
            NSString *image = (NSString*) [photo_urls objectForKey:@"thumb_url"];
            NSLog(@"image %@",image);
            [allStories addObject:[[Story alloc] initWithTitle:title andImageUrl: image]];
            break;
            
        }*/
    }
    //AllStoriesView *controller = [[AllStoriesView alloc] init];
    //controller.allStories = allStories;

    //NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
    //NSLog(@"Get stories Failed! %@",error_msg);
    return allStories;
}

@end
