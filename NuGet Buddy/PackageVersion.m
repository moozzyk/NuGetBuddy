//
//  PackageVersion.m
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 9/17/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "PackageVersion.h"

@implementation PackageVersion

- (id)init:(NSString*)versionId version:(NSString *)version {
    if ((self = [super init])) {
        _versionId = versionId;
        _version = version;
    }
    return self;
}


@end
