//
//  LocationsTableViewController.m
//  map-sqlite
//
//  Created by Thang Tran on 6/1/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

#import "LocationsTableViewController.h"
#import "Location.h"
#import "DBManager.h"
#import "LocationCell.h"
#import "MapViewController.h"

@interface _LocationsTableViewController () {
    Location *_selectedLocation;
}

@end

@implementation _LocationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    DBManager *dbManager = [DBManager getSharedInstance];

    Location *location = [[Location alloc] init];
    
    location.name = @"Hanoi";
    location.latitude = @21.0278;
    location.longitude = @105.8342;
    [dbManager saveData:location];
    
    location.name = @"Ho Chi Minh";
    location.latitude = @10.762622;
    location.longitude = @106.660172;
    [dbManager saveData:location];
    
    location.name = @"Da Nang";
    location.latitude = @16.047079;
    location.longitude = @108.206230;
    [dbManager saveData:location];
    

    self.locations = [dbManager findAll];
    NSLog(@"data size: %ld",[self.locations count] );
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.locations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    Location *location = self.locations[indexPath.row];
    cell.NameLabel.text = location.name;
    cell.LatLabel.text = [location.latitude stringValue] ;
    cell.LngLabel.text = [location.longitude stringValue];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedLocation = self.locations[indexPath.row];
    [self performSegueWithIdentifier:@"showLocation" sender:self];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    

    if ([[segue identifier] isEqualToString:@"showLocation"])
    {
        ((MapViewController *)segue.destinationViewController).location = _selectedLocation;
    }
}


@end
