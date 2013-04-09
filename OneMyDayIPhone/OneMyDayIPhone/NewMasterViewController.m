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

        [[self view] setFrame: self.view.window.bounds];
        
        for (int i = 0; i < [stories count]; i++) {
            Story *story = [stories objectAtIndex:i];
            CGRect frame = CGRectMake(5, i * 180, 300, 300);
            ThumbStoryView *thumbStoryView = [[ThumbStoryView alloc] initWithFrame:frame story:story];
            
            [[self scrollView] addSubview:thumbStoryView];
            NSLog(@"%d", i);
        }
        
        CGFloat scrollViewHeight = 0.0f;
        for (UIView* view in [self scrollView].subviews) {
            scrollViewHeight += view.frame.size.height;
        }

        [[self scrollView] setContentSize:(CGSizeMake(320, scrollViewHeight))];
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
