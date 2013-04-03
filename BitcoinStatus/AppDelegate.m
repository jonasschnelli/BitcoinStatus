//
//  AppDelegate.m
//  BitcoinStatus
//
//  Created by Jonas Schnelli on 03.04.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "AppDelegate.h"
#import "I7SStatusIconView.h"
#import "BSMTGOXLoader.h"

@interface AppDelegate ()
@property (strong) NSNumberFormatter * numberFormatter;
@end

@implementation AppDelegate
@synthesize statusItem=_statusItem;
@synthesize statusMenu=_statusMenu;
@synthesize mainTextView=_mainTextView;
@synthesize numberFormatter=_numberFormatter;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // make a global menu (extra menu) item
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@""];
    
    I7SStatusIconView *statusIconView = [[I7SStatusIconView alloc] initWithFrame:NSMakeRect(0, 0,90,20)];
    statusIconView.statusItem = self.statusItem;
    [statusIconView setMenu:self.statusMenu];
    
    // add a image
    NSImageView *statusMenuIconImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(1, 3,26,16)];
    statusMenuIconImageView.image = [NSImage imageNamed:@"status_bar_icon.png"];
    //[statusMenuIconImageView setWantsLayer:YES];
    
    self.mainTextView = [[BSTextView alloc] initWithFrame:NSMakeRect(15, 3,106,16)];
    self.mainTextView.font = [NSFont systemFontOfSize:12];
    self.mainTextView.string = @"TEST";
    self.mainTextView.backgroundColor = [NSColor clearColor];
    self.mainTextView.editable = NO;
    self.mainTextView.selectable = NO;
    self.mainTextView.iconView = statusIconView;

    
    [statusIconView addSubview:self.mainTextView];
    [statusIconView addSubview:statusMenuIconImageView];
    
    [self.statusItem setView:statusIconView];
    
    
    
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    [self.numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataNotificationRecived:)
                                                 name:BSNewDataFromRemoteNotification
                                               object:nil];
    
    
    [self loadData];
}

- (void)loadAfterStandardDelay {
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(loadData) userInfo:nil repeats:NO];
}

- (void)loadData {
    [BSMTGOXLoader startLoadValueWithCurrency:BSCurrencyCHF];
}

- (void)newDataNotificationRecived:(NSNotification *)notification {
    BSDataFromRemote *dataModel = notification.object;
    NSNumber *valueNum = [NSNumber numberWithDouble:[dataModel.tradeValue doubleValue]];
    NSString *valueString = [self.numberFormatter stringFromNumber:valueNum];
    self.mainTextView.string = [NSString stringWithFormat:@"%@$", valueString];
    
    [self loadAfterStandardDelay];
}

@end
