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
#import "HomeSiteViewController.h"
#import "DMTwitterCore.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

NSURL *onemydayUrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Log out", nil)
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self action:@selector(logOut:)];
        
        [logOutButton setTintColor:[UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1.0]];
        self.navigationItem.rightBarButtonItem = logOutButton;
    }
    return self;
}

- (void)logOut:(id)sender
{
     NSLog(@"Logging out...");
    // get the app delegate so that we can access the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if(appDelegate.loggedInFlag == 1)
    {
        NSLog(@"Logging out facebook");
        [appDelegate.session closeAndClearTokenInformation];
    }
    
    else if (appDelegate.loggedInFlag == 2)
    {
        NSLog(@"Logging out twitter");
        [[DMTwitter shared] logout];
    }
    
    else if (appDelegate.loggedInFlag == 3)
    {
        NSLog(@"Logging out email");        
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loggedInFlag"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    appDelegate.loggedInFlag = 0;
    appDelegate.currentUserId = 0;
    
    //StartViewController  *startViewController = [[StartViewController alloc] initWithNibName:@"StartViewController" bundle:nil];
    //[self presentViewController:startViewController animated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    onemydayUrl = [NSURL URLWithString:@"http://onemyday.co"];
    
    UITableView *tblView = [[UITableView alloc]init];
    tblView.frame = CGRectMake(0, 0, 320, 90); // here , you can set you tableview's frame in view.
    tblView.delegate = self; // for delegate methods this one need to set compulsary
    tblView.dataSource = self;// for datasource methods this one need to set compulsary
    tblView.backgroundColor = [UIColor clearColor];
    tblView.tag = 3; // Tag is used to make the seperation between multiple tables.
    [self.view addSubview:tblView]; // place tableview on the main view on which you want to display it.
}

// Optional method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2; // Default is 1 if not implemented
}

// required datasource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell=[tableView1 dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSInteger section = [indexPath section];
         
    switch (section) {
        case 0: // First cell in section 1
            cell.textLabel.text = @"Version 1.0"; // You can place you content string here what you want to show in each row of the tableview         
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        case 1:
            cell.textLabel.text = @"Onemyday.co";
            break;
    }
    return cell;
}

// Required delegate methods
- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    
    HomeSiteViewController *homeSiteViewController;
    
    switch (section) {    
        case 1:           
           
            homeSiteViewController = [[HomeSiteViewController alloc] initWithNibName:nil bundle:nil];
            [[self navigationController] pushViewController:homeSiteViewController animated:YES];          
            
            break;
    }
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
