//
//  NuGetClient.h
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NuGetClient : NSObject

@property (strong, readonly) NSString *feed;

-(id)initWithFeed: (NSString *)feed;

// TODO: these should be async
-(NSArray *)getPackages:(NSString*)filter;
-(NSArray *)getPackageVersions:(NSString*)packageId;

@end
