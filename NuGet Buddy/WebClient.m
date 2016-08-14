//
//  WebClient.m
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 8/11/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "WebClient.h"

@implementation WebClient

- (void)get:(NSString *)urlString
    responseHandler:(responseCompletionBlock)responseHandler
    errorHandler:(errorCompletionBlock)errorHandler {

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:urlString]
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSString *contents = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                responseHandler((NSHTTPURLResponse *)response, contents);
            }
            else {
                errorHandler(error);
            }
        }] resume];
}

@end
