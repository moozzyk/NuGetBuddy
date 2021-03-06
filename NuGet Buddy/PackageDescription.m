//
//  PackageDescription.m
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "PackageDescription.h"

@implementation PackageDescription

- (id)initPackage:(NSString*)packageId version:(NSString *)version authors:(NSArray *)authors versions:(NSArray *)versions{
    if ((self = [super init])) {
        _packageId = packageId;
        _version = version;
        _authors = authors;
        _versions = versions;
    }
    return self;
}

@end
