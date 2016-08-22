//
//  NuGetClient.m
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "NuGetClient.h"
#import "NuGetClientv3.h"

@implementation NuGetClient

- (id)initWithFeed: (NSString *)feed webClient:(WebClient *) webClient  {
    if ((self = [super init])) {
        _feed = feed;
        _webClient = webClient;
    }
    return self;
}

+ (NuGetClient *) createClient:(NSString *)feed webClient:(WebClient *)webClient {
    return [[NuGetClientv3 alloc] initWithFeed:feed webClient:webClient];
}

- (void)getPackages:(NSString*)filter successHandler:(packagesCompletionBlock)successHandler errorHandler:(errorCompletionBlock)errorHandler {
    // TODO: throw 'NotImpementedException/ClassIsAbstractException`?
}

- (NSArray *)getPackageVersions:(NSString *)packageId {
    // TODO: throw 'NotImpementedException/ClassIsAbstractException`?
    return nil;
}

@end
