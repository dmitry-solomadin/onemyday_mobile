//
//  SettingsViewController.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 11.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "StartViewController.h"
#import "WebViewViewController.h"
#import "DMTwitterCore.h"
#import "Request.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

AppDelegate *appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = [[UIApplication sharedApplication] delegate];
        UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Log out", nil)
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self action:@selector(logOut:)];
        
        [logOutButton setTintColor:[appDelegate onemydayColor]];
        self.navigationItem.rightBarButtonItem = logOutButton;
    }
    return self;
}

- (void)logOut:(id)sender
{
     NSLog(@"Logging out...");
    
    if(appDelegate.loggedInFlag == 1) {
        NSLog(@"Logging out facebook");
       
        [appDelegate.session closeAndClearTokenInformation];  
        
    } else if (appDelegate.loggedInFlag == 2) {
        NSLog(@"Logging out twitter");
        [[DMTwitter shared] logout];
    } else if (appDelegate.loggedInFlag == 3) {
        NSLog(@"Logging out email");        
    }
    
    [self wipeDeviceTokenFromUser];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loggedInFlag"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    appDelegate.loggedInFlag = 0;
    appDelegate.currentUserId = 0;
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableView *tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[self view] bounds].size.height)
                                                        style:UITableViewStyleGrouped];
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tblView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSInteger row = [indexPath row];
    switch (row) {
        case 0:
            cell.textLabel.text = @"Version 1.0";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;            
        case 1:
            cell.textLabel.text = @"Onemyday.co";
            break;
        case 2:
            cell.textLabel.text = @"Terms of Service";
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    WebViewViewController *webViewViewController;
    switch (row) {
        case 1:
            webViewViewController = [[WebViewViewController alloc] initWithNibName:nil bundle:nil];
            [webViewViewController setUrl:@"http://onemyday.co"];
            [[self navigationController] pushViewController:webViewViewController animated:YES];                      
            break;
        case 2:
            webViewViewController = [[WebViewViewController alloc] initWithNibName:nil bundle:nil];
            [webViewViewController setUrl:@"http://onemyday.co/terms"];
            [[self navigationController] pushViewController:webViewViewController animated:YES];
            break;
    }
}

- (void)wipeDeviceTokenFromUser
{
    Request *request = [[Request alloc] init];
    [request addStringToPostData:@"api_key" andValue:appDelegate.apiKey];
    [request addStringToPostData:@"user[ios_device_token]" andValue:@""];    
    [request sendAsync:@"/api/stories/create_and_publish"
            onProgress:nil onFinish:nil];
}

@end
