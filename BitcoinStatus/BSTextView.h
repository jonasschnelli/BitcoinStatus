//
//  BSTextView.h
//  BitcoinStatus
//
//  Created by Jonas Schnelli on 03.04.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "I7SStatusIconView.h"

@interface BSTextView : NSTextView 

@property (strong) I7SStatusIconView *iconView;
@end
