//
//  LocationsTableViewController.h
//  map-sqlite
//
//  Created by Thang Tran on 6/1/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface _LocationsTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) IBOutlet UITableView *locationTableView;
- (IBAction)addLocation:(id)sender;


@end
