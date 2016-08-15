//
//  NuGetClientv3Tests.m
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 8/15/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NuGetClient.h"
#import "FakeWebClient.h"

@interface NuGetClientv3Tests : XCTestCase

@end

@implementation NuGetClientv3Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatErrorsHandlerInvokedIfServiceIndexFails {

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {
            *error = [NSError errorWithDomain:@""
                              code:-1
                              userInfo:@{ NSLocalizedDescriptionKey:@"Something went wrong" }];

            dispatch_semaphore_signal(semaphore);
        }];

    NuGetClient *nugetClient = [NuGetClient createClient:@"fakeurl" webClient:webClient];

    [nugetClient getPackages: @"" errorHandler:^(NSString *error, NSString *errorDetails) {
            XCTAssertEqualObjects(error, @"Cannot access NuGet feed.");
            XCTAssertEqualObjects(errorDetails, @"Something went wrong");
        }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)testThatErrorsHandlerInvokedIfStatusCodeNotOK {

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {
        *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:404 HTTPVersion: nil headerFields:nil];

        dispatch_semaphore_signal(semaphore);
    }];

    NuGetClient *nugetClient = [NuGetClient createClient:@"fakeurl" webClient:webClient];

    [nugetClient getPackages: @"" errorHandler:^(NSString *error, NSString *errorDetails) {
        XCTAssertEqualObjects(error, @"Cannot access NuGet feed.");
        XCTAssertEqualObjects(errorDetails, @"not found");
    }];


    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)testThatErrorsHandlerInvokedIfServiceIndexIsNotValidJSON {

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {
        *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:200 HTTPVersion: nil headerFields:nil];
        *data = [@"invalid json" dataUsingEncoding:NSUTF8StringEncoding];

        dispatch_semaphore_signal(semaphore);
    }];

    NuGetClient *nugetClient = [NuGetClient createClient:@"fakeurl" webClient:webClient];

    [nugetClient getPackages: @"" errorHandler:^(NSString *error, NSString *errorDetails) {
        XCTAssertEqualObjects(error, @"Malformed response.");
        XCTAssertNotNil(errorDetails);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)testThatErrorsHandlerInvokedIfJSONNotADictionary {

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {
        *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:200 HTTPVersion: nil headerFields:nil];
        *data = [@"[1, 2, 3]" dataUsingEncoding:NSUTF8StringEncoding];

        dispatch_semaphore_signal(semaphore);
    }];

    NuGetClient *nugetClient = [NuGetClient createClient:@"fakeurl" webClient:webClient];

    [nugetClient getPackages: @"" errorHandler:^(NSString *error, NSString *errorDetails) {
        XCTAssertEqualObjects(error, @"Unexpected response format.");
        XCTAssertNotNil(errorDetails, @"The format of the service index is invalid");
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)DISABLED_testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
