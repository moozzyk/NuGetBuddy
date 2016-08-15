//
//  NuGetClientv3.m
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "NuGetClientv3.h"

@interface NuGetClientv3()

@property (atomic, strong) NSDictionary *serviceIndex;

- (void)ensureIndex:(void(^)())continuation errorHandler:(errorCompletionBlock)errorHandler;

@end

@implementation NuGetClientv3

- (id)initWithFeed: (NSString *)feed webClient:(WebClient *)webClient  {
    return [super initWithFeed:feed webClient:webClient];
}

- (void)ensureIndex:(void(^)())continuation errorHandler:(errorCompletionBlock)errorHandler {
    if (!self.serviceIndex) {
        [self.webClient get:self.feed responseHandler:^void(NSHTTPURLResponse *httpResponse, NSData *data, NSError *error) {

            if (error || httpResponse.statusCode != 200) {
                errorHandler(@"Cannot access NuGet feed.", error ? error.localizedDescription : [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]);
            } else {
                NSError *parseError = nil;
                id index = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

                if (parseError) {
                    errorHandler(@"Malformed response.", parseError.localizedDescription);
                    return;
                }

                if(![index isKindOfClass:[NSDictionary class]]) {
                    errorHandler(@"Unexpected response format.", @"The format of the service index is invalid.");
                    return;
                }

                self.serviceIndex = index;

                continuation();
            }
        }];
    } else {
        continuation();
    }
}

- (NSArray *)getPackages:(NSString*)filter errorHandler:(errorCompletionBlock)errorHandler {
    [self ensureIndex:^void() { NSLog(@"Completed without error"); }
         errorHandler:(errorCompletionBlock) errorHandler
     ];
    return nil;
}

- (NSArray *)getPackageVersions:(NSString *)packageId {
    return nil;
}

@end
