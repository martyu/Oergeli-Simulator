//
//  MUAudioPlayer.h
//  Oergeli Simulator
//
//  Created by Marty on 5/22/13.
//  Copyright (c) 2013 Marty Ulrich. All rights reserved.
//

#import <Foundation/Foundation.h>

enum { //TODO: change to bitmask
	MUPlay = 0,
	MUStop,
	MUPull,
	MUPush,
	MUBoth
};
typedef int MUPlayback;


@interface MUAudioPlayer : NSObject

@property(nonatomic)float volume;
@property(strong, nonatomic)NSMutableArray *currentlyPlaying; // Keeps an updated list of AVAudioPlayers currently being played.

- (void)btnAtIndex:(int)btnIndex stopPlay:(MUPlayback)stopPlay pushPull:(MUPlayback)pushPull volume:(float)theVolume;
+ (id)sharedInstance;

@end
