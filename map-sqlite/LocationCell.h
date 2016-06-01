//
//  LocationCell.h
//  map-sqlite
//
//  Created by Thang Tran on 6/1/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *NameLabel;
@property (strong, nonatomic) IBOutlet UILabel *LatLabel;
@property (strong, nonatomic) IBOutlet UILabel *LngLabel;

@end
