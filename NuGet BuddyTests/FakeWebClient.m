//
//  FakeWebClient.m
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 8/15/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "FakeWebClient.h"

@interface FakeWebClient()

@property (strong, readonly) requestCompletionBlock requestHandler;

@end

@implementation FakeWebClient

-(id)initWithHandler:(requestCompletionBlock) requestHandler {
    if ((self = [super init])) {
        _requestHandler = requestHandler;
    }
    return self;
}

-(void)get:(NSString*)urlString responseHandler:(completionHandler)responseHandler {
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data;

    self.requestHandler(urlString, &response, &data, &error);
    responseHandler(response, data, error);
}

@end
