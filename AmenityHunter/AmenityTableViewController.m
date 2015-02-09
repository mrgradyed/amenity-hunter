//
//  AmenityTableViewController.m
//  AmenityHunter
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE
//  SOFTWARE.
//
//  Created by emi on 21/11/14.
//
//

#import "AmenityTableViewController.h"
#import "AmenityMapViewController.h"

@interface AmenityTableViewController ()

@property(nonatomic, strong) NSArray *amenityCategories;
@property(nonatomic, strong) NSArray *amenityTypes;
@property(nonatomic, strong) NSString *selectedAmenity;

@end

@implementation AmenityTableViewController

#pragma mark - ACCESSORS

- (NSArray *)amenityCategories
{
    if (!_amenityCategories)
    {
        _amenityCategories = @[
            NSLocalizedString(@"Sustenance", nil),
            NSLocalizedString(@"Transportation", nil),
            NSLocalizedString(@"Financial", nil),
            NSLocalizedString(@"Entertainment", nil),
            NSLocalizedString(@"Others", nil)
        ];
    }

    return _amenityCategories;
}

- (NSArray *)amenityTypes
{
    if (!_amenityTypes)
    {
        NSArray *sustenanceAmenities = @[ @"bar", @"cafe", @"fast_food", @"ice_cream", @"pub", @"restaurant" ];

        NSArray *transportationAmenities = @[ @"bicycle_rental", @"car_rental", @"fuel", @"parking", @"taxi" ];

        NSArray *financialAmenities = @[ @"atm", @"bank" ];

        NSArray *entertainmentAmenities = @[ @"cinema", @"theatre" ];

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
    self.clearsSelectionOnViewWillAppear = YES;
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

    return self.amenityCategories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.

    return [self.amenityTypes[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AmenityTableCell" forIndexPath:indexPath];

    // Configure the cell...
    cell.textLabel.text = NSLocalizedString(self.amenityTypes[indexPath.section][indexPath.row], nil);

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.amenityCategories[section];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedAmenity = self.amenityTypes[indexPath.section][indexPath.row];
}

#pragma mark - SEGUES

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id detailViewController = segue.destinationViewController;

    if ([detailViewController isKindOfClass:[UINavigationController class]])
    {
        detailViewController = ((UINavigationController *)detailViewController).topViewController;
    }

    if ([detailViewController isKindOfClass:[AmenityMapViewController class]])
    {
        ((AmenityMapViewController *)detailViewController).selectedAmenityType = self.selectedAmenity;
    }
}

@end
