//
//  NuGetClient.h
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebClient.h"

typedef void (^errorCompletionBlock)(NSString *error, NSString *errorDetails);
typedef void (^responseCompletionBlock)(NSHTTPURLResponse *httpResponse, NSString *content);

@interface NuGetClient : NSObject

@property (strong, readonly) NSString *feed;
@property (strong, readonly) WebClient *webClient;

- (id)initWithFeed: (NSString *)feed webClient:(WebClient *)webClient;

+ (NuGetClient *) createClient:(NSString *)feed webClient:(WebClient *)webClient;

// TODO: these should be async
- (NSArray *)getPackages:(NSString*)filter errorHandler:(errorCompletionBlock)errorHandler;
- (NSArray *)getPackageVersions:(NSString*)packageId;

@end
