//
//  FakeWebClient.h
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 8/15/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "WebClient.h"

typedef void (^requestCompletionBlock)(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error);

@interface FakeWebClient : WebClient

-(id)initWithHandler:(requestCompletionBlock) requestHandler;

@end
