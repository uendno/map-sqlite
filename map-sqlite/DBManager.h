//
//  DBManager.h
//  map-sqlite
//
//  Created by Thang Tran on 5/30/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject {
    NSString *databasePath;
}

+ (DBManager *)getSharedInstance;
-(BOOL) createDB;
-(BOOL) saveData: (NSNumber *)lat lng:(NSNumber *)lng name:(NSString *) name;
-(NSArray *)findById: (NSNumber *)id;

@end
