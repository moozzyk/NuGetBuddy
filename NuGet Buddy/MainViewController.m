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
@property (weak) IBOutlet NSTableView *packageVersionsView;
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
}

- (IBAction)tableViewSelectionDidChange:(NSNotification *)notification {
    if (notification.object == self.packagesView) {
        [self.packageVersionsView reloadData];
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];

    if (tableView == self.packagesView) {
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
    }
    else if (tableView == self.packageVersionsView) {
        NSInteger selectedRow = [self.packagesView selectedRow];
        if (selectedRow >= 0 && selectedRow < [self.packageDescriptions count]) {

            PackageDescription *package = self.packageDescriptions[selectedRow];
            PackageVersion *version = [package.versions objectAtIndex:row];
            cellView.textField.stringValue = version.version;
        }
    }

    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.packagesView) {
        return [self.packageDescriptions count];
    }

    if (tableView == self.packageVersionsView) {
        NSInteger selectedRow = [self.packagesView selectedRow];
        if (selectedRow < 0 || selectedRow >= [self.packageDescriptions count]) {
            return 0;
        }

        PackageDescription *package = self.packageDescriptions[selectedRow];
        return package.versions.count;
    }

    return 0;
}

@end

