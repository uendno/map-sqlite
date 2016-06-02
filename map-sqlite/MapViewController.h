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
@class MapViewController;

@protocol MapViewDelegate <NSObject>

@optional
- (void)deleteLocationID:(NSNumber *)locationId;

@end

@interface MapViewController : UIViewController <GMSMapViewDelegate>

@property (nonatomic, strong) Location *location;

@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

@property (weak, nonatomic) id<MapViewDelegate> delegate;

- (IBAction)deleteLocation:(id)sender;

@end

