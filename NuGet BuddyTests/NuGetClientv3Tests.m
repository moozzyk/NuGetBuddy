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

- (void)testThatErrorsHandlerInvokedIfGettingServiceIndexFails {

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {
            *error = [NSError errorWithDomain:@""
                              code:-1
                              userInfo:@{ NSLocalizedDescriptionKey:@"Something went wrong" }];
        }];

    NuGetClient *nugetClient = [NuGetClient createClient:@"fakeurl" webClient:webClient];

    [nugetClient getPackages: @"" successHandler:^(NSArray *packages){} errorHandler:^(NSString *error, NSString *errorDetails) {
        XCTAssertEqualObjects(error, @"Cannot access NuGet feed.");
        XCTAssertEqualObjects(errorDetails, @"Something went wrong");

        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)testThatErrorsHandlerInvokedIfStatusCodeNotOK {

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {
        *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:404 HTTPVersion: nil headerFields:nil];
    }];

    NuGetClient *nugetClient = [NuGetClient createClient:@"fakeurl" webClient:webClient];

    [nugetClient getPackages: @"" successHandler:^(NSArray *packages){} errorHandler:^(NSString *error, NSString *errorDetails) {
        XCTAssertEqualObjects(error, @"Cannot access NuGet feed.");
        XCTAssertEqualObjects(errorDetails, @"not found");

        dispatch_semaphore_signal(semaphore);
    }];


    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)testThatErrorsHandlerInvokedIfServiceIndexIsNotValidJSON {

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {
        *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:200 HTTPVersion: nil headerFields:nil];
        *data = [@"invalid json" dataUsingEncoding:NSUTF8StringEncoding];
    }];

    NuGetClient *nugetClient = [NuGetClient createClient:@"fakeurl" webClient:webClient];

    [nugetClient getPackages: @"" successHandler:^(NSArray *packages){} errorHandler:^(NSString *error, NSString *errorDetails) {
        XCTAssertEqualObjects(error, @"Malformed response.");
        XCTAssertNotNil(errorDetails);

        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)testThatErrorsHandlerInvokedIfJSONNotADictionary {

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {
        *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:200 HTTPVersion: nil headerFields:nil];
        *data = [@"[1, 2, 3]" dataUsingEncoding:NSUTF8StringEncoding];
    }];

    NuGetClient *nugetClient = [NuGetClient createClient:@"fakeurl" webClient:webClient];

    [nugetClient getPackages: @"" successHandler:^(NSArray *packages){} errorHandler:^(NSString *error, NSString *errorDetails) {
        XCTAssertEqualObjects(error, @"Unexpected response format.");
        XCTAssertEqualObjects(errorDetails, @"The format of the service index is invalid.");

        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)testThatErrorInvokedIfServiceIndexDoesNotContainSearchQueryServiceUrl {

    NSString *indexWithoutResources = @"{ \"version\": \"3.0.0-beta.1\" }";
    NSString *indexWithoutQueryService =
        @"{ \
            \"version\": \"3.0.0-beta.1\", \
            \"resources\": [ \
                { \
                    \"@id\": \"https://api-v2v3search-0.nuget.org/autocomplete\", \
                    \"@type\": \"SearchAutocompleteService\", \
                    \"comment\": \"Autocomplete endpoint of NuGet Search service (primary)\" \
                }, \
            ],\
         }";

    NSString *indexWithoutQueryServiceUrl =
    @"{ \
        \"version\": \"3.0.0-beta.1\", \
        \"resources\": [ \
            { \
                \"@type\": \"SearchQueryService\", \
                \"comment\": \"Query endpoint of NuGet Search service (primary)\" \
            }, \
        ],\
    }";

    NSArray *serviceIndices = [[NSArray alloc] initWithObjects:indexWithoutResources, indexWithoutQueryService, indexWithoutQueryServiceUrl, nil];

    for (int i = 0; i < [serviceIndices count]; i++) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {

            if ([url containsString:@"index.json"]) {
                *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:200 HTTPVersion: nil headerFields:nil];
                *data = [serviceIndices[i] dataUsingEncoding:NSUTF8StringEncoding];
            } else {
                *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:404 HTTPVersion: nil headerFields:nil];
            }
        }];

        NuGetClient *nugetClient = [NuGetClient createClient:@"http://nuget/v3/index.json" webClient:webClient];

        [nugetClient getPackages: @"" successHandler:^(NSArray *packages){} errorHandler:^(NSString *error, NSString *errorDetails) {
            XCTAssertEqualObjects(error, @"Unexpected format of service index.");
            XCTAssertEqualObjects(errorDetails, @"Could not get an Url to the query service.");
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, 1000);
    }
}

