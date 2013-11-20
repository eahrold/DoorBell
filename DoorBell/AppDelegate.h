//
//  AppDelegate.h
//  DoorBell
//
//  Created by Eldon on 9/19/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSKeychain.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    NSMutableSet* serverSet;
}

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSPanel *progPanel;
@property (assign) IBOutlet NSProgressIndicator *progress;
@property (assign) IBOutlet NSTextField *progstatus;
@property (assign) IBOutlet NSButton* ringButton;

@property (assign) IBOutlet NSComboBox *serverName;
@property (assign) IBOutlet NSSecureTextField *key1;
@property (assign) IBOutlet NSSecureTextField *key2;
@property (assign) IBOutlet NSSecureTextField *key3;


@end
