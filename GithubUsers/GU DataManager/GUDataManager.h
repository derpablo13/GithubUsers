//
//  GUDataManager.h
//  GithubUsers
//
//  Created by parak on 3/12/15.
//  Copyright (c) 2015 parak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GUUserNode.h"

@interface GUDataManager : NSObject

/**
 *  Array of GUUserNode objects.
 */
@property (nonatomic, readonly) NSMutableArray *usersData;

/**
 *  Will start downloading users data.
 *
 *  @param completionBlock Completion block.
 */
- (void)downloadGithubUsersDataWithCompletionBlock:(void (^)(NSArray *usersData, NSError *error, NSString *errorTitle, NSString *errorMessage))completionBlock;

/**
 *  Will start downloading cell image for node at index with required size.
 *
 *  @param index           Index of node.
 *  @param imageSize       Required image size.
 *  @param completionBlock Completion block.
 */
- (void)downloadCellImageForNodeWithIndex:(NSInteger)index
                             requiredSize:(CGSize)imageSize
                          completionBlock:(void (^)(UIImage *image, NSError *error, NSString *errorTitle, NSString *errorMessage))completionBlock;

/**
 *  Will cancel downloading cell image for node at index.
 *
 *  @param indexPath Index of node.
 */
- (void)cancelDownloadCellImageForNodeWithIndex:(NSInteger)index;

/**
 *  Check does users data array contains index.
 *
 *  @param index Index.
 *
 *  @return YES if contains.
 */
- (BOOL)usersDataContainsIndex:(NSInteger)index;

@end