- (void)testThatErrorInvokedIfGettingServiceIndexFails {

    NSString *serviceIndex =
    @"{ \
        \"version\": \"3.0.0-beta.1\", \
        \"resources\": [ \
            { \
                \"@id\": \"https://api-v2v3search-0.nuget.org/query\", \
                \"@type\": \"SearchQueryService\", \
                \"comment\": \"Query endpoint of NuGet Search service (primary)\" \
            }, \
        ] \
    }";

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {

        if ([url containsString:@"index.json"]) {
            *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:200 HTTPVersion: nil headerFields:nil];
            *data = [serviceIndex dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            *error = [NSError errorWithDomain:@""
                            code:-1
                            userInfo:@{ NSLocalizedDescriptionKey:@"Something went wrong" }];
        }
    }];

    NuGetClient *nugetClient = [NuGetClient createClient:@"http://nuget/v3/index.json" webClient:webClient];

    [nugetClient getPackages: @"" successHandler:^(NSArray *packages){} errorHandler:^(NSString *error, NSString *errorDetails) {
        XCTAssertEqualObjects(error, @"Cannot read NuGet packages.");
        XCTAssertEqualObjects(errorDetails, @"Something went wrong");
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, 1000);
}

- (void)testThatErrorInvokedIfGettingServiceIndexReturnStatusCodeNotOK {

    NSString *serviceIndex =
    @"{ \
        \"version\": \"3.0.0-beta.1\", \
        \"resources\": [ \
            { \
                \"@id\": \"https://api-v2v3search-0.nuget.org/query\", \
                \"@type\": \"SearchQueryService\", \
                \"comment\": \"Query endpoint of NuGet Search service (primary)\" \
            }, \
        ] \
    }";

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {

        if ([url containsString:@"index.json"]) {
            *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:200 HTTPVersion: nil headerFields:nil];
            *data = [serviceIndex dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:404 HTTPVersion: nil headerFields:nil];
        }
    }];

    NuGetClient *nugetClient = [NuGetClient createClient:@"http://nuget/v3/index.json" webClient:webClient];

    [nugetClient getPackages: @"" successHandler:^(NSArray *packages) {} errorHandler:^(NSString *error, NSString *errorDetails) {
        XCTAssertEqualObjects(error, @"Cannot read NuGet packages.");
        XCTAssertEqualObjects(errorDetails, @"not found");
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, 1000);

}

- (void) testThatErrorInvokedIfPackageListIsNotValidJSON {
    NSString *serviceIndex =
    @"{ \
        \"version\": \"3.0.0-beta.1\", \
        \"resources\": [ \
            { \
                \"@id\": \"https://api-v2v3search-0.nuget.org/query\", \
                \"@type\": \"SearchQueryService\", \
                \"comment\": \"Query endpoint of NuGet Search service (primary)\" \
            }, \
        ] \
    }";

    NSString *packageList = @"invalid JSON";

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {

        *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:200 HTTPVersion: nil headerFields:nil];

        if ([url containsString:@"index.json"]) {
            *data = [serviceIndex dataUsingEncoding:NSUTF8StringEncoding];
        } else {

            *data = [packageList dataUsingEncoding:NSUTF8StringEncoding];
        }
    }];

    NuGetClient *nugetClient = [NuGetClient createClient:@"http://nuget/v3/index.json" webClient:webClient];

    [nugetClient getPackages: @"" successHandler:^(NSArray *packages){} errorHandler:^(NSString *error, NSString *errorDetails) {
        XCTAssertEqualObjects(error, @"Malformed package list response.");
        XCTAssertNotNil(errorDetails);
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, 1000);
}

