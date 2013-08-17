//
//  MUMainWindow.m
//  AudioTest
//
//  Created by Marty on 5/22/13.
//  Copyright (c) 2013 Marty Ulrich. All rights reserved.
//


// TODO: TEST SPEED DIFFERENCE BETWEEN LEAP
// TODO: CHANGING PUSH/PULL MUST SWITCH SOUND FOR BUTTON

#import "MUMainWindow.h"
#import <AVFoundation/AVFoundation.h>
#import "MUAudioPlayer.h"

#define VOLUME_FROM_SPEED(x)  (sin((M_PI*x)/2000 ))


@interface MUMainWindow ()
{
	// Used to determine whether to play push or pull note.
	// Updated in onFrame:.
	MUDirection pushPull;
}

@property(strong, nonatomic)LeapController *controller;

// Used to store per-frame volume based on speed of pencil tracker.
// Updated in onFrame:.
@property(nonatomic)float volume;

@property (strong) IBOutlet NSTextField *pushPullLabel;

@end


@implementation MUMainWindow

static NSArray *keysArr;

-(void)awakeFromNib
{
	keysArr = @[@'z', @'x', @'c', @'v', @'b', @'n', @'m', @',', @'.', @'/', @'a', @'s', @'d', @'f', @'g', @'h', @'j', @'k', @'l', @';', @'\'',
			  @'w', @'e', @'r', @'t', @'y', @'u', @'i', @'o', @'p', @'['];

	self.controller = [[LeapController alloc] initWithDelegate:self];

	// Set default value for pushPull in case Leap isn't plugged in (which usually sets it)
	//
	// CHANGE THIS VALUE TO CHANGE PUSH/PULL WITHOUT LEAP.
	pushPull = MUPull;

	[self updatePushPullLabel];
}

-(void)keyDown:(NSEvent *)theEvent
{
	if (theEvent.type == NSKeyDown) {
		NSString *characters = [theEvent characters];
		if ([characters length]) {
			unichar character = [characters characterAtIndex:0];
			int index = (int)[keysArr indexOfObject:[NSNumber numberWithChar:character]];

			[[MUAudioPlayer sharedInstance] btnAtIndex:index stopPlay:MUPlay pushPull:pushPull volume:self.volume];

			if (character == '8' || character == '9' || character == '7' || character == '6' || character == '5' ||
				character == '4' || character == '3' || character == '2' || character == '1' || character == '-' ||
				character == '=' || character == '0' || character == ' ' || character == '') {
				[self changeDirection];
			}
		}
	}
}

-(void)keyUp:(NSEvent *)theEvent
{
	if (theEvent.type == NSKeyUp) {
		NSString *characters = [theEvent characters];
		if ([characters length]) {
			unichar character = [characters characterAtIndex:0];
			int index = (int)[keysArr indexOfObject:[NSNumber numberWithChar:character]];

			[[MUAudioPlayer sharedInstance] btnAtIndex:index stopPlay:MUStop pushPull:MUBoth volume:0.0];
		}
	}
}

-(void)changeDirection
{
	if (pushPull == MUPull) {
		pushPull = MUPush;
	} else if (pushPull == MUPush) {
		pushPull = MUPull;
	};

	[self updatePushPullLabel];
}

-(void)updatePushPullLabel
{
	if (pushPull == MUPull) {
		self.pushPullLabel.stringValue = @"Pull\n (press a key on the numbers row on the your keyboard to change)";
	} else if (pushPull == MUPush) {
		self.pushPullLabel.stringValue = @"Push\n (press a key on the numbers row on the your keyboard to change)";
	}
}


#pragma mark Leap methods

