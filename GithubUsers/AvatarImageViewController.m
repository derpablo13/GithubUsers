//
//  AvatarImageViewController.m
//  GithubUsers
//
//  Created by parak on 3/13/15.
//  Copyright (c) 2015 parak. All rights reserved.
//

#import "AvatarImageViewController.h"

@interface AvatarImageViewController ()

@property IBOutlet UIView *containerView;
@property IBOutlet UIImageView *imageView;
@property IBOutlet UIActivityIndicatorView *activityIndicator;
@property IBOutlet NSLayoutConstraint *imageViewWidthConstraint;
@property IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@end

@implementation AvatarImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle
                                                                                                message:errorMessage
                                                                                               delegate:nil
                                                                                      cancelButtonTitle:@"OK"
                                                                                      otherButtonTitles:nil];
                                                [alert show];
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
