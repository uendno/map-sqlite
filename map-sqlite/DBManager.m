//
//  DBManager.m
//  map-sqlite
//
//  Created by Thang Tran on 5/30/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//
#import "DBManager.h"

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DBManager

+ (DBManager *)getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL] init];
        NSLog(@"CREATE DB");
        [sharedInstance createDB];
    } else {
        NSLog(@"OPEN DB");
    }
    return sharedInstance;
}
- (BOOL)createDB {
    NSString *docsDir;
    NSArray *dirPath;
    
    // Get the document directory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                  NSUserDomainMask, YES);
    docsDir = dirPath[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc]
                    initWithString:[docsDir stringByAppendingString:@"/locations.db"]];
    
    NSLog(@"%@", databasePath);
    
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:databasePath] == NO) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            char *errMsg;
            char *latlng_stmt = "create table if not exists latlng (_id text primary "
            "key, name text,address text, latitude "
            "float, longitude float)";
            char *version_stmt = "create table if not exists version (_id integer primary key autoincrement, db_name text, modified_since text)";
            if (sqlite3_exec(database, latlng_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"%s", errMsg);
            }
            
            if (sqlite3_exec(database, version_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"%s", errMsg);
            }
            
            sqlite3_close(database);
            return isSuccess;
        } else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    
    return isSuccess;
}
- (NSNumber *)saveData:(Location *)location;
{
          NSLog(@"LOCATION ID: %@", location.id);
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString
                               stringWithFormat:@"insert into latlng (_id, name, address, latitude, "
                               @"longitude) values(\"%@\", \"%@\", \"%@\", %f, %f)",
                               location.id,
                               location.name, location.addressLine,
                               [location.latitude floatValue],
                               [location.longitude floatValue]];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            sqlite3_reset(statement);
            return [[NSNumber alloc] initWithLong:sqlite3_last_insert_rowid(database)];
        } else {
            sqlite3_reset(statement);
            return nil;
        }
    }
    return nil;
}

- (BOOL)deleteDataWithId:(NSString *)id {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *deleteSQL = [NSString
                               stringWithFormat:@"delete from latlng where _id = \"%@\"", id];
        const char *delete_stmt = [deleteSQL UTF8String];
        
        NSLog(@"%s", delete_stmt);
        
        sqlite3_prepare_v2(database, delete_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE) {
            
            sqlite3_finalize(statement);
            return YES;
        } else {
            sqlite3_reset(statement);
            return NO;
        }
    }
    return NO;
}

- (BOOL)deleteAllData{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *deleteSQL = [NSString
                               stringWithFormat:@"delete from latlng"];
        const char *delete_stmt = [deleteSQL UTF8String];
        
        NSLog(@"%s", delete_stmt);
        
        sqlite3_prepare_v2(database, delete_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE) {
            
            sqlite3_finalize(statement);
            return YES;
        } else {
            sqlite3_reset(statement);
            return NO;
        }
    }
    return NO;
}

- (BOOL)updateData:(Location *)location {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
    
        NSString *updateSQL = [NSString
                               stringWithFormat:@"update latlng set name=\"%@\", latitude=%f, "
                               @"longitude=%f where _id = %@",
                               location.name, [location.latitude floatValue],
                               [location.longitude floatValue],
                               location.id];
        const char *update_stmt = [updateSQL UTF8String];
        sqlite3_prepare_v2(database, update_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            sqlite3_reset(statement);
            return YES;
        } else {
            sqlite3_reset(statement);
            return NO;
        }
    }
    return NO;
}

- (NSMutableArray *)findById:(NSString *)id {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querrySQL =
        [NSString stringWithFormat:@"select * from latlng where _id = %@", id];
        const char *query_stmt = [querrySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) ==
            SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                Location *location = [[Location alloc] init];
                
                NSString *id = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                location.id = id;
                
                NSString *name = [[NSString alloc]
                                  initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                location.name = name;
                
                NSString *address = [[NSString alloc]
                                     initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                location.addressLine = address;
                
                NSNumber *lat = [[NSNumber alloc]
                                 initWithFloat:(float)sqlite3_column_double(statement, 3)];
                location.latitude = lat;
                
                NSNumber *lng = [[NSNumber alloc]
                                 initWithFloat:(float)sqlite3_column_double(statement, 4)];
                location.longitude = lng;
                
                [resultArray addObject:location];
            }
            sqlite3_reset(statement);
            
            return resultArray;
        }
    }
    return nil;
}

- (NSMutableArray *)findAll {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querrySQL = @"select * from latlng";
        const char *query_stmt = [querrySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) ==
            SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                Location *location = [[Location alloc] init];
                NSString *id = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                location.id = id;
                
                NSString *name = [[NSString alloc]
                                  initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                location.name = name;
                
                NSString *address = [[NSString alloc]
                                     initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                location.addressLine = address;
                
                NSNumber *lat = [[NSNumber alloc]
                                 initWithFloat:(float)sqlite3_column_double(statement, 3)];
                location.latitude = lat;
                
                NSNumber *lng = [[NSNumber alloc]
                                 initWithFloat:(float)sqlite3_column_double(statement, 4)];
                location.longitude = lng;
                
                [resultArray addObject:location];
            }
            sqlite3_reset(statement);
            
            return resultArray;
        }
    }
    return nil;
}

-(void)setModifiedDate: (NSString *)date {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        NSLog(@"UPDATING DATE %@", date);
        
        NSString *updateSQL = [NSString
                               stringWithFormat:@"update version set modified_since = \"%@\" where db_name = \"%@\"", date, @"latlng"];
        const char *update_stmt = [updateSQL UTF8String];
        sqlite3_prepare_v2(database, update_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_ROW) {
            //if update completed
            NSLog(@"UPDATED DATE");
            sqlite3_reset(statement);
      
        } else {
            
            NSLog(@"INSERTING DATE");
            
            //row not found, let's add one
            sqlite3_reset(statement);
            
            
            NSString *insertSQL = [NSString
                                   stringWithFormat:@"insert into version (db_name, modified_since) values(\"%@\", \"%@\")",
                                   @"latlng",
                                   date];
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                sqlite3_reset(statement);
                NSLog(@"INSERTED DATE");
               
            } else {
                sqlite3_reset(statement);
                NSLog(@"UPDATED FAILED");
            }
        }
    }
}

-(NSString *)getModifiedDate {
    NSLog(@"GETTING MODIFIED DATE");
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querrySQL =
        [NSString stringWithFormat:@"select * from version where db_name = \"%@\"", @"latlng"];
        
        NSLog(@"%@",querrySQL);
        const char *query_stmt = [querrySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) ==
            SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *date = [[NSString alloc ] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                NSLog(@"DATE IS: %@", date);
                sqlite3_reset(statement);
                return date;
            } else {
                NSLog(@"FOUND NO ROW");
            }
        } else {
            NSLog(@"WRONG SQL STATEMENT FORMAT");
        }
    } else{
         NSLog(@"CAN'T OPEN DB");
    }
    return @"";
}


@end
