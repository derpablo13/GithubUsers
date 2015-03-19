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

static NSString * const NETWORK_ERROR_TITLE = @"Network error";
static NSString * const DOWNLOAD_USERS_DATA_ERROR_MESSAGE = @"Can not download users data.\nPlease try again.";
static NSString * const DOWNLOAD_IMAGE_ERROR_MESSAGE = @"Can not download user's avatar image.\nPlease try again.";
static NSString * const PARSE_USERS_DATA_ERROR_TITLE = @"Parsing error";
static NSString * const PARSE_USERS_DATA_ERROR_MESSAGE = @"Can not parse GitHub users data.\nPlease try again.";
static NSString * const NO_USERS_DATA_ERROR_TITLE = @"No users data";
static NSString * const NO_USERS_DATA_ERROR_MESSAGE = @"Currently no GitHub users data available.\nPlease try again.";

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

- (void)downloadGithubUsersDataWithCompletionBlock:(void (^)(NSArray *usersData, NSError *error, NSString *errorTitle, NSString *errorMessage))completionBlock {
    if (!completionBlock) {
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:GITHUB_USERS_URL]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:self.downloadUsersListQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   // Clear previous users data objects.
                                   [self.usersData removeAllObjects];
                                   
                                   if (error || !data) {
                                       completionBlock(nil, error, NETWORK_ERROR_TITLE, DOWNLOAD_USERS_DATA_ERROR_MESSAGE);
                                   } else {
                                       NSError *parseError = [self parseUsersListFromData:data];
                                       if (!parseError && self.usersData.count == 0) {
                                           completionBlock(self.usersData, [NSError new], NO_USERS_DATA_ERROR_TITLE, NO_USERS_DATA_ERROR_MESSAGE);
                                       } else {
                                           completionBlock(self.usersData, parseError, PARSE_USERS_DATA_ERROR_TITLE, PARSE_USERS_DATA_ERROR_MESSAGE);
                                       }
                                   }
                               });
                           }];
}

- (NSError *)parseUsersListFromData:(NSData *)data {
    NSError *error;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    
    if (!error) {
        for (id userData in jsonArray) {
            if ([userData isKindOfClass:[NSDictionary class]]) {
                GUUserNode *userNode = [[GUUserNode alloc] initWithLogin:[userData objectForKey:LOGIN_KEY]
                                                                 htmlURL:[userData objectForKey:HTML_URL_KEY]
                                                               avatarURL:[userData objectForKey:AVATAR_URL_KEY]];
                [self.usersData addObject:userNode];
            }
        }
    }
    
    return error;
}

#pragma mark - Download user's avatar image

- (void)downloadCellImageForNodeWithIndex:(NSInteger)index
                             requiredSize:(CGSize)imageSize
                          completionBlock:(void (^)(UIImage *image, NSError *error, NSString *errorTitle, NSString *errorMessage))completionBlock {
    if (!completionBlock) {
        return;
    }
    
    if (![self usersDataContainsIndex:index]) {
        return;
    }
    
    GUUserNode *userNode = [self.usersData objectAtIndex:index];

    if (!userNode.avatarURL) {
        return;
    }
    
    NSBlockOperation *downloadOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSError *error;
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:userNode.avatarURL]
                                                  options:NSDataReadingMappedIfSafe
                                                    error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                userNode.avatarImage = [self imageWithImage:[UIImage imageWithData:imageData]
                                               scaledToSize:imageSize];
            }
            
            completionBlock(userNode.avatarImage, error, NETWORK_ERROR_TITLE, DOWNLOAD_IMAGE_ERROR_MESSAGE);
        });
    }];
    
    userNode.downloadImageOperation = downloadOperation;
    
    [self.downloadImageQueue addOperation:userNode.downloadImageOperation];
}

- (void)cancelDownloadCellImageForNodeWithIndex:(NSInteger)index {
    if ([self usersDataContainsIndex:index]) {
        GUUserNode *userNode = [self.usersData objectAtIndex:index];
        [userNode cancelDownloadImageOperation];
    }
}

#pragma mark - Check does users data array contains index

- (BOOL)usersDataContainsIndex:(NSInteger)index {
    return self.usersData.count > index;
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
