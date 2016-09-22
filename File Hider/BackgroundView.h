//
//  BackgroundView.h
//  File Hider
//
//  Created by Eric Liang on 6/8/13.
//  Copyright (c) 2013 Eric Liang. All rights reserved.
//

#define ARROW_WIDTH 15
#define ARROW_HEIGHT 10

@interface BackgroundView : NSView
{
    NSInteger _arrowX;
}

@property (nonatomic, assign) NSInteger arrowX;

@end

