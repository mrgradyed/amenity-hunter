//
//  AmenityTableViewController.m
//  AmenityHunter
//
//  Created by emi on 21/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import "AmenityTableViewController.h"

@interface AmenityTableViewController ()

@end

@implementation AmenityTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view
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

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.

#warning INCOMPLETE IMPLEMENTATION.

    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"AmenityTableCell" forIndexPath:indexPath];

    // Configure the cell...

    NSLog(@"%s TO DO", __PRETTY_FUNCTION__);

    return cell;
}

@end