- (void) testThatErrorInvokedIfPackageListIsDictionary {
    NSString *serviceIndex =
    @"{ \
        \"version\": \"3.0.0-beta.1\", \
        \"resources\": [ \
            { \
                \"@id\": \"https://api-v2v3search-0.nuget.org/query\", \
                \"@type\": \"SearchQueryService\", \
                \"comment\": \"Query endpoint of NuGet Search service (primary)\" \
            }, \
        ] \
    }";

    NSString *packageList = @"[1, 2, 3]";

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {

        *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:200 HTTPVersion: nil headerFields:nil];

        if ([url containsString:@"index.json"]) {
            *data = [serviceIndex dataUsingEncoding:NSUTF8StringEncoding];
        } else {

            *data = [packageList dataUsingEncoding:NSUTF8StringEncoding];
        }
    }];

    NuGetClient *nugetClient = [NuGetClient createClient:@"http://nuget/v3/index.json" webClient:webClient];

    [nugetClient getPackages: @"" successHandler:^(NSArray *packages){} errorHandler:^(NSString *error, NSString *errorDetails) {
        XCTAssertEqualObjects(error, @"Unexpected package list format.");
        XCTAssertEqualObjects(errorDetails, @"The format of the package list is invalid.");
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, 1000);
}

- (void) testThatPackagesPassedToSuccessHandler {
    NSString *serviceIndex =
    @"{ \
        \"version\": \"3.0.0-beta.1\", \
        \"resources\": [ \
            { \
                \"@id\": \"https://api-v2v3search-0.nuget.org/query\", \
                \"@type\": \"SearchQueryService\", \
                \"comment\": \"Query endpoint of NuGet Search service (primary)\" \
            }, \
        ] \
    }";

    NSString *packageList =
    @"{ \
            \"data\": [ \
                { \
                    \"id\": \"'Allo 'Allo\", \
                    \"version\": \"8.5.1945\", \
                    \"authors\": [ \
                        \"Jeremy Lloyd\", \
                        \"David Croft\" \
                    ], \
                    \"versions\": [\
                        { \
                            \"version\": \"6.6.1944\", \
                            \"@id\": \"version-id-link-6.6.1944\" \
                        }, \
                        { \
                            \"version\": \"8.5.1944\", \
                            \"@id\": \"version-id-link-8.5.1944\" \
                        } \
                    ] \
                }, \
                {\
                    \"id\": \"Mr. Bean\", \
                    \"version\": \"1.0.0-beta1\", \
                    \"authors\": [ \
                        \"Rowan Atkinson\" \
                    ] \
                }, \
            ] \
        }";

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {

        *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:200 HTTPVersion: nil headerFields:nil];

        if ([url containsString:@"index.json"]) {
            *data = [serviceIndex dataUsingEncoding:NSUTF8StringEncoding];
        } else {

            *data = [packageList dataUsingEncoding:NSUTF8StringEncoding];
        }
    }];

    NuGetClient *nugetClient = [NuGetClient createClient:@"http://nuget/v3/index.json" webClient:webClient];

    [nugetClient getPackages: @""
        successHandler:^(NSArray *packages){
            XCTAssertEqual(2, [packages count]);
            PackageDescription *package1 = packages[0];
            XCTAssertEqualObjects(package1.packageId, @"'Allo 'Allo");
            XCTAssertEqualObjects(package1.version, @"8.5.1945");
            NSArray *authors = @[@"Jeremy Lloyd", @"David Croft"];
            XCTAssertEqualObjects(package1.authors, authors);
            XCTAssertEqual(package1.versions.count, 2);

            PackageVersion *version1 = package1.versions[0];
            XCTAssertEqualObjects(version1.version, @"8.5.1944");
            XCTAssertEqualObjects(version1.versionId, @"version-id-link-8.5.1944");

            PackageVersion *version2 = package1.versions[1];
            XCTAssertEqualObjects(version2.version, @"6.6.1944");
            XCTAssertEqualObjects(version2.versionId, @"version-id-link-6.6.1944");

            PackageDescription *package2 = packages[1];
            XCTAssertEqualObjects(package2.packageId, @"Mr. Bean");
            XCTAssertEqualObjects(package2.version, @"1.0.0-beta1");
            authors = @[@"Rowan Atkinson"];
            XCTAssertEqualObjects(package2.authors, authors);
            XCTAssertEqual(package2.versions.count, 0);
        }
        errorHandler:^(NSString *error, NSString *errorDetails) {
            XCTAssertTrue(false);
            dispatch_semaphore_signal(semaphore);
        }];

    dispatch_semaphore_wait(semaphore, 1000);

}

