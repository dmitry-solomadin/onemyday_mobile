//
//  AllStoriesView.m
//  OneMyDayIPhone
//
//  Created by Admin on 2/10/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "AllStoriesView.h"
#import "AsyncImageView.h"
#import "CloseupViewController.h"
#import "Story.h"
#import "Request.h"

@implementation AllStoriesView

NSMutableArray * stories;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"OneMyDay";
    
    NSString *postString =[[NSString alloc] initWithFormat:@"/stories.json?p=true"];
    
    stories = [[Request alloc] storiesRequest: postString];
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [stories count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

#define ASYNC_IMAGE_TAG 9999
#define LABEL_TAG 8888

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    AsyncImageView *asyncImageView = nil;
    UILabel *label = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        CGRect frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        frame.size.width = 100;
        frame.size.height = 150;
        asyncImageView = [[AsyncImageView alloc] initWithFrame:frame];
        asyncImageView.tag = ASYNC_IMAGE_TAG;
        [cell.contentView addSubview:asyncImageView];
        frame.origin.x = 100 + 10;
        frame.size.width = 200;
        label = [[UILabel alloc] initWithFrame:frame];
        label.tag = LABEL_TAG;
        [cell.contentView addSubview:label];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        asyncImageView = (AsyncImageView *) [cell.contentView viewWithTag:ASYNC_IMAGE_TAG];
        label = (UILabel *) [cell.contentView viewWithTag:LABEL_TAG];
    }
    
    
    Story *story = [stories objectAtIndex: indexPath.row];
    
    NSURL *url = [NSURL URLWithString: [story thumbImageUrl]];
    [asyncImageView loadImageFromURL:url];
    
    label.text = [story title];
    
    return cell;
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CloseupViewController *viewController = [[CloseupViewController alloc]
                                             initWithNibName:@"CloseupViewController" bundle:nil];
    Story *story = [stories objectAtIndex: indexPath.row];
    
    NSURL *url = [NSURL URLWithString: [story thumbImageUrl]];
    
    viewController.myURL = url;
    viewController.title = [story title];
	[self.navigationController pushViewController:viewController animated:YES];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */




@end


