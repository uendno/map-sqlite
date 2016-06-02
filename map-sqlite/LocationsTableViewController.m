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

@interface _LocationsTableViewController () <MapViewDelegate> {
    Location *_selectedLocation;
    GMSPlacePicker *_placePicker;
    GMSPlacesClient *_placesClient;
    BOOL _isWaitingForPlacePicker;
}

@end

@implementation _LocationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation
    // bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //find all data
    DBManager *dbManager = [DBManager getSharedInstance];
    self.locations = [dbManager findAll];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return [self.locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"LocationCell"
                                    forIndexPath:indexPath];
    
    // Configure the cell...
    
    Location *location = self.locations[indexPath.row];
    cell.NameLabel.text = location.name;
    cell.LatLabel.text = [location.latitude stringValue];
    cell.LngLabel.text = [location.longitude stringValue];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedLocation = self.locations[indexPath.row];
    [self performSegueWithIdentifier:@"showLocation" sender:self];
}

// In a storyboard-based application, you will often want to do a little
// preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"showLocation"]) {
        ((MapViewController *)segue.destinationViewController).location =
        _selectedLocation;
        ((MapViewController *)segue.destinationViewController).delegate = self;
    }
}

#pragma mark - MapViewDelegate
- (void)deleteLocationID:(NSNumber *)locationId {
    NSLog(@"%ld", (long)locationId);
    for (Location *location in self.locations) {
        if (location.id == locationId) {
            [self.locations removeObject:location];
            DBManager *dbManager = [DBManager getSharedInstance];
            [dbManager deleteDataWithId:location.id];
            break;
        }
        
    }
    [self.locationTableView reloadData];
}

#pragma mark - Add Data
- (IBAction)addLocation:(id)sender {
    
    if (_isWaitingForPlacePicker == NO) {
        
        _isWaitingForPlacePicker = YES;
        
        _placesClient = [[GMSPlacesClient alloc] init];
        
        
        [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *
                                                  placeLikelihoodList,
                                                  NSError *error) {
            _isWaitingForPlacePicker = NO;
            
            if (error != nil) {
                NSLog(@"Pick Place error %@", [error localizedDescription]);
                return;
            }
            
            if (placeLikelihoodList != nil) {
                GMSPlace *currentPlace =
                [[[placeLikelihoodList likelihoods] firstObject] place];
                
                CLLocationCoordinate2D center;
                
                if (currentPlace != nil) {
                    
                    center = currentPlace.coordinate;
                } else {
                    
                    center = CLLocationCoordinate2DMake(51.5108396, -0.0922251);
                }
                
                CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(
                                                                              center.latitude + 0.001, center.longitude + 0.001);
                CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(
                                                                              center.latitude - 0.001, center.longitude - 0.001);
                GMSCoordinateBounds *viewport =
                [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                     coordinate:southWest];
                
                GMSPlacePickerConfig *config =
                [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
                
                _placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
                
                [_placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
                    if (error != nil) {
                        NSLog(@"Pick Place error %@", [error localizedDescription]);
                        return;
                    }
                    
                    if (place != nil) {
                        
                        Location *location = [[Location alloc] init];
                        location.name = place.name;
                        location.latitude = [[NSNumber alloc] initWithFloat:place.coordinate.latitude];
                        location.longitude = [[NSNumber alloc] initWithFloat:place.coordinate.longitude];
                        
                        DBManager *dbManager = [DBManager getSharedInstance];
                        location.id = [dbManager saveData:location];
                        
                        [self.locations addObject:location];
                        [self.locationTableView reloadData];
                        
                    } else {
                        NSLog(@"No place selected");
                    }
                }];
            }
            
        }];

    }
    }
@end
