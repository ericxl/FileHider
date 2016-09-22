//
//  AppDelegate.h
//  Unhidden Files
//
//  Created by Eric Liang on 8/16/12.
//  Copyright (c) 2012 Eric Liang. All rights reserved.
//

#import "DraggingAreaView.h"
#import "PanelController.h"

@implementation DraggingAreaView
@dynamic isHighlighted;
@synthesize delegate = _delegate;


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


-(void)awakeFromNib {
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    //NSLog(@"drag entered");
    int files_count = 0;
    int folders_count = 0;
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *paths = nil;
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        
        paths = [pboard propertyListForType:NSFilenamesPboardType];
        for (NSString *path in paths) {
            NSError *error = nil;
            NSString *utiType = [[NSWorkspace sharedWorkspace]
                                 typeOfFile:path error:&error];
            if ([[NSWorkspace sharedWorkspace]
                  type:utiType conformsToType:(id)kUTTypeFolder]) {
                folders_count ++;
                
            }
            else files_count ++;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(setDisplayed_text:)])
    {
        if (paths) {
            PanelController *con = self.delegate;
            NSTextField *field = con.displayed_text;
            NSString *string = nil;
            if (files_count > 0 && folders_count == 0) {
                if (files_count == 1) {
                    string = [NSString stringWithFormat:@"%d File Entered", (short)[paths count]];
                }
                else {
                    string = [NSString stringWithFormat:@"%d Files Entered", (short)[paths count]];
                }
                
            }
            else if (files_count == 0 && folders_count > 0) {
                if (folders_count == 1) {
                    string = [NSString stringWithFormat:@"%d Folder Entered", (short)[paths count]];
                }
                else {
                    string = [NSString stringWithFormat:@"%d Folders Entered", (short)[paths count]];

                }
            }
            else {
                if (files_count == 1 && folders_count == 1) {
                    string = [NSString stringWithFormat:@"%d Folder and %d File Entered", folders_count, files_count];
                }
                else if (files_count == 1 && folders_count != 1) {
                    string = [NSString stringWithFormat:@"%d Folders and %d File Entered", folders_count, files_count];
                }
                else if (files_count != 1 && folders_count == 1) {
                    string = [NSString stringWithFormat:@"%d Folder and %d Files Entered", folders_count, files_count];
                }
                else {
                    string = [NSString stringWithFormat:@"%d Folders and %d Files Entered", folders_count, files_count];
                }
            }
            
            [field setStringValue:string];
        }
    }
    
    [self setHighlighted:YES];
    return NSDragOperationEvery;
}
- (void)draggingExited:(id <NSDraggingInfo>)sender {
    [self setHighlighted:NO];
    //NSLog(@"drag exited");
}
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender  {
    
    
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    //NSLog(@"drag performed");
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        
        NSArray *paths = [pboard propertyListForType:NSFilenamesPboardType];
        //NSLog(@"%ld",[paths count]);
        for (NSString *path in paths) {
            //NSError *error = nil;
            //NSLog(@"%@",path);
            //NSString *utiType = [[NSWorkspace sharedWorkspace] typeOfFile:path error:&error];
            /*
            if (![[NSWorkspace sharedWorkspace]
                  type:utiType conformsToType:(id)kUTTypeFolder]) {
                
               // [self setHighlighted:NO];
                //[self toggleVisibilityForFile:path isDirectory:NO];
                //return NSDragOperationEvery;
            }
            */
            [self toggleVisibilityForFile:path isDirectory:YES];
        }
    }
    [self setHighlighted:NO];
    return YES;
}
- (BOOL)isHighlighted {
    return isHighlighted;
}

- (void)setHighlighted:(BOOL)value {
    isHighlighted = value;
    if (!isHighlighted) {
        if ([self.delegate respondsToSelector:@selector(setDisplayed_text:)])
        {
            PanelController *con = self.delegate;
            NSTextField *field = con.displayed_text;
            [field setStringValue:@"Drag Files or Folders Here to Toggle Visibility"];
        }
    }
    
    
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)frame {
    [super drawRect:frame];
    if (isHighlighted) {
        [NSBezierPath setDefaultLineWidth:10.0];
        int red = rand() % 255;
        int green = rand() % 255;
        int blue = rand() % 255;
        NSColor* myColor = [NSColor colorWithCalibratedRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        
        
        [myColor set];
        [NSBezierPath strokeRect:frame];
    }
    else {
        [NSBezierPath setDefaultLineWidth:3.0];
        [[NSColor whiteColor] set];
        [NSBezierPath strokeRect:frame];
    }
}

- (void)toggleVisibilityForFile:(NSString *)filename isDirectory:(BOOL)isDirectory {
    // Convert the pathname to HFS+
    FSRef fsRef;
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filename, kCFURLPOSIXPathStyle, isDirectory);
    
    if (!url)
    {
        NSLog(@"Error creating CFURL for %@.", filename);
        return;
    }
    
    if (!CFURLGetFSRef(url, &fsRef))
    {
        NSLog(@"Error creating FSRef for %@.", filename);
        CFRelease(url);
        return ;
    }
    
    CFRelease(url);
    
    // Get the file's catalog info
    FSCatalogInfo *catalogInfo = (FSCatalogInfo *)malloc(sizeof(FSCatalogInfo));
    OSErr err = FSGetCatalogInfo(&fsRef, kFSCatInfoFinderInfo, catalogInfo, NULL, NULL, NULL);
    
    if (err != noErr)
    {
        NSLog(@"Error getting catalog info for %@. The error returned was: %d", filename, err);
        free(catalogInfo);
        return ;
    }
    
    // Extract the Finder info from the FSRef's catalog info
    FInfo *info = (FInfo *)(&catalogInfo->finderInfo[0]);
    
    // Toggle the invisibility flag
    if (info->fdFlags & kIsInvisible)
        info->fdFlags &= ~kIsInvisible;
    else
        info->fdFlags |= kIsInvisible;
    
    // Update the file's visibility
    err = FSSetCatalogInfo(&fsRef, kFSCatInfoFinderInfo, catalogInfo);
    
    if (err != noErr)
    {
        NSLog(@"Error setting visibility bit for %@. The error returned was: %d", filename, err);
        free(catalogInfo);
        return ;
    }
    
    free(catalogInfo);
    //return YES;
}
@end
