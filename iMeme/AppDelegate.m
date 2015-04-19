//
//  AppDelegate.m
//  iMeme
//
//  Created by Avikant Saini on 04/18/2015.
//  Copyright (c) 2015 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "NSData+Base64.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize imageView;
@synthesize tableView;
@synthesize header;
@synthesize footer;
@synthesize headerAlignment;
@synthesize footerAlignment;

- (void)dealloc {
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
    model = [[Model alloc] init];
	DragDropImageView *ddmiv = (DragDropImageView *)imageView;
	ddmiv.delegate = self;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender {
    return YES;
}

- (NSData*)getPNG {
    NSData* imageData = [[imageView image] TIFFRepresentation];
    NSBitmapImageRep* rep = [NSBitmapImageRep imageRepWithData:imageData];
    NSData* data = [rep representationUsingType:NSPNGFileType properties:nil];
    return data;
}

- (NSData*)getJPG {
    NSDictionary *properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.98] forKey:NSImageCompressionFactor];
    NSData* imageData = [[imageView image] TIFFRepresentation];
    NSBitmapImageRep* rep = [NSBitmapImageRep imageRepWithData:imageData];
    NSData* data = [rep representationUsingType:NSJPEGFileType properties:properties];
    return data;
}

- (NSData*)getTIF {
    NSData* imageData = [[imageView image] TIFFRepresentation];
    NSBitmapImageRep* rep = [NSBitmapImageRep imageRepWithData:imageData];
    NSData* data = [rep representationUsingType:NSTIFFFileType properties:nil];
    return data;
}

- (void)setPath:(NSString*)aPath {
    model.path = aPath;
    [self updateImage];
}

-(void)dropComplete:(NSString *)filePath {
	model.path = filePath;
	[self updateImage];
}

- (void)controlTextDidChange:(NSNotification*)aNotification {
    model.header = [[header stringValue] uppercaseString];
    model.footer = [[footer stringValue] uppercaseString];
    [self updateImage];
}

- (IBAction)onHeaderSize:(NSSegmentedControl*)sender {
    NSInteger segment = [sender selectedSegment];
    NSInteger tag = [[sender cell] tagForSegment:segment];
    model.headerSize += tag ? 4 : -4;
    model.headerSize = MAX(model.headerSize, 8);
    model.headerSize = MIN(model.headerSize, 144);
    [self updateImage];
}

- (IBAction)onFooterSize:(NSSegmentedControl*)sender {
    NSInteger segment = [sender selectedSegment];
    NSInteger tag = [[sender cell] tagForSegment:segment];
    model.footerSize += tag ? 4 : -4;
    model.footerSize = MAX(model.footerSize, 8);
    model.footerSize = MIN(model.footerSize, 144);
    [self updateImage];
}

- (IBAction)onHeaderAlignment:(NSSegmentedControl*)sender {
    NSInteger segment = [sender selectedSegment];
    NSInteger tag = [[sender cell] tagForSegment:segment];
    model.headerAlignment = tag;
    [self updateImage];
}

- (IBAction)onFooterAlignment:(NSSegmentedControl*)sender {
    NSInteger segment = [sender selectedSegment];
    NSInteger tag = [[sender cell] tagForSegment:segment];
    model.footerAlignment = tag;
    [self updateImage];
}



- (IBAction)onSave:(id)sender {
    NSSavePanel* panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"jpg", nil]];
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        NSData* data = [self getJPG];
        [data writeToURL:[panel URL] atomically:YES];
    }
}

- (IBAction)onOpen:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"png", @"jpg", @"jpeg", @"bmp", @"gif", nil]];
    [panel setAllowsMultipleSelection:NO];
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        NSURL* url = [[panel URLs] objectAtIndex:0];
        [self setPath:[url path]];
    }
}

- (IBAction)onCopy:(id)sender {
    NSPasteboard* board = [NSPasteboard generalPasteboard];
    NSData* data = [self getTIF];
    [board clearContents];
    [board setData:data forType:NSTIFFPboardType];
}

- (IBAction)onReset:(id)sender {
    [tableView deselectAll:nil];
    [model reset];
    [headerAlignment selectSegmentWithTag:model.headerAlignment];
    [footerAlignment selectSegmentWithTag:model.footerAlignment];
    [header setStringValue:model.header];
    [footer setStringValue:model.footer];
    [self updateImage];
}

float heightForStringDrawing(NSString* myString, NSFont* myFont, float myWidth) {
    NSTextStorage* textStorage = [[[NSTextStorage alloc] initWithString:myString] autorelease];
    NSTextContainer* textContainer = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(myWidth, FLT_MAX)] autorelease];
    NSLayoutManager* layoutManager = [[[NSLayoutManager alloc] init] autorelease];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttribute:NSFontAttributeName value:myFont range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    [layoutManager glyphRangeForTextContainer:textContainer];
    return [layoutManager usedRectForTextContainer:textContainer].size.height;
}

- (void)drawText:(NSString *)text withRect:(CGRect)rect andPoints:(int)points andAlignment:(NSUInteger)alignment {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    NSFont *font = [NSFont fontWithName:@"Impact" size:points];
    [attrs setValue:font forKey:NSFontAttributeName];
    NSMutableParagraphStyle *style = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [style setAlignment:alignment];
    [style setMaximumLineHeight:points * 1.0f];
    [attrs setValue:style forKey:NSParagraphStyleAttributeName];
	[attrs setValue:@-4.0f forKey:NSStrokeWidthAttributeName];
	[attrs setValue:[NSColor blackColor] forKey:NSStrokeColorAttributeName];
	[attrs setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
    [text drawInRect:NSRectFromCGRect(rect) withAttributes:attrs];
}

- (void)updateImage {
    NSImage* image = [[NSImage alloc] initWithContentsOfFile:model.path];
    [image lockFocus];
    NSSize size = [image size];
    int pad = 10;
    int width = size.width - pad * 2;
    int height;
    CGRect rect;
    // header
    height = size.height - pad * 2;
    rect = CGRectMake(pad, pad, width, height);
    [self drawText:model.header withRect:rect andPoints:model.headerSize andAlignment:model.headerAlignment];
    // footer
    NSFont* font = [NSFont fontWithName:@"Impact" size:model.footerSize];
    height = heightForStringDrawing(model.footer, font, width);
    rect = CGRectMake(pad, -pad, width, height);
    [self drawText:model.footer withRect:rect andPoints:model.footerSize andAlignment:model.footerAlignment];
    [image unlockFocus];
    
    [imageView setImage:image];
    [image release];
}

@end
