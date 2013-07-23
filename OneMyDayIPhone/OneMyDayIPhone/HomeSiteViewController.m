//
//  HomeSiteViewController.m
//  Onemyday
//
//  Created by Admin on 7/23/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "HomeSiteViewController.h"

@interface HomeSiteViewController ()

@end

@implementation HomeSiteViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
     
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	UIWebView *view = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 370)];
    NSString *url=@"http://onemyday.co";
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [view loadRequest:nsrequest];
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
