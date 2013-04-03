//
//  BSTextView.m
//  BitcoinStatus
//
//  Created by Jonas Schnelli on 03.04.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "BSTextView.h"

@implementation BSTextView
@synthesize iconView=_iconView;


- (void)mouseDown:(NSEvent *)event {
    [self.iconView mouseDown:event];
}


@end
