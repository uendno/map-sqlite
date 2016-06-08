//
//  Location.h
//  map-sqlite
//
//  Created by Thang Tran on 6/1/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject

@property (strong, nonatomic) NSString *id;

@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) NSNumber *latitude;

@property (strong, nonatomic) NSNumber *longitude;

@property (strong, nonatomic) NSString *addressLine;

@end
