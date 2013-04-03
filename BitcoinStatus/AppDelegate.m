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
#import "LaunchAtLoginController.h"

//private declarations
@interface AppDelegate ()
@property (strong) NSNumberFormatter * numberFormatter;
@property (strong) RHPreferencesWindowController * preferencesWindowController;
@property (readonly) NSString * currency;
@property (readonly) NSString * currencySymbole;

@property (strong) I7SStatusIconView *statusIconView;

@property (assign) IBOutlet NSMenuItem *preferences;
@property (assign) IBOutlet NSMenuItem *checkForUpdates;
@property (assign) IBOutlet NSMenuItem *aboutItem;
@property (assign) IBOutlet NSMenuItem *quitItem;

@property (assign) IBOutlet NSMenu *currencySubmenu;
@property (assign) IBOutlet NSMenuItem *currencyMenuItem;

@property (assign) NSTimer *updateTimer;
@property (readonly) NSTimeInterval updateInterval;

@end



@implementation AppDelegate

@synthesize statusItem=_statusItem;
@synthesize statusMenu=_statusMenu;
@synthesize mainTextView=_mainTextView;
@synthesize numberFormatter=_numberFormatter;
@synthesize preferencesWindowController=_preferencesWindowController;
@synthesize statusIconView=_statusIconView;

@synthesize preferences=_preferences;
@synthesize checkForUpdates=_checkForUpdates;
@synthesize aboutItem=_aboutItem;
@synthesize quitItem=_quitItem;
@synthesize updateTimer=_updateTimer;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    CGFloat menuWidth = 80.0;
    
    // make a global menu (extra menu) item
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@""];
    
    self.statusIconView = [[I7SStatusIconView alloc] initWithFrame:NSMakeRect(0, 0,menuWidth,20)];
    self.statusIconView.statusItem = self.statusItem;
    [self.statusIconView setMenu:self.statusMenu];
    [self.statusIconView setWantsLayer:YES];
    
    // add a image
    NSImageView *statusMenuIconImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(1, 3,26,18)];
    statusMenuIconImageView.image = [NSImage imageNamed:@"status_bar_icon.png"];
    //[statusMenuIconImageView setWantsLayer:YES];
    
    self.mainTextView = [[BSTextView alloc] initWithFrame:NSMakeRect(15, 3,menuWidth-15,16)];
    self.mainTextView.font = [NSFont boldSystemFontOfSize:14];
    self.mainTextView.string = @"loading data...";
    self.mainTextView.backgroundColor = [NSColor clearColor];
    self.mainTextView.editable = NO;
    

    NSMutableParagraphStyle *paragraphStyle=[[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSRightTextAlignment];
    
    NSFont *font = [NSFont systemFontOfSize:12];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:font, [NSColor blackColor], paragraphStyle, nil]
                                                                forKeys:[NSArray arrayWithObjects:NSFontAttributeName, NSForegroundColorAttributeName, NSParagraphStyleAttributeName, nil] ];
    NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:@"loading..." attributes:attrsDictionary];

    NSShadow* shadow = [[NSShadow alloc] init];
    
    [shadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0
                                                       alpha:0.5]];
    [shadow setShadowOffset:NSMakeSize(0.0, -1)];
    [shadow setShadowBlurRadius:0.0];
    
    [text addAttribute:NSShadowAttributeName value:shadow
                 range:NSMakeRange(0, [text length])];
    [[self.mainTextView textStorage] setAttributedString:text];
    
    
    self.mainTextView.selectable = NO;
    self.mainTextView.iconView = self.statusIconView;

    
    [self.statusIconView addSubview:self.mainTextView];
    [self.statusIconView addSubview:statusMenuIconImageView];
    
    [self.statusItem setView:self.statusIconView];
    
    
    
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    [self.numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [self.numberFormatter setMaximumFractionDigits:2];
    [self.numberFormatter setMinimumFractionDigits:2];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAfterStandardDelay)
                                                 name:BSShouldResetTimerNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData)
                                                 name:BSShouldReloadFromRemoteNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataNotificationRecived:)
                                                 name:BSNewDataFromRemoteNotification
                                               object:nil];
    
    
    [self loadData];
    
    
    
    // Get current version ("Bundle Version") from the default Info.plist file
    NSString *currentVersion = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSArray *prevStartupVersions = [[NSUserDefaults standardUserDefaults] arrayForKey:@"prevStartupVersions"];
    if (prevStartupVersions == nil)
    {
        
        // Save changes to disk
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Would you like to start BitcoinStatus when your Computer starts?"];
        [alert setInformativeText:@""];
        [alert setAlertStyle:NSWarningAlertStyle];
        NSInteger alertResult = [alert runModal];
        if(alertResult == NSAlertFirstButtonReturn) {
            self.launchAtStartup = YES;
        }
        else {
            self.launchAtStartup = NO;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:currentVersion] forKey:@"prevStartupVersions"];
    }
    else
    {
        if (![prevStartupVersions containsObject:currentVersion])
        {
            
            NSMutableArray *updatedPrevStartVersions = [NSMutableArray arrayWithArray:prevStartupVersions];
            [updatedPrevStartVersions addObject:currentVersion];
            [[NSUserDefaults standardUserDefaults] setObject:updatedPrevStartVersions forKey:@"prevStartupVersions"];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    // rewrite menu text according to translation files
    self.preferences.title      = NSLocalizedString(@"Preferences", @"Preferences Menu Item");
    self.checkForUpdates.title  = NSLocalizedString(@"Check for updates", @"Check for updates Menu Item");
    self.aboutItem.title        = NSLocalizedString(@"About", @"About Menu Item");
    self.quitItem.title         = NSLocalizedString(@"Quit", @"Quit Menu Item");
    self.currencyMenuItem.title = NSLocalizedString(@"Currency", @"Currency Menu Item");
    
    
    // set currency in submenu to defaults
    NSString *currentCurrency = self.currency;
    for(NSMenuItem *mItem in self.currencySubmenu.itemArray) {
        if([mItem.title isEqualToString:currentCurrency]) {
            [mItem setState:1];
        }
    }
    

    
    
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
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    NSTimeInterval updateInterval = self.updateInterval;
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(loadData) userInfo:nil repeats:NO];
}

