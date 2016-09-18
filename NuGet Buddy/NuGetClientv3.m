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
- (NSString *)getSearchQueryServiceUrl;
+ (NSArray *)parsePackages:(NSDictionary *)packagesJson;

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

- (NSString *)getSearchQueryServiceUrl {

    NSArray *resources = [self.serviceIndex objectForKey:@"resources"];
    if (!resources) {
        return nil;
    }

    NSString *searchQueryServiceUrl;

    for (int i = 0; i < [resources count]; i++) {
        if([resources[i] isKindOfClass:[NSDictionary class]]) {
            if ([[resources[i] objectForKey:@"@type"] isEqual: @"SearchQueryService"]) {
                searchQueryServiceUrl = [resources[i] objectForKey:@"@id"];
                if (searchQueryServiceUrl) {
                    break;
                }
            }
        }
    }

    return searchQueryServiceUrl;
}

- (void)getPackages:(NSString*)filter successHandler:(packagesCompletionBlock)successHandler errorHandler:(errorCompletionBlock)errorHandler {
    [self ensureIndex:^void() {

            NSString *tmp = [self getSearchQueryServiceUrl];

            NSMutableString *queryServiceUrl = tmp ? [NSMutableString stringWithString:tmp] : nil;
            if (!queryServiceUrl) {
                errorHandler(@"Unexpected format of service index.", @"Could not get an Url to the query service.");
                return;
            }

            [queryServiceUrl appendString:@"?prerelease=true"];

            if (filter)
            {
                [queryServiceUrl appendString: @"&q="];
                [queryServiceUrl appendString: filter];
            }

            [self.webClient get:queryServiceUrl responseHandler:^void(NSHTTPURLResponse *httpResponse, NSData *data, NSError *error) {

                if (error || httpResponse.statusCode != 200) {
                    errorHandler(@"Cannot read NuGet packages.", error ? error.localizedDescription : [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]);
                } else {
                    NSError *parseError = nil;
                    id packageListJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

                    if (parseError) {
                        errorHandler(@"Malformed package list response.", parseError.localizedDescription);
                        return;
                    }

                    if(![packageListJson isKindOfClass:[NSDictionary class]]) {
                        errorHandler(@"Unexpected package list format.", @"The format of the package list is invalid.");
                        return;
                    }

                    NSArray *packages = [NuGetClientv3 parsePackages:packageListJson];
                    successHandler(packages);
                }
            }];

        }
        errorHandler:(errorCompletionBlock) errorHandler
     ];
}

+ (NSArray *)parsePackages:(NSDictionary *)packagesJson {

    id data = [packagesJson objectForKey:@"data"];
    if (!data || ![data isKindOfClass:[NSArray class]]) {
        NSLog(@"No `data` or `data` not an NSArray");
        return [[NSArray alloc] init];
    }

    NSMutableArray *packages = [[NSMutableArray alloc] initWithCapacity: [data count]];

    for (id package in data)
    {
        if ([package isKindOfClass:[NSDictionary class]]) {
            NSString *packageId = [package objectForKey:@"id"];
            NSString *version = [package objectForKey:@"version"];
            NSArray *authors = [package objectForKey:@"authors"];

            [packages addObject:[[PackageDescription alloc] initPackage:packageId version:version authors:authors]];
        }
    }

    return packages;
}

@end
