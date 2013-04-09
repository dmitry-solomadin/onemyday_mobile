//
//  MasterViewController.m
//  OneMyDayIPhone
//
//  Created by Admin on 2/16/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AsyncImageView.h"
#import "Story.h"
#import "Request.h"

@interface MasterViewController () {
    NSMutableArray * _stories;
}
@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"All stories";
    
    NSString *postString =[[NSString alloc] initWithFormat:@"/stories.json?p=true"];
    
    _stories = [[Request alloc] storiesRequest: postString];
}

// Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_stories count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 225;
}

#define ASYNC_IMAGE_TAG 9999
#define LABEL_TAG 8888

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [object description];*/
    
    static NSString *CellIdentifier = @"Cell";
    
    AsyncImageView *asyncImageView = nil;
    UILabel *label = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        CGRect frame;
        frame.origin.x = 10;
        frame.origin.y = 5;
        frame.size.width = 300;
        frame.size.height = 20;
        label = [[UILabel alloc] initWithFrame:frame];
        label.tag = LABEL_TAG;
        [cell.contentView addSubview:label];
        frame.origin.x = 70;
        frame.origin.y = 25;
        frame.size.width = 200;
        frame.size.height = 200;
        asyncImageView = [[AsyncImageView alloc] initWithFrame:frame];
        asyncImageView.tag = ASYNC_IMAGE_TAG;
        [cell.contentView addSubview:asyncImageView];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        asyncImageView = (AsyncImageView *) [cell.contentView viewWithTag:ASYNC_IMAGE_TAG];
        label = (UILabel *) [cell.contentView viewWithTag:LABEL_TAG];
    }
    
    
    Story *story = [_stories objectAtIndex: indexPath.row];
    
    NSDictionary *photo = [[story photos] objectAtIndex: 0];
    
    NSDictionary *photo_urls = (NSDictionary *) [photo objectForKey:@"photo_urls"];
    NSString *image = (NSString*) [photo_urls objectForKey:@"thumb_url"];
    NSLog(@"image %@",image);
    NSURL *url = [NSURL URLWithString: image];
    [asyncImageView loadImageFromURL:url];
    
    /*for (NSDictionary *photo  in [story photos]) {
        NSDictionary *photo_urls = (NSDictionary *) [photo objectForKey:@"photo_urls"];
        //NSLog(@"photo_urls %@",photo_urls);
        NSString *image = (NSString*) [photo_urls objectForKey:@"thumb_url"];
        NSLog(@"image %@",image);
        NSURL *url = [NSURL URLWithString: image];
        [asyncImageView loadImageFromURL:url];
        
        
        break;
        
    }*/
    
    label.text = [story title];
    label.textAlignment = NSTextAlignmentCenter;
    /*NSURL *url = [NSURL URLWithString: [story thumbImageUrl]];
    [asyncImageView loadImageFromURL:url];*/
    
    
    
    /*AsyncImageView *asyncImageView = nil;
    UIImageView *imageView;
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = 100;
    frame.size.height = 150;
    asyncImageView = [[AsyncImageView alloc] initWithFrame:frame];
    asyncImageView.tag = ASYNC_IMAGE_TAG;
    imageView = asyncImageView;
    Story *story = [stories objectAtIndex: indexPath.row];
    cell.textLabel.text = [story title];;
    cell.imageView.image = asyncImageView;
    //[cell.contentView addSubview:asyncImageView];*/
    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;
    }*/
    Story *story = [_stories objectAtIndex: indexPath.row];
    DetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
    detail.story= story;
    [self.navigationController pushViewController:detail animated:YES];
}

/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}*/

@end
