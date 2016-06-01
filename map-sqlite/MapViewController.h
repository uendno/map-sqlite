//
//  MapViewController.h
//  map-sqlite
//
//  Created by Thang Tran on 6/1/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
@import GoogleMaps;

@interface MapViewController : UIViewController <GMSMapViewDelegate>

@property (nonatomic, strong) Location *location;

@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

@end

