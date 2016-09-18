//
//  MainViewController.m
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "MainViewController.h"
#import "NuGetClient.h"

@interface MainViewController ()
@property (weak) IBOutlet NSComboBoxCell *feedsCombo;
@property (weak) IBOutlet NSTableView *packagesView;
@property (weak) IBOutlet NSSearchField *filter;
@property (atomic, strong) NSArray *packageDescriptions;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.feedsCombo selectItemAtIndex:0];
    [self filterPackages:nil];
}

- (IBAction)filterPackages:(id)sender {
    WebClient *webClient = [[WebClient alloc] init];
    NuGetClient *nugetClient = [NuGetClient createClient:[self.feedsCombo stringValue] webClient:webClient];
    [nugetClient getPackages: [self.filter stringValue]
        successHandler:^(NSArray *packages) {
            for (PackageDescription *p in packages) {
                NSLog(@"%@ %@ %@", p.packageId, p.version, p.authors);
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                self.packageDescriptions = packages;
                [self.packagesView reloadData];
            });
        }
        errorHandler:^(NSString *error, NSString *errorDetails) {
            NSLog(@"%@ %@", error, errorDetails);
            NSAlert *alert = [NSAlert alertWithMessageText:error defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", errorDetails];

            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];

        }
     ];


    /* //TODO: remove
    WebClient *webClient = [[WebClient alloc] init];
    [webClient get:[self.feedsCombo stringValue]
        responseHandler:^void (NSHTTPURLResponse *httpResponse, NSString *data) {
            NSLog(@"response status code: %ld data: %@", (long)[httpResponse statusCode], data);
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        }
        errorHandler:^(NSError *error) {

            dispatch_async(dispatch_get_main_queue(), ^{

                NSAlert *alert = [NSAlert alertWithMessageText:@"Error loading NuGet feed." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:[error localizedDescription]];

                [alert setAlertStyle:NSWarningAlertStyle];
                [alert runModal];
            });

            NSLog(@"error: %@", [error localizedDescription]);
        }];
     */

    /* dispatch on the UI thread (http://www.localwisdom.com/blog/2013/07/blocks-in-objective-c-performing-asynchronous-urlrequests-using-an-nsoperationqueue/): 
     dispatch_async(dispatch_get_main_queue(), ^{
        if (!success) {
            NSLog(@"Could not set label! %@ %@", error, [error localizedDescription]);
        } else {
            [label setText:labelText];
        }
     });
     */
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];

    if([tableColumn.identifier isEqualToString:@"PackageId"]) {
        PackageDescription *packageDescription = [self.packageDescriptions objectAtIndex:row];
        cellView.textField.stringValue = packageDescription.packageId;
    }
    else if([tableColumn.identifier isEqualToString:@"Version"]) {
        PackageDescription *packageDescription = [self.packageDescriptions objectAtIndex:row];
        cellView.textField.stringValue = packageDescription.version;
    }
    else if([tableColumn.identifier isEqualToString:@"Authors"]) {
        PackageDescription *packageDescription = [self.packageDescriptions objectAtIndex:row];
        NSString *authors = [packageDescription.authors componentsJoinedByString:@", "];
        cellView.textField.stringValue = authors;
    }

    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.packageDescriptions count];
}

- (IBAction)fitlerPackages:(id)sender {
}
@end

