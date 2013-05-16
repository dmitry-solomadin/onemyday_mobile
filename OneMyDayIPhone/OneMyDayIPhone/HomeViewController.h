//
//  NewMasterViewController.h
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 09.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
 
@interface HomeViewController : UIViewController <UIScrollViewDelegate, EGORefreshTableHeaderDelegate>
{    
    __block CGFloat oldFeedHeight;

    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@property (nonatomic, strong) UIScrollView *scrollView;

@end


