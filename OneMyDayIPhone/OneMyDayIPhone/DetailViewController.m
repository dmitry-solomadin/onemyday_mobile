//
//  DetailViewController.m
//  OneMyDayIPhone
//
//  Created by Admin on 2/16/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "DetailViewController.h"
#import "AsyncImageView.h"
#import "Story.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailView = _detailView;

- (void)setDetailItem:(id)newDetailItem
{
    if (_story != newDetailItem) {
        _story = newDetailItem;
        
        // Update the view.
        //[self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

#define ASYNC_IMAGE_TAG 9999
#define LABEL_TAG 8888

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_story photos] count];
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.story) {
        //self.detailDescriptionLabel.text = [self.detailItem title];
        //[self.myImageView loadImageFromURL:self.myURL];
        
        self.title = [_story title];
        
        AsyncImageView *asyncImageView = nil;
        UILabel *label = nil;
        
        NSInteger boundsX = 0;
        NSInteger boundsY = 0;
       
        for (NSDictionary *photo  in [_story photos]) {
            
            CGRect frame;
            frame.origin.x = boundsX;
            frame.origin.y = boundsY;
            frame.size.width = 100;
            frame.size.height = 150;
            asyncImageView = [[AsyncImageView alloc] initWithFrame:frame];
            asyncImageView.tag = ASYNC_IMAGE_TAG;
            
            frame.origin.x = 100 + 10;
            frame.size.width = 200;
            frame.size.height = 150;
            label = [[UILabel alloc] initWithFrame:frame];
            label.tag = LABEL_TAG;
            
            
            boundsY += 160;
            
            NSDictionary *photo_urls = (NSDictionary *) [photo objectForKey:@"photo_urls"];
            NSLog(@"photo_urls %@",photo_urls);
            NSString *image = (NSString*) [photo_urls objectForKey:@"thumb_url"];
           
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
            
            NSString *caption = (NSString *) [photo objectForKey:@"caption"];
            
            if(caption!= ( NSString *) [ NSNull null ]){
                label.text = caption;
                [view addSubview:label];
            }
            
            if(image){
                NSLog(@"image %@",image);
                NSURL *url = [NSURL URLWithString: image];
                [asyncImageView loadImageFromURL:url];
            
                [view addSubview:asyncImageView];
            }
            
            [self.view addSubview:view];
            //break;
            
        }
        
        
        

    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

#define ASYNC_IMAGE_TAG 9999
#define LABEL_TAG 8888

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    AsyncImageView *asyncImageView = nil;
    UILabel *label = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (self.story) {
        //self.detailDescriptionLabel.text = [self.detailItem title];
        //[self.myImageView loadImageFromURL:self.myURL];
        
        self.title = [_story title];
        
        /*AsyncImageView *asyncImageView = nil;
        UILabel *label = nil;
        
        NSInteger boundsX = 0;
        NSInteger boundsY = 0;
        
        for (NSDictionary *photo  in [_story photos]) {
            
            CGRect frame;
            frame.origin.x = boundsX;
            frame.origin.y = boundsY;
            frame.size.width = 100;
            frame.size.height = 150;
            asyncImageView = [[AsyncImageView alloc] initWithFrame:frame];
            asyncImageView.tag = ASYNC_IMAGE_TAG;
            
            frame.origin.x = 100 + 10;
            frame.size.width = 200;
            frame.size.height = 150;
            label = [[UILabel alloc] initWithFrame:frame];
            label.tag = LABEL_TAG;
            
            
            boundsY += 160;
            
            NSDictionary *photo_urls = (NSDictionary *) [photo objectForKey:@"photo_urls"];
            NSLog(@"photo_urls %@",photo_urls);
            NSString *image = (NSString*) [photo_urls objectForKey:@"thumb_url"];
            
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
            
            NSString *caption = (NSString *) [photo objectForKey:@"caption"];
            
            if(caption!= ( NSString *) [ NSNull null ]){
                label.text = caption;
                [view addSubview:label];
            }
            
            if(image){
                NSLog(@"image %@",image);
                NSURL *url = [NSURL URLWithString: image];
                [asyncImageView loadImageFromURL:url];
                
                [view addSubview:asyncImageView];
            }
            
            [self.view addSubview:view];
            //break;
            
        }*/
        
        
       
        if (cell == nil) {
            NSDictionary *photo= [[_story photos] objectAtIndex: indexPath.row];
            
            NSDictionary *photo_urls = (NSDictionary *) [photo objectForKey:@"photo_urls"];
            //NSLog(@"photo_urls %@",photo_urls);
            NSString *image = (NSString*) [photo_urls objectForKey:@"thumb_url"];
            NSString *caption = (NSString *) [photo objectForKey:@"caption"];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            CGRect frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            frame.size.width = 100;
            frame.size.height = 150;
            asyncImageView = [[AsyncImageView alloc] initWithFrame:frame];
            asyncImageView.tag = ASYNC_IMAGE_TAG;
            [cell.contentView addSubview:asyncImageView];
            if(caption!= ( NSString *) [ NSNull null ]){
                frame.origin.x = 100 + 10;
                frame.size.width = 190;
                frame.size.height = 150;
                label = [[UILabel alloc] initWithFrame:frame];
                label.numberOfLines = 0;
                label.adjustsFontSizeToFitWidth = YES;
                label.lineBreakMode = UILineBreakModeWordWrap;
                label.tag = LABEL_TAG;
                [cell.contentView addSubview:label];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            NSLog(@"image %@",image);
            NSURL *url = [NSURL URLWithString: image];
            [asyncImageView loadImageFromURL:url];
            
            
            label.text = caption;
        } else {
            asyncImageView = (AsyncImageView *) [cell.contentView viewWithTag:ASYNC_IMAGE_TAG];
            label = (UILabel *) [cell.contentView viewWithTag:LABEL_TAG];
        }
        
        
        
       

        
        
        
    }
    
    
    
    
        
    /*for (NSDictionary *photo  in photos) {
        NSDictionary *photo_urls = (NSDictionary *) [photo objectForKey:@"photo_urls"];
        //NSLog(@"photo_urls %@",photo_urls);
        NSString *image = (NSString*) [photo_urls objectForKey:@"thumb_url"];
        NSLog(@"image %@",image);
        NSURL *url = [NSURL URLWithString: image];
        [asyncImageView loadImageFromURL:url];
        
        NSString *caption = (NSString *) [photo objectForKey:@"caption"];
        label.text = caption;
        break;
        
    }*/
    
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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //[self configureView];
}

- (void)getCellHeight
{
    
    //CGSize textSize = [label.title sizeWithFont:label.font];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
