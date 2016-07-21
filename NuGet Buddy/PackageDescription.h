//
//  PackageDescription.h
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PackageDescription : NSObject

@property (readonly, strong) NSString *packageId;
@property (readonly, strong) NSString *name;
@property (readonly, strong) NSString *version;

- (id)initPackage:(NSString*)packageId name:(NSString*)name version:(NSString *)version;

@end
