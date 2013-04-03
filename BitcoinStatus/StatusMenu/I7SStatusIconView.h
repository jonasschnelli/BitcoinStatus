//
//  I7SStatusIconView.h
//  i7share
//
//  Created by Jonas Schnelli on 02.09.11.
//  Copyright 2011 Jonas Schnelli. All rights reserved.

#import <Cocoa/Cocoa.h>

@interface I7SStatusIconView : NSView <NSMenuDelegate> {
    NSStatusItem *statusItem;
    BOOL isMenuVisible;
}

@property (retain, nonatomic) NSStatusItem *statusItem;
- (void)addDragLayer;
@end
