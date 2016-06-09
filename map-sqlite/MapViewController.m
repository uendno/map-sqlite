//
//  MapViewController.m
//  map-sqlite
//
//  Created by Thang Tran on 6/1/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

#import "MapViewController.h"
#import "InfoWindow.h"
#import "DBManager.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.location.name;
    
    GMSCameraPosition *camera =
    [GMSCameraPosition cameraWithLatitude:[self.location.latitude floatValue]
                                longitude:[self.location.longitude floatValue]
                                     zoom:15];
    
    self.mapView.delegate = self;
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position =
    CLLocationCoordinate2DMake([self.location.latitude floatValue],
                               [self.location.longitude floatValue]);
    marker.infoWindowAnchor = CGPointMake(1.85, 0);
    marker.map = self.mapView;
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    
    InfoWindow *infoWindow =
    [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil]
     objectAtIndex:0];
    infoWindow.nameLabel.text = self.location.name;
    infoWindow.latitude.text = [self.location.latitude stringValue];
    infoWindow.longitude.text = [self.location.longitude stringValue];
    return infoWindow;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little
 preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)deleteLocation:(id)sender {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Delete location"
                                message:@"Are you sure want to delete this location?"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction
                              actionWithTitle:@"YES"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction *action) {
                                  
                                  if ([self.delegate
                                       respondsToSelector:@selector(deleteLocationID:)]) {
                                      [self.delegate deleteLocationID:self.location.id];
                                      
                                      // back to the root view
                                      [self.navigationController
                                       popToRootViewControllerAnimated:YES];
                                  }
                                  
                              }];
    
    UIAlertAction *cancel =
    [UIAlertAction actionWithTitle:@"NO"
                             style:UIAlertActionStyleCancel
                           handler:nil];
    
    [alert addAction:confirm];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
