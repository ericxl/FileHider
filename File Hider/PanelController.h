//
//  PanelController.h
//  File Hider
//
//  Created by Eric Liang on 6/8/13.
//  Copyright (c) 2013 Eric Liang. All rights reserved.
//

#import "BackgroundView.h"
#import "StatusItemView.h"
#import "DraggingAreaView.h"

@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate>
{
    BOOL _hasActivePanel;
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<PanelControllerDelegate> _delegate;
    __unsafe_unretained NSSearchField *_searchField;
    __unsafe_unretained NSTextField *_textField;
    __unsafe_unretained DraggingAreaView *_draggingView;
    __unsafe_unretained BackgroundView *_setting_backgroundView;
}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;
@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *setting_backgroundView;
@property (nonatomic, unsafe_unretained) IBOutlet DraggingAreaView *draggingView;
@property (strong) IBOutlet NSTextField *displayed_text;
@property (strong) IBOutlet NSPanel *setting_panel;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;
- (IBAction)closeApp:(NSButton *)sender;
- (IBAction)closeButtonPressed:(NSButton *)sender;
- (IBAction)toggleSettingView:(NSButton *)sender;
- (IBAction)hideButtonPressed:(NSButton *)sender;
- (IBAction)showAllButtonPressed:(NSButton *)sender;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;

@end
