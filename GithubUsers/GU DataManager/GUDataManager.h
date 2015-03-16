//
//  GUDataManager.h
//  GithubUsers
//
//  Created by parak on 3/12/15.
//  Copyright (c) 2015 parak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GUUserNode.h"

@class GUDataManager;

/**
 *  Protocol for GUDataManager delegate.
 */
@protocol GUDataManagerDelegate <NSObject>

@optional

/**
 *  Will notify delegate about start downloading users data.
 *
 *  @param manager Data manager instance.
 */
- (void)dataManagerDidStartDownloadingUsersData:(GUDataManager *)manager;

/**
 *  Will notify delegate about finished downloading users data.
 *
 *  @param manager Data manager instance.
 *  @param content Array of GUUserNode objects.
 */
- (void)dataManager:(GUDataManager *)manager didFinishDownloadingUsersData:(NSArray *)usersData;

/**
 *  Will notify delegate about finished downloading image for cell at index path.
 *
 *  @param manager   Data manager instance.
 *  @param indexPath Index path of cell.
 */
- (void)dataManager:(GUDataManager *)manager didFinishDownloadingImageForCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Will notify delegate about downloading error with title and message.
 *
 *  @param manager Data manager instance.
 *  @param title   Error title.
 *  @param message Error message.
 */
- (void)dataManager:(GUDataManager *)manager didFailDownloadingWithErrorTitle:(NSString *)title andMessage:(NSString *)message;

@end

@interface GUDataManager : NSObject

/**
 *  Delegate of Data manager.
 */
@property (nonatomic, weak) id <GUDataManagerDelegate> delegate;

/**
 *  Array of GUUserNode objects.
 */
@property (nonatomic, readonly) NSMutableArray *usersData;

/**
 *  Will start downloading users data.
 */
- (void)downloadGithubUsersData;

/**
 *  Will start downloading image for cell at index path with required size.
 *
 *  @param indexPath Index path of cell.
 *  @param imageSize Required image size.
 */
- (void)downloadImageForCellAtIndexPath:(NSIndexPath *)indexPath
                                andSize:(CGSize)imageSize;

/**
 *  Will cancel downloading image for cell at index path.
 *
 *  @param indexPath Index path of cell.
 */
- (void)cancelDownloadImageForCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Will start downloading image for node at index path with required size.
 *
 *  @param index           Index of node.
 *  @param imageSize       Required image size.
 *  @param completionBlock Completion block.
 */
- (void)downloadFullImageForNodeWithIndex:(NSInteger)index
                             requiredSize:(CGSize)imageSize
                          completionBlock:(void (^)(UIImage *image, NSError *error, NSString *errorTitle, NSString *errorMessage))completionBlock;

@end
