//
//  WebClient.m
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 8/11/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "WebClient.h"

@implementation WebClient

- (void)get:(NSString *)urlString {
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:urlString]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                // handle response
            }] resume];
}

@end
