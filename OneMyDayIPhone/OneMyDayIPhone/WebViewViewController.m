//
//  HomeSiteViewController.m
//  Onemyday
//
//  Created by Admin on 7/23/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "WebViewViewController.h"

@interface WebViewViewController ()
{
    NSString *url;
}

@end

@implementation WebViewViewController


- (void)setUrl:(NSString *)_url
{
    url = _url;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	UIWebView *view = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 370)];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [view loadRequest:request];
    [self.view addSubview:view];
}

@end
