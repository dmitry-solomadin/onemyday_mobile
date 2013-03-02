//
//  DetailViewController.h
//  OneMyDayIPhone
//
//  Created by Admin on 2/16/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UITableViewController

@property (strong, nonatomic) id story;
@property (strong, nonatomic) IBOutlet UIView *detailView;

@end