- (void)testThatFilterIsAppendedToQueryStringIfPresent {

    NSString *serviceIndex =
    @"{ \
        \"version\": \"3.0.0-beta.1\", \
        \"resources\": [ \
            { \
                \"@id\": \"https://api-v2v3search-0.nuget.org/query\", \
                \"@type\": \"SearchQueryService\", \
                \"comment\": \"Query endpoint of NuGet Search service (primary)\" \
            }, \
        ] \
    }";

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    __block NSString *queryUrl;

    WebClient *webClient = [[FakeWebClient alloc] initWithHandler:^(NSString *url, NSHTTPURLResponse **response, NSData **data, NSError **error) {

        if ([url containsString:@"index.json"]) {
            *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:200 HTTPVersion: nil headerFields:nil];
            *data = [serviceIndex dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:404 HTTPVersion: nil headerFields:nil];

            queryUrl = url;

            dispatch_semaphore_signal(semaphore);
        }
    }];

    NuGetClient *nugetClient = [NuGetClient createClient:@"http://nuget/v3/index.json" webClient:webClient];

    [nugetClient getPackages: @"moozzyk test" successHandler:^(NSArray *packages) {} errorHandler:^(NSString *error, NSString *errorDetails) { }];

    long result = dispatch_semaphore_wait(semaphore, 1000);
    XCTAssertEqual(0, result);
    XCTAssertEqualObjects(queryUrl, @"https://api-v2v3search-0.nuget.org/query?prerelease=true&q=moozzyk%20test");
}


- (void)DISABLED_testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end


     /*
    NSString *serviceIndex =
    @"{ \
        \"version\": \"3.0.0-beta.1\", \
        \"resources\": [ \
            { \
                \"@id\": \"https://api-v2v3search-0.nuget.org/query\", \
                \"@type\": \"SearchQueryService\", \
                \"comment\": \"Query endpoint of NuGet Search service (primary)\" \
            }, \
            { \
                \"@id\": \"https://api-v2v3search-1.nuget.org/query\", \
                \"@type\": \"SearchQueryService\", \
                \"comment\": \"Query endpoint of NuGet Search service (secondary)\" \
            }, \
            { \
                \"@id\": \"https://api-v2v3search-0.nuget.org/autocomplete\", \
                \"@type\": \"SearchAutocompleteService\", \
                \"comment\": \"Autocomplete endpoint of NuGet Search service (primary)\" \
            }, \
        ], \
        \"@context\": { \
            \"@vocab\": \"http://schema.nuget.org/services#\", \
            \"comment\": \"http://www.w3.org/2000/01/rdf-schema#comment\" \
        } \
    }";*/

