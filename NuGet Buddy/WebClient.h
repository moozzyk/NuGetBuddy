//
//  WebClient.h
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 8/11/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebClient : NSObject

- (void)get:(NSString*)urlString;

@end
