//
//  MUMainWindow.h
//  AudioTest
//
//  Created by Marty on 5/22/13.
//  Copyright (c) 2013 Marty Ulrich. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LeapObjectiveC.h"

enum {
	MUDirectionPull = 0,
	MUDirectionPush,
}; typedef int MUDirection;

@interface MUMainWindow	: NSWindow <LeapDelegate>

@end
