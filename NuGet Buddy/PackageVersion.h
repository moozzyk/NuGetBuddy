//
//  PackageVersion.h
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 9/17/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PackageVersion : NSObject

@property (readonly, strong) NSString *versionId;
@property (readonly, strong) NSString *version;

- (id)init:(NSString*)versionId version:(NSString *)version;

@end
