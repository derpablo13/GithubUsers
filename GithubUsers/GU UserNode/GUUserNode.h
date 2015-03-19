//
//  GUUserNode.h
//  GithubUsers
//
//  Created by parak on 3/12/15.
//  Copyright (c) 2015 parak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GUUserNode : NSObject

/**
 *  User's login name.
 */
@property (nonatomic, readonly) NSString *login;

/**
 *  User's profile URL.
 */
@property (nonatomic, readonly) NSString *htmlURL;

/**
 *  User's avatar URL.
 */
@property (nonatomic, readonly) NSString *avatarURL;

/**
 *  User's avatar image.
 */
@property (nonatomic, strong) UIImage *avatarImage;

/**
 *  Download avatar image operation.
 */
@property (nonatomic, weak) NSBlockOperation *downloadImageOperation;

/**
 *  Will initialize user node with login name, profile URL and avatar URL.
 *
 *  @param login     User's login name.
 *  @param htmlURL   User's profile URL.
 *  @param avatarURL User's avatar URL.
 *
 *  @return Initialized user node.
 */
- (instancetype)initWithLogin:(NSString *)login
                      htmlURL:(NSString *)htmlURL
                    avatarURL:(NSString *)avatarURL;

/**
 *  Will cancel download avatar image operation.
 */
- (void)cancelDownloadImageOperation;

@end
