//
//  AppDelegate.h
//  iMeme
//
//  Created by Avikant Saini on 04/18/2015.
//  Copyright (c) 2015 n/a. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Model.h"
#import "DragDropImageView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate, DragDropImageViewDelegate> {
    NSWindow* _window;
    Model* model;
    NSImageView *imageView;
    NSTableView *tableView;
    NSTextField *header;
    NSTextField *footer;
    NSSegmentedControl *headerAlignment;
    NSSegmentedControl *footerAlignment;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSImageView *imageView;
@property (assign) IBOutlet NSTableView *tableView;
@property (assign) IBOutlet NSTextField *header;
@property (assign) IBOutlet NSTextField *footer;
@property (assign) IBOutlet NSSegmentedControl *headerAlignment;
@property (assign) IBOutlet NSSegmentedControl *footerAlignment;

- (void)setPath:(NSString*)aPath;
float heightForStringDrawing(NSString *myString, NSFont *myFont, float myWidth);
- (void)drawText:(NSString*)text withRect:(CGRect)rect andPoints:(int)points andAlignment:(NSUInteger)alignment;
- (void)updateImage;

@end
