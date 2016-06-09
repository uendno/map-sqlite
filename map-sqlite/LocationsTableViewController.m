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
#import "constants.h"

#import "AFNetworking.h"

@interface _LocationsTableViewController () <MapViewDelegate> {
    Location *_selectedLocation;
    GMSPlacePicker *_placePicker;
    GMSPlacesClient *_placesClient;
    BOOL _isWaitingForPlacePicker;
    LocationCell *_sampleCell;
  
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
    
    // find all data
    self.locations = [[NSMutableArray alloc] init];
    
    //refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor darkTextColor];
    [self.refreshControl addTarget: self action:@selector(loadDataFromServer) forControlEvents:UIControlEventValueChanged];
    
   
}

- (void)viewWillAppear:(BOOL)animated{
   [self loadDataFromServer];
}

- (void)viewDidAppear:(BOOL)animated{
    
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
    cell.nameLabel.text = location.name;
    cell.addressLine.text = location.addressLine;
    
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

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // get a sample cell
    if (!_sampleCell) {
        _sampleCell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
    }
    
    // set it's data
    Location *location = self.locations[indexPath.row];
    _sampleCell.nameLabel.text = location.name;
    _sampleCell.addressLine.text = location.addressLine;
    
    [_sampleCell layoutIfNeeded];
    
    // calulate the height of content view
    CGFloat height =
    [_sampleCell.contentView
     systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // set height for cell = height of content view + height of separator (1.0f)
    return height + 1.0f;
}

#pragma mark - MapViewDelegate
- (void)deleteLocationID:(NSString *)locationId {
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
    
    NSString *deleteUrl = [API_URL stringByAppendingString:locationId];
    
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"DELETE" URLString:deleteUrl parameters:nil error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            
            NSDictionary *result = (NSDictionary *)responseObject;
            
            if ([[result valueForKey:@"success" ] boolValue] == YES) {
                
                DBManager *dbManager = [DBManager getSharedInstance];
                [dbManager setModifiedDate:result[@"modified_since"]];
                
                for (Location *location in self.locations) {
                    if ([location.id isEqualToString:locationId]) {
                        
                        [dbManager deleteDataWithId:location.id];
                        [self.locations removeObject:location];
                        
                        
                        break;
                    }
                }
                
                [self.locationTableView reloadData];

            } else {
                NSLog(@"%@", result[@"message"]);
            }
        }
    }];
    
    [dataTask resume];

    
    
   
    }

#pragma mark - Change data
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
                        location.addressLine = place.formattedAddress;
                        location.latitude =
                        [[NSNumber alloc] initWithFloat:place.coordinate.latitude];
                        location.longitude =
                        [[NSNumber alloc] initWithFloat:place.coordinate.longitude];
                        
                        
                        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
                        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
                        
                        NSDictionary *postData = @{@"name" : location.name,
                                                   @"address" : location.addressLine,
                                                   @"latitude" : location.latitude,
                                                   @"longitude" : location.longitude};
                        
                        NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:API_URL parameters:postData error:nil];
                        
                        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                            
                            if (error) {
                                NSLog(@"Error: %@", error);
                            } else {
                                
                                NSDictionary *result = (NSDictionary *)responseObject;
                                
                                if ([[result valueForKey:@"success" ] boolValue] == YES) {
                                    
                                    location.id = result[@"_id"];
                                    DBManager *dbManager = [DBManager getSharedInstance];
                                    [dbManager saveData:location];
                                    
                                    
                                    [dbManager setModifiedDate:result[@"modified_since"]];
                                    
                                    [self.locations addObject:location];
                                    [self.locationTableView reloadData];
                                }
                                
                                
                            }
                        }];
                        
                        [dataTask resume];
                        
                    } else {
                        NSLog(@"No place selected");
                    }
                }];
            }
            
        }];
    }
}

- (void)loadDataFromServer {
    
    DBManager *dbmanager = [DBManager getSharedInstance];
    
    //get last modified late in local db
    NSString *date = [dbmanager getModifiedDate];
    NSLog(@"DATE: %@", date);
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
    
   
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:API_URL parameters:nil error:nil];
   
    [request setValue:date forHTTPHeaderField:@"if_modified_since"];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [self.refreshControl endRefreshing];
        
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            
            NSDictionary *result = (NSDictionary *)responseObject;
            
            if ([[result valueForKey:@"success"] boolValue]== YES) {
                NSArray *data = [result objectForKey:@"data"];
                
                if (data != nil) {
                    
                    [dbmanager deleteAllData];
                    self.locations = [[NSMutableArray alloc] init];
                    
                    NSLog(@"Got data");
                    
                    for (NSDictionary *locationDict in data) {
                        Location *location = [[Location alloc ]init];
                        location.id = locationDict[@"_id"];
                        location.name = locationDict[@"name"];
                        location.addressLine = locationDict[@"address"];
                        location.latitude = locationDict[@"latitude"];
                        location.longitude = locationDict[@"longitude"];
                        
                        [self.locations addObject:location];
                        [dbmanager saveData:location];
                        
                    }
                    
                  
                    [dbmanager setModifiedDate: [result valueForKey:@"modified_since"]];
                    
                    [self.tableView reloadData];
                } else {
                    //null data
                    NSLog(@"Null data");
                }
                
            } else {
                NSLog(@"%@", [result valueForKey:@"message"]);
                self.locations = [dbmanager findAll];
                [self.tableView reloadData];
            }
            
            
        }
    }];
    
    [dataTask resume];
}

@end
