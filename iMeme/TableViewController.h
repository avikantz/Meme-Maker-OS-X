//
//  TableViewController.h
//  iMeme
//
//  Created by Avikant Saini on 04/18/2015.
//  Copyright (c) 2015 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface TableViewController : NSObject <NSTableViewDataSource, NSTableViewDelegate> {
    NSMutableArray* items;
    AppDelegate* appDelegate;
    NSTableView* tableView;
}

@property (assign) IBOutlet AppDelegate* appDelegate;
@property (assign) IBOutlet NSTableView* tableView;

@end