-(void)onFrame:(LeapController *)controller
{
    // Get the most recent frame and report some basic information
    LeapFrame *frame = [controller frame:0];

	//    NSLog(@"Frame id: %lld, timestamp: %lld, hands: %ld, fingers: %ld, tools: %ld, gestures: %ld",
	//          [frame id], [frame timestamp], [[frame hands] count],
	//          [[frame fingers] count], [[frame tools] count], [[frame gestures:nil] count]);

	// Get tools
	if([[frame tools] count] != 0) {
		NSArray *tools = [frame tools];

		// Should only be one tool, so index 0.
		// leftHandTracker is a pencil attached to the monitor.
		LeapTool *leftHandTracker = [tools objectAtIndex:0];

		// If the velocity vector of pencil in the x direction is negative,
		// it's pulling open.  If it's positive, it's closing.
		LeapVector *velocity = [leftHandTracker tipVelocity];
		if (velocity.x <= 0) {
			// Push
			pushPull = MUPush;
		} else {
			// Pull
			pushPull = MUPull;
		}

		//			NSLog(@"velocity: <%f, %f, %f>\n", velocity.x, velocity.y, velocity.z);

		// The volume needs to be between 0 and 1.  To translate speed into volume, we use the
		// equation sin((pi*x)/2000).  The equation models a nice curve that starts out linear at x=0,
		// then it's slope starts to decrease.
		// Since the speed of the left hand probably won't get above 1000 mm/s,
		// it's a good cap.

		self.volume = VOLUME_FROM_SPEED(ceilf([velocity magnitude]));

		NSLog(@"volume: %f\n", self.volume);
		NSLog(@"velocity_x: %f\n", velocity.x);
	}






	/*****************  Sample code below *******************/


	//        // Check if the hand has any fingers
	//        NSArray *fingers = [hand fingers];
	//        if ([fingers count] != 0) {
	//            // Calculate the hand's average finger tip position
	//            LeapVector *avgPos = [[LeapVector alloc] init];
	//            for (int i = 0; i < [fingers count]; i++) {
	//                LeapFinger *finger = [fingers objectAtIndex:i];
	//                avgPos = [avgPos plus:[finger tipPosition]];
	//            }
	//            avgPos = [avgPos divide:[fingers count]];
	//            NSLog(@"Hand has %ld fingers, average finger tip position %@",
	//                  [fingers count], avgPos);
	//        }
	//
	//        // Get the hand's sphere radius and palm position
	//        NSLog(@"Hand sphere radius: %f mm, palm position: %@",
	//              [hand sphereRadius], [hand palmPosition]);
	//
	//        // Get the hand's normal vector and direction
	//        const LeapVector *normal = [hand palmNormal];
	//        const LeapVector *direction = [hand direction];
	//
	//        // Calculate the hand's pitch, roll, and yaw angles
	//        NSLog(@"Hand pitch: %f degrees, roll: %f degrees, yaw: %f degrees\n",
	//              [direction pitch] * LEAP_RAD_TO_DEG,
	//              [normal roll] * LEAP_RAD_TO_DEG,
	//              [direction yaw] * LEAP_RAD_TO_DEG);
	//    }
	//
	//    NSArray *gestures = [frame gestures:nil];
	//    for (int g = 0; g < [gestures count]; g++) {
	//        LeapGesture *gesture = [gestures objectAtIndex:g];
	//        switch (gesture.type) {
	//            case LEAP_GESTURE_TYPE_CIRCLE: {
	//                LeapCircleGesture *circleGesture = (LeapCircleGesture *)gesture;
	//
	//                NSString *clockwiseness;
	//                if ([[[circleGesture pointable] direction] angleTo:[circleGesture normal]] <= LEAP_PI/4) {
	//                    clockwiseness = @"clockwise";
	//                } else {
	//                    clockwiseness = @"counterclockwise";
	//                }
	//
	//                // Calculate the angle swept since the last frame
	//                float sweptAngle = 0;
	//                if(circleGesture.state != LEAP_GESTURE_STATE_START) {
	//                    LeapCircleGesture *previousUpdate = (LeapCircleGesture *)[[controller frame:1] gesture:gesture.id];
	//                    sweptAngle = (circleGesture.progress - previousUpdate.progress) * 2 * LEAP_PI;
	//                }
	//
	//                NSLog(@"Circle id: %d, %@, progress: %f, radius %f, angle: %f degrees %@",
	//                      circleGesture.id, [Sample stringForState:gesture.state],
	//                      circleGesture.progress, circleGesture.radius,
	//                      sweptAngle * LEAP_RAD_TO_DEG, clockwiseness);
	//                break;
	//            }
	//            case LEAP_GESTURE_TYPE_SWIPE: {
	//                LeapSwipeGesture *swipeGesture = (LeapSwipeGesture *)gesture;
	//                NSLog(@"Swipe id: %d, %@, position: %@, direction: %@, speed: %f",
	//                      swipeGesture.id, [Sample stringForState:swipeGesture.state],
	//                      swipeGesture.position, swipeGesture.direction, swipeGesture.speed);
	//                break;
	//            }
	//            case LEAP_GESTURE_TYPE_KEY_TAP: {
	//                LeapKeyTapGesture *keyTapGesture = (LeapKeyTapGesture *)gesture;
	//                NSLog(@"Key Tap id: %d, %@, position: %@, direction: %@",
	//                      keyTapGesture.id, [Sample stringForState:keyTapGesture.state],
	//                      keyTapGesture.position, keyTapGesture.direction);
	//                break;
	//            }
	//            case LEAP_GESTURE_TYPE_SCREEN_TAP: {
	//                LeapScreenTapGesture *screenTapGesture = (LeapScreenTapGesture *)gesture;
	//                NSLog(@"Screen Tap id: %d, %@, position: %@, direction: %@",
	//                      screenTapGesture.id, [Sample stringForState:screenTapGesture.state],
	//                      screenTapGesture.position, screenTapGesture.direction);
	//                break;
	//            }
	//            default:
	//                NSLog(@"Unknown gesture type");
	//                break;
	//        }
	//    }
	//
	//    if (([[frame hands] count] > 0) || [[frame gestures:nil] count] > 0) {
	//        NSLog(@" ");
	//    }
	//
	//
}

-(void)onConnect:(LeapController *)controller
{
	NSLog(@"Connected");
	//    [controller enableGesture:LEAP_GESTURE_TYPE_CIRCLE enable:YES];
	//    [controller enableGesture:LEAP_GESTURE_TYPE_KEY_TAP enable:YES];
	//    [controller enableGesture:LEAP_GESTURE_TYPE_SCREEN_TAP enable:YES];
	//    [controller enableGesture:LEAP_GESTURE_TYPE_SWIPE enable:YES];

	// Bind the singleton MUAudioPlayer instance's volume property to this class's.
	[[MUAudioPlayer sharedInstance] bind:@"volume" toObject:self withKeyPath:@"volume" options:nil];
}


@end
