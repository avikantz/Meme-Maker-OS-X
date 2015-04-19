//
//  TableViewController.m
//  iMeme
//
//  Created by Avikant Saini on 04/18/2015.
//  Copyright (c) 2015 n/a. All rights reserved.
//

#import "TableViewController.h"
#import "Template.h"

@implementation TableViewController

@synthesize appDelegate;
@synthesize tableView;

- (id)init {
    self = [super init];
    if (self) {
        items = [[NSMutableArray alloc] init];
        NSArray* paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg" inDirectory:nil];
        for (NSString* filename in paths) {
            NSString* path = [[filename lastPathComponent] stringByDeletingPathExtension];
            NSString* name = [path stringByReplacingOccurrencesOfString:@"-" withString:@" "];
            path = [[NSBundle mainBundle] pathForImageResource:path];
            [items addObject:[[Template alloc] initWithName:name path:path]];
        }
    }
    return self;
}



-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	return 25.f;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [items count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    Template* template = [items objectAtIndex:row];
    NSString* identifier = [tableColumn identifier];
    return [template valueForKey:identifier];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [tableView selectedRow];
    if (row >= 0) {
        Template* template = [items objectAtIndex:row];
        [appDelegate setPath:[template path]];
    }
}

@end
