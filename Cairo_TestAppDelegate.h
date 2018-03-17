//
//  Cairo_TestAppDelegate.h
//  Cairo Test
//
//  Created by i.am.mutun on 13/3/2556.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Cairo_TestAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
  IBOutlet NSTextField *textfield;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)save:(id) sender;

@end
