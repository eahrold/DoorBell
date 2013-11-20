//
//  AppDelegate.m
//  DoorBell
//
//  Created by Eldon on 9/19/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize serverName, key1, key2, key3;

#pragma mark - AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    serverName.stringValue = [[NSUserDefaults standardUserDefaults]objectForKey:@"LastServerUsed"];
    [self chooseServer:self];
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    NSMutableArray* serverList = [[NSMutableArray alloc]init];
    NSUserDefaults *sd = [NSUserDefaults standardUserDefaults];
    
    if(serverSet.count > 0){
        for(NSString* i in serverSet){
            [serverList addObject:i];
        }
        [sd setObject:serverList forKey:@"ServerList"];
    }
    if(![serverName.stringValue isEqualToString:@""]){
        [sd setObject:serverName.stringValue forKey:@"LastServerUsed"];
    }
    [sd synchronize];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

#pragma mark - IBActions
-(IBAction)dingDong:(id)sender{
    NSError* error;
    NSSet* reqFields = [NSSet setWithObjects:key1,key2,key3,serverName, nil];
    
    for(NSTextField* req in reqFields){
        if([req.stringValue isEqualToString:@""]) {
            NSLog(@"something is missing");
            error = [NSError errorWithDomain:@"Missing Field" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Something is missing"}];
            [NSApp presentError:error modalForWindow:_window delegate:nil didPresentSelector:NULL contextInfo:NULL];
            return;
        }
    }
    
    
    if(![serverName.stringValue isEqualToString:@""]){
        [serverSet addObject:serverName.stringValue];
    }
    
    NSSound *dingDongSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Doorbell"  ofType:@"m4a"] byReference:NO];

    NSString* knock_seq = [NSString stringWithFormat:@"%@ %@ %@",key1.stringValue,key2.stringValue,key3.stringValue];
    [SSKeychain setPassword:knock_seq forService:[[NSBundle mainBundle] bundleIdentifier] account:serverName.stringValue];
    
    
    
    // for some reason the port knocking is a bit fussy with DNS names,
    // so we'll try and work those out here...
    NSHost* host = [NSHost hostWithName:serverName.stringValue];
    if(!host.addresses.count){
        host = [NSHost hostWithAddress:serverName.stringValue];
    }
    
    if(host.addresses.count){
        if (dingDongSound)[dingDongSound play];
        
        [self startProgressPanelWithMessage:@"Ding Dong..."];
        NSArray *seq = @[key1.stringValue,key2.stringValue,key3.stringValue,key1.stringValue];
        NSArray* status = @[@"Once",@"Twice",@"Three Times",@"Once Again"];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int i = 0;
        for(NSString* key in seq){
            NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@",host.address,key]];
            _progstatus.stringValue = [NSString stringWithFormat:@"Ding-Dong %@",status[i]]; i++;
            
            NSURLRequest* ring = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:1];
            
            [NSURLConnection sendSynchronousRequest:ring returningResponse:nil error:nil];
            [NSURLConnection sendSynchronousRequest:ring returningResponse:nil error:nil];
        }
            dispatch_async(dispatch_get_main_queue(),
                           ^{[self stopProgressPanel];
                           });
        });
    }else{
        [self stopProgressPanel];
        NSError* hostError = [NSError errorWithDomain:@"Invalid Host" code:1 userInfo:@{NSLocalizedDescriptionKey:@"We couldn't resolve that host"}];
        [NSApp presentError:hostError modalForWindow:_window delegate:nil didPresentSelector:nil contextInfo:NULL];
    }
}


-(IBAction)chooseServer:(id)sender{
    NSString* knocks = [SSKeychain passwordForService:[[NSBundle mainBundle] bundleIdentifier] account:serverName.stringValue];
    NSArray* keys = [ knocks componentsSeparatedByString:@" "];
    
    if(keys.count == 3){
        key1.stringValue = keys[0];
        key2.stringValue = keys[1];
        key3.stringValue = keys[2];
    }else{
        key1.stringValue = @"";
        key2.stringValue = @"";
        key3.stringValue = @"";
    }
}

#pragma mark - Progress Panel
- (void)startProgressPanelWithMessage:(NSString*)message{
    /* Display a progress panel as a sheet */
    _progstatus.stringValue = message;
    [_progress startAnimation:self];
    [_ringButton setEnabled:NO];

    [NSApp beginSheet:_progPanel
       modalForWindow:_window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:NULL];
}

- (void)stopProgressPanel {
    [_progress stopAnimation:self];
    [_progPanel orderOut:self];
    [_ringButton setEnabled:YES];

    [NSApp endSheet:_progPanel returnCode:0];
}


@end
