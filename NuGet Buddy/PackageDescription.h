//
//  PackageDescription.h
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PackageVersion.h"

@interface PackageDescription : NSObject

@property (readonly, strong) NSString *packageId;
@property (readonly, strong) NSString *version;
@property (readonly, strong) NSArray *authors;
@property (readonly, strong) NSArray *versions;

- (id)initPackage:(NSString*)packageId version:(NSString *)version authors:(NSArray *)authors versions:(NSArray *)versions;

@end
