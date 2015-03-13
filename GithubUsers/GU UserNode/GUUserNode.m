//
//  GUUserNode.m
//  GithubUsers
//
//  Created by parak on 3/12/15.
//  Copyright (c) 2015 parak. All rights reserved.
//

#import "GUUserNode.h"

@interface GUUserNode ()

@property NSString *login;
@property NSString *htmlURL;
@property NSString *avatarURL;

@end

@implementation GUUserNode

- (instancetype)initWithLogin:(NSString *)login
                      htmlURL:(NSString *)htmlURL
                    avatarURL:(NSString *)avatarURL {
    self = [super init];
    if (self) {
        self.login = login;
        self.htmlURL = htmlURL;
        self.avatarURL = avatarURL;
        self.avatarImage = nil;
    }
    return self;
}

- (void)cancelDownloadImageOperation {
    if (self.downloadImageOperation) {
        [self.downloadImageOperation cancel];
    }
}

@end
