//
//  MainViewController.m
//  NuGet Buddy
//
//  Created by Pawel Kadluczka on 7/20/16.
//  Copyright © 2016 Pawel Kadluczka. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (weak) IBOutlet NSComboBoxCell *feedsCombo;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.feedsCombo selectItemAtIndex:0];
}

@end
