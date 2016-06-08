//
//  DBManager.h
//  map-sqlite
//
//  Created by Thang Tran on 5/30/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Location.h"

@interface DBManager : NSObject {
    NSString *databasePath;
}

+ (DBManager *)getSharedInstance;
-(BOOL) createDB;
-(NSString *) saveData: (Location *)location;
-(NSMutableArray *)findById: (NSNumber *)id;
-(NSMutableArray *)findAll;
-(BOOL) deleteDataWithId: (NSString *)id;
-(BOOL) deleteAllData;
-(BOOL) updateData: (Location *)location;
-(void) setModifiedDate: (NSString *)date;
-(NSString *) getModifiedDate;
@end
