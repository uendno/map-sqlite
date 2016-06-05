//
//  LocationCell.h
//  map-sqlite
//
//  Created by Thang Tran on 6/1/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UILabel *addressLine;

@end
