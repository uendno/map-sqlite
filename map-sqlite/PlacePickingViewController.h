//
//  PlacePickingViewController.h
//  map-sqlite
//
//  Created by Thang Tran on 6/2/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface PlacePickingViewController : UIViewController
@property (strong, nonatomic) IBOutlet GMSPlacePicker *placePicker;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

@end
