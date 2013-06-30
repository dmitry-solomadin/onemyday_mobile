//
//  ActivityViewController.h
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 11.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface ActivityViewController : UIViewController <UIScrollViewDelegate, EGORefreshTableHeaderDelegate>
{    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@property(nonatomic, strong) UIScrollView *scrollView;

@end
