//
//  MUAudioPlayer.m
//  Oergeli Simulator
//
//  Created by Marty on 5/22/13.
//  Copyright (c) 2013 Marty Ulrich. All rights reserved.
//

#import "MUAudioPlayer.h"
#import <AVFoundation/AVAudioPlayer.h>

@interface MUAudioPlayer ()

// TODO: add char for bitmask to keep track of what notes are being played.


@property(strong, nonatomic)NSMutableArray *audioPlayersPullArr;
@property(strong, nonatomic)NSMutableArray *audioPlayersPushArr;


@end

@implementation MUAudioPlayer

+ (id)sharedInstance
{
    // the instance of this class is stored here
    static MUAudioPlayer *myInstance = nil;

    // check to see if an instance already exists
    if (nil == myInstance)
	{
		myInstance = [[MUAudioPlayer alloc] init];
		
		// Initialize button sounds here
		myInstance.audioPlayersPullArr = [[NSMutableArray alloc] initWithCapacity:31];
		NSError *error;
		for (int i = 0; i <= 30; i++) {
			NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%i_pull", i] ofType:@"mp3"];
			NSURL *soundURL = [NSURL fileURLWithPath:path];
			AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
			if(error) {
				NSLog(@"Error loading sound:  %@\n", [error description]);
				[NSException raise:@"MUSoundLoadingException" format:@"Couldn't load button sound"];
			} else {
				//TODO:
//				[player bind:@"volume" toObject:self withKeyPath:@"volume" options:nil];
				[myInstance.audioPlayersPullArr addObject:player];
			}
		}

		
		myInstance.audioPlayersPushArr = [[NSMutableArray alloc] initWithCapacity:31];
		for (int i = 0; i <= 30; i++) {
			NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%i_push", i] ofType:@"mp3"];
			NSURL *soundURL = [NSURL fileURLWithPath:path];
			AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
			if(error) {
				NSLog(@"Error loading sound:  %@\n", [error description]);
				[NSException raise:@"MUSoundLoadingException" format:@"Couldn't load button sound"];
			} else {

				//TODO:
//				[player bind:@"volume" toObject:self withKeyPath:@"volume" options:nil];
				[myInstance.audioPlayersPushArr addObject:player];
			}
		}

    }
    // return the instance of this class
    return myInstance;
}


// btnIndex is top to bottom, starting with 'Z', ending with '['.
// theVolume can be NULL if pushPull is MUStop.
- (void)btnAtIndex:(int)btnIndex stopPlay:(MUPlayback)stopPlay pushPull:(MUPlayback)pushPull volume:(float)theVolume
{
	if(btnIndex < 0 || btnIndex > 30) {
		return;
	}

	// The pull and push AVAudioPlayers at index 'btnIndex' on the keyboard.
	AVAudioPlayer *pullPlayer = ((AVAudioPlayer*)[self.audioPlayersPullArr objectAtIndex:btnIndex]);
	AVAudioPlayer *pushPlayer = ((AVAudioPlayer*)[self.audioPlayersPushArr objectAtIndex:btnIndex]);


	switch (stopPlay) {
		case MUPlay:
			if (pushPull == MUPull) {
				[self.currentlyPlaying addObject:pullPlayer];
				[pullPlayer play];
			} else if (pushPull == MUPush) {
				[self.currentlyPlaying addObject:pushPlayer];
				[pushPlayer play];
			}
			break;
		case MUStop:
			if (pushPull == MUPull || pushPull == MUBoth) {
				if ([pullPlayer isPlaying]) {
					[pullPlayer pause];
					[pullPlayer setCurrentTime:0.0];
					[self.currentlyPlaying removeObject:pullPlayer];
				}
			}

			if (pushPull == MUPush || pushPull == MUBoth) {
				if ([pushPlayer isPlaying]) {
					[pushPlayer pause];
					[pushPlayer setCurrentTime:0.0];
					[self.currentlyPlaying removeObject:pushPlayer];
				}
			}
			break;
		default:
			break;
	}
}

@end
