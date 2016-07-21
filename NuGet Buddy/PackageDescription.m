//
//  PackageDescription.m
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "PackageDescription.h"

@implementation PackageDescription

- (id)initPackage:(NSString*)packageId name:(NSString*)name version:(NSString *)version {
    //TODO: throw/assert on null?
    if ((self = [super init])) {
        _packageId = packageId;
        _name = name;
        _version = version;
    }
    return self;
}

@end
