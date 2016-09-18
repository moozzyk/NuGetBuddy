//
//  NuGetClient.h
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebClient.h"
#import "PackageDescription.h"

typedef void (^errorCompletionBlock)(NSString *error, NSString *errorDetails);
typedef void (^packagesCompletionBlock)(NSArray *packages);

@interface NuGetClient : NSObject

@property (strong, readonly) NSString *feed;
@property (strong, readonly) WebClient *webClient;

- (id)initWithFeed: (NSString *)feed webClient:(WebClient *)webClient;

+ (NuGetClient *) createClient:(NSString *)feed webClient:(WebClient *)webClient;
+ (NSString *) URLEncodeString:(NSString *)urlPortion;

// TODO: these should be async
- (void)getPackages:(NSString*)filter successHandler:(packagesCompletionBlock)successHandler errorHandler:(errorCompletionBlock)errorHandler;
- (NSArray *)getPackageVersions:(NSString*)packageId;

@end
