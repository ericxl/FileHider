//
//  AppDelegate.h
//  File Hider
//
//  Created by Eric Liang on 6/8/13.
//  Copyright (c) 2013 Eric Liang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MenubarController.h"
#import "PanelController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate>

@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;

- (IBAction)togglePanel:(id)sender;

@end
