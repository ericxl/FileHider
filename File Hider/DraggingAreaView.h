//
//  AppDelegate.h
//  Unhidden Files
//
//  Created by Eric Liang on 8/16/12.
//  Copyright (c) 2012 Eric Liang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PanelController;

@interface DraggingAreaView : NSView {
    BOOL        isHighlighted;
}
@property (assign, setter=setHighlighted:) BOOL isHighlighted;
@property (nonatomic, unsafe_unretained) id delegate;

@end
