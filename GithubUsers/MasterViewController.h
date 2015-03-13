//
//  MasterViewController.h
//  GithubUsers
//
//  Created by parak on 3/11/15.
//  Copyright (c) 2015 parak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

/**
 *  Reference to table view.
 */
@property (nonatomic, strong) IBOutlet UITableView *tableView;

/**
 *  Activity indicator for preseting loading process.
 */
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

/**
 *  Action that will be called when user pressed refresh button.
 *
 *  @param sender Sender.
 */
- (IBAction)refreshButtonPressed:(id)sender;

@end

