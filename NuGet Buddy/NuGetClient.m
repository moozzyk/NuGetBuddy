//
//  NuGetClient.m
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "NuGetClient.h"

@implementation NuGetClient

-(id)initWithFeed: (NSString *)feed {
    if ((self = [super init])) {
        _feed = feed;
    }
    return self;
}

-(NSArray *)getPackages:(NSString*)filter {
    // TODO: throw 'NotImpementedException/ClassIsAbstractException`?
    return nil;
}

-(NSArray *)getPackageVersions:(NSString *)packageId {
    // TODO: throw 'NotImpementedException/ClassIsAbstractException`?
    return nil;
}

@end
