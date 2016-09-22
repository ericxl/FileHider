//
//  PanelController.m
//  File Hider
//
//  Created by Eric Liang on 6/8/13.
//  Copyright (c) 2013 Eric Liang. All rights reserved.
//

#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"
#import "AppDelegate.h"


#define kShowAtLaunch @"showAtLaunch"

#define OPEN_DURATION 0.05
#define CLOSE_DURATION .1

#define SEARCH_INSET 17

#define POPUP_HEIGHT 300
#define PANEL_WIDTH 300
#define MENU_ANIMATION_DURATION .1

#pragma mark -

@implementation PanelController

@synthesize backgroundView = _backgroundView;
@synthesize draggingView =_draggingView;
@synthesize delegate = _delegate;
@synthesize displayed_text;
@synthesize setting_panel;

#pragma mark -

BOOL hasActiveSettingPanel;

- (IBAction)closeApp:(NSButton *)sender {
    [NSApp terminate:nil];
}

- (IBAction)closeButtonPressed:(NSButton *)sender {
    [self closePanel];
    AppDelegate *app = [NSApp delegate];
    [app.menubarController setHasActiveIcon:NO];
    [app.panelController setHasActivePanel:NO];
}


- (IBAction)toggleSettingView:(NSButton *)sender {
    if (!hasActiveSettingPanel) {
        hasActiveSettingPanel = !hasActiveSettingPanel;
        NSWindow *panel = [self window];
        NSWindow *settingPanel = [self setting_panel];
        
        [settingPanel setAcceptsMouseMovedEvents:YES];
        [settingPanel setLevel:NSPopUpMenuWindowLevel];
        [settingPanel setOpaque:NO];
        [settingPanel setBackgroundColor:[NSColor clearColor]];
        
        
        NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
        NSRect statusRect = [self statusRectForWindow:panel];
        
        NSRect panelRect = NSMakeRect(panel.frame.origin.x + 134, panel.frame.origin.y, setting_panel.frame.size.width, setting_panel.frame.size.height);
        NSRect originalSettingPanelRect = NSMakeRect(panelRect.origin.x, panelRect.origin.y, statusRect.size.width, statusRect.size.height);
        panelRect.origin.y = panelRect.origin.y - setting_panel.frame.size.height;
        /*
         
         
         NSRect panelsRect = [setting_panel frame];
         
         CGFloat statusX = roundf(NSMidX(statusRect));
         CGFloat panelX = statusX - NSMinX(panelsRect);
         
         self.setting_backgroundView.arrowX = panelX;
         */
        
        if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
            panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
        
        [NSApp activateIgnoringOtherApps:NO];
        [settingPanel setAlphaValue:0];
        [settingPanel setFrame:originalSettingPanelRect display:YES];
        [settingPanel makeKeyAndOrderFront:nil];
        
        NSTimeInterval openDuration = OPEN_DURATION;
        
        NSEvent *currentEvent = [NSApp currentEvent];
        if ([currentEvent type] == NSLeftMouseDown)
        {
            NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
            BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
            BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
            if (shiftPressed || shiftOptionPressed)
            {
                openDuration *= 10;
                
                if (shiftOptionPressed)
                    NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                          NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
            }
        }
        
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:openDuration];
        [[settingPanel animator] setFrame:panelRect display:YES];
        [[settingPanel animator] setAlphaValue:1];
        [NSAnimationContext endGrouping];

    }
    else {
        hasActiveSettingPanel = !hasActiveSettingPanel;

        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
        [[[self setting_panel] animator] setAlphaValue:0];
        [NSAnimationContext endGrouping];
        
        dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
            
            [[self setting_panel] orderOut:nil];
        });
    }
    
    
    
    
}

- (IBAction)hideButtonPressed:(NSButton *)sender {
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:kShowAtLaunch];
    
    NSTask *hideTask=[[NSTask alloc]init];
    NSString *cmd=[[NSBundle mainBundle]pathForResource:@"vpl" ofType:@"tmn"];
    [hideTask setLaunchPath:cmd];
    [hideTask launch];
}

- (IBAction)showAllButtonPressed:(NSButton *)sender {
     [[NSUserDefaults standardUserDefaults]setBool:NO forKey:kShowAtLaunch];
    
    NSTask *showTask=[[NSTask alloc]init];
    NSString *cmd=[[NSBundle mainBundle]pathForResource:@"vsl" ofType:@"tmn"];
    [showTask setLaunchPath:cmd];
    [showTask launch];
}

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate
{
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil)
    {
        _delegate = delegate;
    }
    return self;
}


#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    hasActiveSettingPanel = NO;
    
    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    
    // Resize panel
    NSRect panelRect = [[self window] frame];
    panelRect.size.height = POPUP_HEIGHT;
    [[self window] setFrame:panelRect display:NO];
    
    [self.draggingView setDelegate:self];
    
    // Follow search string
}

#pragma mark - Public accessors

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
    if (_hasActivePanel != flag)
    {
        _hasActivePanel = flag;
        
        if (_hasActivePanel)
        {
            [self openPanel];
        }
        else
        {
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
}


- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *panel = [self window];
    NSRect statusRect = [self statusRectForWindow:panel];
    NSRect panelRect = [panel frame];
    
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);
    
    self.backgroundView.arrowX = panelX;
    self.setting_backgroundView.arrowX = panelX;
    //NSLog(@"%d",self.backgroundView.arrowX);
    
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActivePanel = NO;
}


#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    //NSLog(@"%f",screenRect.size.width);
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
    {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
        
    }
    else
    {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
        //NSLog(@"%f",statusRect.origin.x);
    }
    //NSLog(@"%f", statusRect.origin.x);
    return statusRect;
}

- (void)openPanel
{
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];
    
    NSRect panelRect = [panel frame];
    panelRect.size.width = PANEL_WIDTH;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown)
    {
        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
        if (shiftPressed || shiftOptionPressed)
        {
            openDuration *= 10;
            
            if (shiftOptionPressed)
                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
        }
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
    
}

- (void)closePanel
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    
    if ([setting_panel isVisible]) {
        [[setting_panel animator] setAlphaValue:0];
        hasActiveSettingPanel = NO;
    }
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.window orderOut:nil];
        if ([setting_panel isVisible]) {
            [setting_panel orderOut:nil] ;
        }
    });
}
@end


