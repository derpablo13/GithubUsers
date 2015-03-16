//
//  AvatarImageViewController.h
//  GithubUsers
//
//  Created by parak on 3/13/15.
//  Copyright (c) 2015 parak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GUDataManager.h"

@interface AvatarImageViewController : UIViewController

/**
 *  Data manager.
 */
@property (nonatomic, weak) GUDataManager *dataManager;

/**
 *  Current user index.
 */
@property NSInteger userIndex;

@end
