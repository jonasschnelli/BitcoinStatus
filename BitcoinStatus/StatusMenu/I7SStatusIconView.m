//
//  I7SStatusIconView.m
//  i7share
//
//  Created by Jonas Schnelli on 02.09.11.
//  Copyright 2011 Jonas Schnelli. All rights reserved.

#import "I7SStatusIconView.h"
#import <QuartzCore/QuartzCore.h>
#import "I7SStatusIconViewDragView.h"

@implementation I7SStatusIconView
@synthesize statusItem;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        
        
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    
    [statusItem drawStatusBarBackgroundInRect:[self bounds]
                                withHighlight:isMenuVisible];
    
    
    // Drawing code here.
}

- (void)addDragLayer {
    I7SStatusIconViewDragView *view = [[I7SStatusIconViewDragView alloc] initWithFrame:self.bounds];
    

    [self addSubview:view];
    
    
}

- (void)mouseDown:(NSEvent *)event {
    [[self menu] setDelegate:self];
    [statusItem popUpStatusItemMenu:[self menu]];
    [self setNeedsDisplay:YES];
}



- (void)rightMouseDown:(NSEvent *)event {
    // Treat right-click just like left-click
    [self mouseDown:event];
}

- (void)menuWillOpen:(NSMenu *)menu {
    [[NSNotificationCenter defaultCenter] postNotificationName:BSMenuWillShowNotification object:nil];
    isMenuVisible = YES;
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    [[NSNotificationCenter defaultCenter] postNotificationName:BSMenuWillHideNotification object:nil];
    isMenuVisible = NO;
    [menu setDelegate:nil];    
    [self setNeedsDisplay:YES];
}


@end
