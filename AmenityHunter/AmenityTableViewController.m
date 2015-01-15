//
//  AmenityTableViewController.m
//  AmenityHunter
//
//  Created by emi on 21/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import "AmenityTableViewController.h"
#import "AmenityMapViewController.h"

@interface AmenityTableViewController ()

@property(nonatomic, strong) NSArray *amenityCategories;
@property(nonatomic, strong) NSArray *amenityTypes;

@end

@implementation AmenityTableViewController

#pragma mark - ACCESSORS

- (NSArray *)amenityCategories
{
    if (!_amenityCategories)
    {
        _amenityCategories = @[ @"Sustenance", @"Transportation", @"Financial", @"Entertainment", @"Others" ];
    }

    return _amenityCategories;
}

- (NSArray *)amenityTypes
{
    if (!_amenityTypes)
    {
        NSArray *sustenanceAmenities = @[ @"bar", @"cafe", @"fast_food", @"ice_cream", @"pub", @"restaurant" ];

        NSArray *transportationAmenities =
            @[ @"bicycle_rental", @"bus_station", @"car_rental", @"fuel", @"parking", @"taxi" ];

        NSArray *financialAmenities = @[ @"atm", @"bank" ];

        NSArray *entertainmentAmenities = @[ @"arts_centre", @"cinema", @"theatre" ];

        NSArray *otherAmenities = @[ @"marketplace", @"post_office", @"toilets" ];

        _amenityTypes = @[
            sustenanceAmenities,
            transportationAmenities,
            financialAmenities,
            entertainmentAmenities,
            otherAmenities
        ];
    }

    return _amenityTypes;
}

#pragma mark - LIFECYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation
    // bar for this view
    // controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
// Return the number of sections.

#warning INCOMPLETE IMPLEMENTATION.

    return [self.amenityCategories count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
// Return the number of rows in the section.

#warning INCOMPLETE IMPLEMENTATION.

    return [self.amenityTypes[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AmenityTableCell" forIndexPath:indexPath];

    // Configure the cell...
    cell.textLabel.text = self.amenityTypes[indexPath.section][indexPath.row];

#warning INCOMPLETE IMPLEMENTATION.

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.amenityCategories[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedAmenity = self.amenityTypes[indexPath.section][indexPath.row];

    [self setAmenityInMapController:selectedAmenity];
}

#pragma mark - UTILITY METHODS

- (void)setAmenityInMapController:(NSString *)selectedAmenity
{
    id detailViewController = [self.splitViewController.viewControllers lastObject];

    if ([detailViewController isKindOfClass:[AmenityMapViewController class]])
    {
        ((AmenityMapViewController *)detailViewController).selectedAmenityType = selectedAmenity;
    }
}

@end
