//
//  WebClient.h
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 8/11/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^responseCompletionBlock)(NSHTTPURLResponse *response, NSString *data);
typedef void (^errorCompletionBlock)(NSError *error);

@interface WebClient : NSObject

- (void)get:(NSString*)urlString responseHandler:(responseCompletionBlock)responseHandler errorHandler:(errorCompletionBlock)errorHandler;

@end