- (void)loadData {
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    
    [BSMTGOXAPILoader startLoadValueWithCurrency:self.currency];
}



- (void)newDataNotificationRecived:(NSNotification *)notification {
    BSDataFromRemote *dataModel = notification.object;
    if(!dataModel) {
        self.mainTextView.string = @"?";
    }
    else {
        NSNumber *valueNum = [NSNumber numberWithDouble:[dataModel.tradeValue doubleValue]];
        NSString *valueString = [self.numberFormatter stringFromNumber:valueNum];
        self.mainTextView.string = [NSString stringWithFormat:@"%@%@", valueString, self.currencySymbole];
    }
    [self loadAfterStandardDelay];
    
    CABasicAnimation *fadeOutFadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutFadeInAnimation.duration=0.2;
    fadeOutFadeInAnimation.repeatCount=1;
    fadeOutFadeInAnimation.autoreverses=YES;
    fadeOutFadeInAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    fadeOutFadeInAnimation.toValue=[NSNumber numberWithFloat:0.0];
    
    //NSRect bounds = [[self.mainTextView textStorage] boundingRectWithSize:NSMakeSize(1000, 1000) options:NSStringDrawingOneShot];


    //float requiredHeight = [cell cellSizeForBounds:bounds].width;
    
    //self.statusIconView.layer.opacity = 0.0;
    [self.statusIconView.layer addAnimation:fadeOutFadeInAnimation forKey:@"fadingAnimation"];
    
    //self.statusIconView.frame = NSMakeRect(0, 0,bounds.size.width+25,20);
}

#pragma mark - auto launch controlling

- (BOOL)launchAtStartup {
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL state = [launchController launchAtLogin];
    launchController = nil;
    return state;
}

- (void)setLaunchAtStartup:(BOOL)aState {
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [launchController setLaunchAtLogin:aState];
    launchController = nil;
}

#pragma mark - configuration values

- (NSString *)currency {
    //!TODO: implement caching
    NSString *currencyString = [[NSUserDefaults standardUserDefaults] objectForKey:BSUserDefaultsCurrencyKey];
    if(!currencyString || currencyString.length <= 0) {
        currencyString = @"USD";
    }
    return currencyString;
}

- (NSString *)currencySymbole {
    //!TODO: implement caching
    NSString *currencyString = self.currency;
    NSString *currencySymbole = @"";
    
    if([currencyString isEqualToString:@"USD"]) {
        currencySymbole = @"$";
    }
    else if([currencyString isEqualToString:@"EUR"]) {
        currencySymbole = @"€";
    }
    else if([currencyString isEqualToString:@"CHF"]) {
        currencySymbole = @" CHF";
    }
    
    return currencySymbole;
}

- (NSTimeInterval)updateInterval {
    NSNumber *updateIntervalNumber = [[NSUserDefaults standardUserDefaults] objectForKey:BSUserDefaultsUpdateIntervalKey];
    if(!updateIntervalNumber) {
        updateIntervalNumber = [NSNumber numberWithInt:60*2];
    }
    
    return [updateIntervalNumber intValue];
}

#pragma mark - quick settings

- (IBAction)changeCurrencyWithMenuItem:(NSMenuItem *)menuItem {
    NSLog(@"%@", menuItem.title);
    
    for(NSMenuItem *mItem in self.currencySubmenu.itemArray) {
        NSLog(@"%@", mItem);
        [mItem setState:0];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:menuItem.title forKey:BSUserDefaultsCurrencyKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:BSShouldReloadFromRemoteNotification object:nil];
    
    [menuItem setState:1];
}

@end
