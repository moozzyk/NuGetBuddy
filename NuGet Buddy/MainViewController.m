//
//  MainViewController.m
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "MainViewController.h"
#include "WebClient.h"

@interface MainViewController ()
@property (weak) IBOutlet NSComboBoxCell *feedsCombo;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.feedsCombo selectItemAtIndex:0];
}

- (IBAction)showPackages:(id)sender {

    /* TODO: remove
    WebClient *webClient = [[WebClient alloc] init];
    [webClient get:[self.feedsCombo stringValue]
        responseHandler:^void (NSHTTPURLResponse *httpResponse, NSString *data) {
            NSLog(@"response status code: %ld data: %@", (long)[httpResponse statusCode], data);
        }
        errorHandler:^(NSError *error) {
            NSLog(@"error: %@", [error localizedDescription]);
        }];
     */
}

@end

