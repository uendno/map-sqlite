//
//  ViewController.m
//  map-sqlite
//
//  Created by Thang Tran on 5/30/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

#import "ViewController.h"
#import "DBManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    DBManager *dbmanager = [DBManager getSharedInstance];
    BOOL success = [dbmanager saveData:@123.2 lng:@123.2 name:@"DB"];
    if (success) {
        NSLog(@"true");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
