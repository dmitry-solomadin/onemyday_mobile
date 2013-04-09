//
//  NewMasterViewController.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 09.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "NewMasterViewController.h"
#import "Request.h"
#import "Story.h"
#import "ThumbStoryView.h"

@interface NewMasterViewController ()
{
    NSMutableArray * stories;
}
@end

@implementation NewMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSString *postString =[[NSString alloc] initWithFormat:@"/stories.json?p=true"];
        stories = [[Request alloc] storiesRequest: postString];
        
        for (int i = 0; i < [stories count]; i++) {
            Story *story = [stories objectAtIndex:i];
            CGRect frame = CGRectMake(0, i * 225, 200, 200);
            ThumbStoryView *thumbStoryView = [[ThumbStoryView alloc] initWithFrame:frame story:story];
            
            [[self view] addSubview:thumbStoryView];
            NSLog(@"%d", i);
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
