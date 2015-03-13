//
//  GUDataManager.m
//  GithubUsers
//
//  Created by parak on 3/12/15.
//  Copyright (c) 2015 parak. All rights reserved.
//

#import "GUDataManager.h"

static const NSInteger MAX_DOWNLOADING_USERS_LIST_COUNT = 1;
static const NSInteger MAX_DOWNLOADING_IMAGE_COUNT = 10;

static NSString * const GITHUB_USERS_URL = @"https://api.github.com/users";
static NSString * const LOGIN_KEY = @"login";
static NSString * const HTML_URL_KEY = @"html_url";
static NSString * const AVATAR_URL_KEY = @"avatar_url";

static NSString * const ERROR_DOWNLOADING_GITHUB_USERS_DATA_TITLE = @"Error downloading GitHub users data";
static NSString * const ERROR_PARSING_GITHUB_USERS_DATA_TITLE = @"Error parsing GitHub users data";
static NSString * const ERROR_DOWNLOADING_USERS_AVATAR_IMAGE_TITLE = @"Error downloading user's avatar image";

@interface GUDataManager()

@property NSMutableArray *usersData;

@property NSOperationQueue *downloadUsersListQueue;
@property NSOperationQueue *downloadImageQueue;

@end

@implementation GUDataManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.usersData = [NSMutableArray array];
        
        self.downloadUsersListQueue = [NSOperationQueue new];
        self.downloadUsersListQueue.maxConcurrentOperationCount = MAX_DOWNLOADING_USERS_LIST_COUNT;
        
        self.downloadImageQueue = [NSOperationQueue new];
        self.downloadImageQueue.maxConcurrentOperationCount = MAX_DOWNLOADING_IMAGE_COUNT;
    }
    return self;
}

#pragma mark - Download users data

- (void)downloadGithubUsersData {
    if ([self.delegate respondsToSelector:@selector(dataManagerDidStartDownloadingUsersData:)]) {
        [self.delegate dataManagerDidStartDownloadingUsersData:self];
    }
    
    // Clear previous users data objects.
    [self.usersData removeAllObjects];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:GITHUB_USERS_URL]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:self.downloadUsersListQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   [self notifyDelegateAboutDownloadingErrorWithTitle:ERROR_DOWNLOADING_GITHUB_USERS_DATA_TITLE
                                                                           andMessage:error.localizedDescription];
                               } else {
                                   [self parseUsersListFromData:data];
                               }
                           }];
}

- (void)parseUsersListFromData:(NSData *)data {
    NSError *error;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    
    if (error) {
        [self notifyDelegateAboutDownloadingErrorWithTitle:ERROR_PARSING_GITHUB_USERS_DATA_TITLE
                                                andMessage:error.localizedDescription];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSDictionary *userData in jsonArray) {
                GUUserNode *userNode = [[GUUserNode alloc] initWithLogin:[userData objectForKey:LOGIN_KEY]
                                                                 htmlURL:[userData objectForKey:HTML_URL_KEY]
                                                               avatarURL:[userData objectForKey:AVATAR_URL_KEY]];
                [self.usersData addObject:userNode];
            }
            
            if ([self.delegate respondsToSelector:@selector(dataManager:didFinishDownloadingUsersData:)]) {
                [self.delegate dataManager:self didFinishDownloadingUsersData:self.usersData];
            }
        });
    }
}

#pragma mark - Download user's avatar image

- (void)downloadImageForCellAtIndexPath:(NSIndexPath *)indexPath
                                andSize:(CGSize)imageSize {
    if (indexPath.row >= self.usersData.count) {
        return;
    }
    
    GUUserNode *userNode = [self.usersData objectAtIndex:indexPath.row];

    if (!userNode.avatarURL) {
        return;
    }
    
    userNode.downloadImageOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSError *error;
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:userNode.avatarURL]
                                                  options:NSDataReadingMappedIfSafe
                                                    error:&error];
        
        if (error) {
            [self notifyDelegateAboutDownloadingErrorWithTitle:ERROR_DOWNLOADING_USERS_AVATAR_IMAGE_TITLE
                                                    andMessage:error.localizedDescription];
        } else {
            userNode.avatarImage = [self imageWithImage:[UIImage imageWithData:imageData]
                                           scaledToSize:imageSize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(dataManager:didFinishDownloadingImageForCellAtIndexPath:)]) {
                    [self.delegate dataManager:self didFinishDownloadingImageForCellAtIndexPath:indexPath];
                }
            });
        }
    }];
    
    [self.downloadImageQueue addOperation:userNode.downloadImageOperation];
}

- (void)cancelDownloadImageForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.usersData.count) {
        return;
    }
    
    GUUserNode *userNode = [self.usersData objectAtIndex:indexPath.row];
    [userNode cancelDownloadImageOperation];
}

#pragma mark - Notify delegate about downloading error

- (void)notifyDelegateAboutDownloadingErrorWithTitle:(NSString *)title
                                          andMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(dataManager:didFailDownloadingWithErrorTitle:andMessage:)]) {
            [self.delegate dataManager:self didFailDownloadingWithErrorTitle:title andMessage:message];
        }
    });
}

#pragma mark - Scaling image

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0.0f, 0.0f, newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
