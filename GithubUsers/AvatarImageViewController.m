//
//  AvatarImageViewController.m
//  GithubUsers
//
//  Created by parak on 3/13/15.
//  Copyright (c) 2015 parak. All rights reserved.
//

#import "AvatarImageViewController.h"

@interface AvatarImageViewController ()

/**
 *  Container view for image.
 */
@property IBOutlet UIView *containerView;

/**
 *  Avatar image view.
 */
@property IBOutlet UIImageView *imageView;

/**
 *  Activity indicator for preseting loading process.
 */
@property IBOutlet UIActivityIndicatorView *activityIndicator;

/**
 *  Avatar image view width constraint.
 */
@property IBOutlet NSLayoutConstraint *imageViewWidthConstraint;

/**
 *  Avatar image view height constraint.
 */
@property IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@end

@implementation AvatarImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showActivityIndicator];
}

- (void)viewDidAppear:(BOOL)animated {
    CGFloat minImageSize = MIN(self.containerView.frame.size.width, self.containerView.frame.size.height);
    CGSize requiredImageSize = CGSizeMake(minImageSize, minImageSize);
    
    [self.dataManager downloadFullImageForNodeWithIndex:self.userIndex
                                           requiredSize:requiredImageSize
                                        completionBlock:^(UIImage *image, NSError *error, NSString *errorTitle, NSString *errorMessage) {
                                            if (image && !error) {
                                                [self setAvatarImage:image];
                                            } else {
                                                [self showErrorAlertViewWithTitle:errorTitle
                                                                          message:errorMessage];
                                            }
                                            
                                            [self hideActivityIndicator];
                                    }];
}

- (void)setAvatarImage:(UIImage *)image {
    self.imageView.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    
    self.imageViewWidthConstraint.constant = self.imageView.frame.size.width;
    self.imageViewHeightConstraint.constant = self.imageView.frame.size.height;
    
    self.imageView.image = image;
}

#pragma mark - Error alert view

- (void)showErrorAlertViewWithTitle:(NSString *)errorTitle
                            message:(NSString *)errorMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle
                                                    message:errorMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Activity indicator

- (void)showActivityIndicator {
    [self.activityIndicator startAnimating];
    self.imageView.hidden = YES;
}

- (void)hideActivityIndicator {
    [self.activityIndicator stopAnimating];
    self.imageView.hidden = NO;
}

@end
