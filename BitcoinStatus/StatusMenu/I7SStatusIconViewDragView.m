//
//  I7SStatusIconViewDragView.m
//  i7share
//
//  Created by Jonas Schnelli on 01.09.12.
//  Copyright (c) 2012 include7 AG. All rights reserved.
//

#import "I7SStatusIconViewDragView.h"

@implementation I7SStatusIconViewDragView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
        
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}


#pragma mark - dragin stack

-(NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
    NSLog(@"Drag Enter");
    return NSDragOperationCopy;
}

-(NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender{
    return NSDragOperationCopy;
}

-(void)draggingExited:(id <NSDraggingInfo>)sender{
    NSLog(@"Drag Exit");
}

-(BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender{
    return YES;
}


//perform the drag and log the files that are dropped
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        //NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        
        // only take first file

    }
    return YES;
}



@end
