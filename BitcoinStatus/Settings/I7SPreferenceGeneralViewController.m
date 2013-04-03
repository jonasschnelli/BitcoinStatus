//
//  I7SPreferenceSharesViewController.m
//  i7share
//
//  Created by Jonas Schnelli on 30.07.12.
//  Copyright (c) 2012 include7 AG. All rights reserved.
//

#import "I7SPreferenceGeneralViewController.h"


@interface I7SPreferenceGeneralViewController ()

@end

@implementation I7SPreferenceGeneralViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - custom stuff


- (BOOL)launchAtStartup {
//    I7SAppDelegate *dele = (I7SAppDelegate *)[NSApplication sharedApplication].delegate;
//    return dele.launchAtStartup;
    return YES;
}

- (void)setLaunchAtStartup:(BOOL)aState {
//    I7SAppDelegate *dele = (I7SAppDelegate *)[NSApplication sharedApplication].delegate;
//    dele.launchAtStartup = aState;
}


#pragma mark - View hide/show

- (void)awakeFromNib {
    
}


- (void)viewDidDisappear {
    
    
}

#pragma mark - RHPreferencesViewControllerProtocol

-(NSString*)identifier{
    return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}
-(NSString*)toolbarItemLabel{
    
    return NSLocalizedString(@"General", @"GeneralToolbarItemLabel");
}

-(NSView*)initialKeyView{
    return nil;
}


@end
