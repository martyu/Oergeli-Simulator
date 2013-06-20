//
//  AppDelegate.h
//  Oergeli Simulator
//
//  Created by Marty on 5/22/13.
//  Copyright (c) 2013 Marty Ulrich. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MUMainMenu;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong, readwrite)IBOutlet NSWindow *window;
@property (nonatomic, strong, readwrite)MUMainMenu *sample;

@end
