//
//  AmenitySplitViewController.m
//  AmenityHunter
//
//  Created by emi on 22/01/15.
//  Copyright (c) 2015 Emiliano D'Alterio. All rights reserved.
//

#import "AmenitySplitViewController.h"

@interface AmenitySplitViewController () <UISplitViewControllerDelegate>

@end

@implementation AmenitySplitViewController

#pragma mark - Life-cycle

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.delegate = self;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
    collapseSecondaryViewController:(UIViewController *)secondaryViewController
          ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    return YES;
}


@end
