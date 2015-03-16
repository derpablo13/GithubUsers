//
//  MasterViewController.m
//  GithubUsers
//
//  Created by parak on 3/11/15.
//  Copyright (c) 2015 parak. All rights reserved.
//

#import "MasterViewController.h"
#import "GUDataManager.h"
#import "AvatarImageViewController.h"

static NSString * const USER_CELL_IDENTIFIER = @"nodeCell";
static NSString * const USER_CELL_DEFAULT_IMAGE = @"no_photo.png";
static NSString * const DISPLAY_AVATAR_IMAGE_SEGUE_IDENTIFIER = @"displayAvatarImage";

@interface MasterViewController () <GUDataManagerDelegate>

@property GUDataManager *dataManager;
@property NSInteger indexOfUserForDisplayAvatarImage;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataManager = [GUDataManager new];
    self.dataManager.delegate = self;
    
    [self.dataManager downloadGithubUsersData];
}

#pragma mark - Actions

- (IBAction)refreshButtonPressed:(id)sender {
    [self.dataManager downloadGithubUsersData];
}

- (IBAction)cellImagePressed:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    
    if (self.dataManager.usersData.count > tap.view.tag) {
        self.indexOfUserForDisplayAvatarImage = tap.view.tag;
        
        [self performSegueWithIdentifier:DISPLAY_AVATAR_IMAGE_SEGUE_IDENTIFIER
                                  sender:self];
    }
}

#pragma mark - Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:DISPLAY_AVATAR_IMAGE_SEGUE_IDENTIFIER]) {
        AvatarImageViewController *avatarImageViewController = [segue destinationViewController];
        avatarImageViewController.dataManager = self.dataManager;
        avatarImageViewController.userIndex = self.indexOfUserForDisplayAvatarImage;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataManager.usersData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableViewCellForIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.dataManager cancelDownloadImageForCellAtIndexPath:indexPath];
}

/**
 *  Will configure table view cell for index path.
 *
 *  @param indexPath Index path of cell.
 *
 *  @return Configured cell.
 */
- (UITableViewCell *)tableViewCellForIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:USER_CELL_IDENTIFIER
                                                                 forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:USER_CELL_IDENTIFIER];
    }
    
    cell.imageView.tag = indexPath.row;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellImagePressed:)];
    [cell.imageView addGestureRecognizer:tapGestureRecognizer];
    
    if (self.dataManager.usersData.count > indexPath.row) {
        GUUserNode *userNode = [self.dataManager.usersData objectAtIndex:indexPath.row];
        
        cell.textLabel.text = userNode.login;
        cell.detailTextLabel.text = userNode.htmlURL;
        
        if (userNode.avatarImage) {
            cell.imageView.image = userNode.avatarImage;
        } else {
            // Set default image for cell.
            cell.imageView.image = [UIImage imageNamed:USER_CELL_DEFAULT_IMAGE];
            
            // Start download image for cell.
            [self.dataManager downloadImageForCellAtIndexPath:indexPath
                                                      andSize:cell.imageView.image.size];
        }
    } else {
        // Set default content for cell.
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        cell.imageView.image = [UIImage imageNamed:USER_CELL_DEFAULT_IMAGE];
    }
    
    return cell;
}

#pragma mark - GUDataManagerDelegate

- (void)dataManagerDidStartDownloadingUsersData:(GUDataManager *)manager {
    [self showActivityIndicator];
}

- (void)dataManager:(GUDataManager *)manager didFinishDownloadingUsersData:(NSArray *)usersData {
    [self.tableView reloadData];
    [self hideActivityIndicator];
}

- (void)dataManager:(GUDataManager *)manager didFinishDownloadingImageForCellAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
}

- (void)dataManager:(GUDataManager *)manager didFailDownloadingWithErrorTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [self hideActivityIndicator];
}

#pragma mark - Activity indicator

- (void)showActivityIndicator {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.activityIndicator startAnimating];
    self.tableView.hidden = YES;
}

- (void)hideActivityIndicator {
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.activityIndicator stopAnimating];
    self.tableView.hidden = NO;
}

@end
