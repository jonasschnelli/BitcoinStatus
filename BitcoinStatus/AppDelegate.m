//
//  AppDelegate.m
//  BitcoinStatus
//
//  Created by Jonas Schnelli on 03.04.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "AppDelegate.h"
#import "I7SStatusIconView.h"
#import "BSMTGOXAPILoader.h"
#import "I7SPreferenceGeneralViewController.h"
#import "RHPreferencesWindowController.h"


//private declarations
@interface AppDelegate ()
@property (strong) NSNumberFormatter * numberFormatter;
@property (strong) RHPreferencesWindowController * preferencesWindowController;
@end



@implementation AppDelegate

@synthesize statusItem=_statusItem;
@synthesize statusMenu=_statusMenu;
@synthesize mainTextView=_mainTextView;
@synthesize numberFormatter=_numberFormatter;
@synthesize preferencesWindowController=_preferencesWindowController;

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
    NSImageView *statusMenuIconImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(1, 3,26,18)];
    statusMenuIconImageView.image = [NSImage imageNamed:@"status_bar_icon.png"];
    //[statusMenuIconImageView setWantsLayer:YES];
    
    self.mainTextView = [[BSTextView alloc] initWithFrame:NSMakeRect(15, 3,106,16)];
    self.mainTextView.font = [NSFont boldSystemFontOfSize:14];
    self.mainTextView.string = @"TEST";
    self.mainTextView.backgroundColor = [NSColor clearColor];
    self.mainTextView.editable = NO;
    

    NSFont *font = [NSFont systemFontOfSize:12];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:font, [NSColor blackColor], nil]
                                                                forKeys:[NSArray arrayWithObjects:NSFontAttributeName, NSForegroundColorAttributeName, nil] ];
    NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:@"TEST" attributes:attrsDictionary];

    NSShadow* shadow = [[NSShadow alloc] init];
    
    [shadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0
                                                       alpha:0.5]];
    [shadow setShadowOffset:NSMakeSize(0.0, -1)];
    [shadow setShadowBlurRadius:0.0];
    
    [text addAttribute:NSShadowAttributeName value:shadow
                 range:NSMakeRange(0, [text length])];
    [[self.mainTextView textStorage] setAttributedString:text];
    
    
    self.mainTextView.selectable = NO;
    self.mainTextView.iconView = statusIconView;

    
    [statusIconView addSubview:self.mainTextView];
    [statusIconView addSubview:statusMenuIconImageView];
    
    [self.statusItem setView:statusIconView];
    
    
    
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    [self.numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [self.numberFormatter setMaximumFractionDigits:2];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataNotificationRecived:)
                                                 name:BSNewDataFromRemoteNotification
                                               object:nil];
    
    
    [self loadData];
}

- (IBAction)showPreferences:(id)sender {
    I7SPreferenceGeneralViewController *general = [[I7SPreferenceGeneralViewController alloc] initWithNibName:@"I7SPreferenceGeneralViewController" bundle:nil];
    
    NSArray *controllers = [NSArray arrayWithObjects:general,
                            nil];
    
    self.preferencesWindowController = [[RHPreferencesWindowController alloc] initWithViewControllers:controllers andTitle:NSLocalizedString(@"Preferences", @"Preferences Window Title")];
    [self.preferencesWindowController showWindow:self];
    [self.preferencesWindowController.window orderFrontRegardless];
}

- (void)loadAfterStandardDelay {
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(loadData) userInfo:nil repeats:NO];
}

- (void)loadData {
    [BSMTGOXAPILoader startLoadValueWithCurrency:BSCurrencyCHF];
}

- (void)newDataNotificationRecived:(NSNotification *)notification {
    BSDataFromRemote *dataModel = notification.object;
    NSNumber *valueNum = [NSNumber numberWithDouble:[dataModel.tradeValue doubleValue]];
    NSString *valueString = [self.numberFormatter stringFromNumber:valueNum];
    self.mainTextView.string = [NSString stringWithFormat:@"%@$", valueString];
    
    [self loadAfterStandardDelay];
}

@end
