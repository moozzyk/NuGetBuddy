//
//  NuGetClientv3.h
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "NuGetClient.h"

@interface NuGetClientv3 : NuGetClient

- (id)initWithFeed: (NSString *)feed webClient:(WebClient *)webClient;

- (NSArray *)getPackageVersions:(NSString*)packageId;

@end
