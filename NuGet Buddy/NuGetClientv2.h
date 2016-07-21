//
//  NuGetClientv2.h
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "NuGetClient.h"

@interface NuGetClientv2 : NuGetClient

-(NSArray *)getPackages:(NSString*)filter;

@end
