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
        [sharedInstance createDB];
    }
    return sharedInstance;
}
-(BOOL) createDB {
    NSString *docsDir;
    NSArray *dirPath;
    
    //Get the document directory
    dirPath =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPath[0];
    
    //Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingString:@"latlng.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:databasePath] == NO) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            char *errMsg;
            char *sql_stmt = "create table if not exists latlng (_id integer primary key AUTOINCREMENT, name text, lat float, lng float)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)!= SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create table");
                
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
-(BOOL) saveData: (NSNumber *)lat
             lng:(NSNumber *)lng
            name:(NSString *)name;
{
    const char *dbpath = [databasePath UTF8String];
    if(sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into latlng (name, lat, lng) values(\"%@\", %f, %f)", name, [lat floatValue], [lng floatValue]];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            return YES;
        } else {
            return NO;
        }
        sqlite3_reset(statement);
    }
    return NO;
}
-(NSArray *)findById: (NSNumber *)id {
    const char *dbpath = [databasePath UTF8String];
    if(sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querrySQL = [NSString stringWithFormat:@"select * from studentsDetail where _id = %ld",[id integerValue]];
        const char *query_stmt = [querrySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                [resultArray addObject:name];
                
                NSNumber *lat = [[NSNumber alloc] initWithFloat:(float)sqlite3_column_double(statement, 2)];
                [resultArray addObject:lat];
                
                NSNumber *lng = [[NSNumber alloc] initWithFloat:(float)sqlite3_column_double(statement, 3)];
                [resultArray addObject:lng];
            
            } else {
                NSLog(@"Not Found");
                return nil;
            }
            sqlite3_reset(statement);
        }
    }
    return nil;
}


@end
