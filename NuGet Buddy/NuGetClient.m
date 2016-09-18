//
//  NuGetClient.m
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "NuGetClient.h"
#import "NuGetClientv3.h"

@implementation NuGetClient

- (id)initWithFeed: (NSString *)feed webClient:(WebClient *) webClient  {
    if ((self = [super init])) {
        _feed = feed;
        _webClient = webClient;
    }
    return self;
}

+ (NuGetClient *) createClient:(NSString *)feed webClient:(WebClient *)webClient {
    return [[NuGetClientv3 alloc] initWithFeed:feed webClient:webClient];
}

+ (NSString *) URLEncodeString:(NSString *)urlPortion {
    NSMutableString * output = [NSMutableString string];

    for (int i = 0; i < [urlPortion length]; ++i) {
        const unsigned char thisChar = [urlPortion characterAtIndex:i];
        if (thisChar == ' '){
            [output appendString:@"%20"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (void)getPackages:(NSString*)filter successHandler:(packagesCompletionBlock)successHandler errorHandler:(errorCompletionBlock)errorHandler {
    // TODO: throw 'NotImpementedException/ClassIsAbstractException`?
}

- (NSArray *)getPackageVersions:(NSString *)packageId {
    // TODO: throw 'NotImpementedException/ClassIsAbstractException`?
    return nil;
}

@end
