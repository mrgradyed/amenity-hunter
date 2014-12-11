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

@property(nonatomic, strong) NSArray *amenitiesCategories;
@property(nonatomic, strong) NSArray *amenitiesTypes;

@end

@implementation AmenityTableViewController

- (NSArray *)amenitiesCategories
{
    if (!_amenitiesCategories)
    {
        _amenitiesCategories = @[ @"Sustenance" ];
    }
    return _amenitiesCategories;
}

- (NSArray *)amenitiesTypes
{
    if (!_amenitiesTypes)
    {
        _amenitiesTypes = @[
            @[
               @"bar",
               @"biergarten",
               @"cafe",
               @"drinking_water",
               @"fast_food",
               @"food_court",
               @"ice_cream",
               @"pub",
               @"restaurant"
            ]
        ];
    }

    return _amenitiesTypes;
}

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

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *firstSectionFirstRow = [NSIndexPath indexPathForRow:2 inSection:0];

    [self.tableView selectRowAtIndexPath:firstSectionFirstRow
                                animated:NO
                          scrollPosition:UITableViewScrollPositionTop];

    NSString *selectedAmenity =
        self.amenitiesTypes[firstSectionFirstRow.section][firstSectionFirstRow.row];

    [self setAmenityInMapController:selectedAmenity];
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

    return [self.amenitiesCategories count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
// Return the number of rows in the section.

#warning INCOMPLETE IMPLEMENTATION.

    return [self.amenitiesTypes[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"AmenityTableCell" forIndexPath:indexPath];

    // Configure the cell...
    cell.textLabel.text = self.amenitiesTypes[indexPath.section][indexPath.row];

#warning INCOMPLETE IMPLEMENTATION.

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.amenitiesCategories[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedAmenity = self.amenitiesTypes[indexPath.section][indexPath.row];

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
