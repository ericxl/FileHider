//
//  Panel.m
//  File Hider
//
//  Created by Eric Liang on 6/8/13.
//  Copyright (c) 2013 Eric Liang. All rights reserved.
//
#import "Panel.h"

@implementation Panel

- (BOOL)canBecomeKeyWindow;
{
    return YES; // Allow Search field to become the first responder
}

@end
