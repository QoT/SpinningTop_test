//
//  MusicDeshion.h
//  Prova
//
//  Created by Visone on 17/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "CocosDenshion.h"
#import "CDAudioManager.h"

#define CHANNELNUM		32
#define	SOUND_AT_LEFT	-1
#define	SOUND_RIGHT		1
#define	SOUND_AT_CENTER	0


/*
* @param pitch pitch multiplier. e.g 1.0 is unaltered, 0.5 is 1 octave lower. 
* @param pan stereo position. -1 is fully left, 0 is centre and 1 is fully right.
* @param gain gain multiplier. e.g. 1.0 is unaltered, 0.5 is half the gain
* @param loop should the sound be looped or one shot.
 */

//----------------------------------------------------------------------------------------------------------------------------------------------------------
@interface AudioChannel : CDSoundSource

{
	id				Target;		//nil if available
	int				SoundId;	//sound ID del suono in esecuzione
	NSTimeInterval	StartTime;
	CDSoundSource	*toneSource;
}

@property(nonatomic,readwrite,assign)	id	Target;
@property(nonatomic,readwrite)	int	SoundId;
@property(nonatomic,readwrite)	NSTimeInterval	StartTime;
@property(nonatomic,readwrite,assign)	CDSoundSource	*toneSource;

+(id)initAudioChannel;
-(id)initAudioChannel;


@end

//----------------------------------------------------------------------------------------------------------------------------------------------------------

@interface SoundManager : NSObject
{
	NSMutableArray		*MusicCollection;
	CDAudioManager		*audioManager;
	CDSoundEngine		*soundEngine;
	AudioChannel		*AudioChannels[CHANNELNUM];
	AVAudioPlayer		*audioSourcePlayer;
	NSString			*CurrentBackground;
	NSMutableArray		*PreloadQueue;
	NSLock				*Lock;
	bool				Ready;
	bool				vibrationEnable;
}

@property (nonatomic, readonly)				bool		Ready;
@property (nonatomic, readonly)				bool		LoadCompleted;
@property (nonatomic, readwrite)			float		backgroundVolume;
@property (nonatomic, readwrite)			float		volume;
@property (nonatomic, readwrite)			bool		vibrationEnable;
@property (nonatomic, readonly)				NSString	*CurrentBackground;


+(SoundManager*)sharedManager;
-(id)initSoundEngine;
-(void)__initSoundEngine:(NSObject*) data;
-(void)preloadSounds: (NSArray*)SoundNames async: (bool)Async;
-(void)asyncPreloadSound: (NSString*)SoundName;
-(void)asyncPreloadSounds: (NSArray*)SoundNames;
-(void)preloadSound: (NSString*)SoundName;
-(void)preloadSounds: (NSArray*)SoundNames;
-(void)___preloadSounds: (id)Obj;
-(void)unloadSound: (NSString*)SoundName;
-(int)__getSoundId: (NSString*)SoundName shared:(bool)shared error: (bool)Error;
-(float)soundDuration: (NSString*)SoundName;
-(void)stopAllSounds;
-(void)stopAllSoundsForTarget: (id) Target;
-(void)pauseAllSoundsForTarget: (id) Target;
-(void)resumeAllSoundsForTarget: (id) Target;
-(void)pause;
-(void)resume;
-(int)__findAvailableChannel;
-(AudioChannel*)playSound: (NSString*)SoundName forTarget: (id) Target loop: (bool) Loop Shared:(bool)shared;
-(AudioChannel*)playSound: (NSString*)SoundName forTarget: (id) Target pitch: (float)Pitch pan: (float)Pan gain: (float)Gain loop: (bool)Loop Shared:(bool)shared;
-(CDSoundSource*)soundSourceForSound: (NSUInteger)resourceID;
-(void)playBackgroundMusic: (NSString*)SoundName;
-(void)pauseBackgroundMusic;
-(void)resumeBackgroundMusic;
-(void)stopBackgroundMusic;
-(void)vibrate;
@end

//-----------------------------------------------------------------------------------------------------------------------------------------------------------
@interface SoundInfo : NSObject
{
	NSString			*SoundName;
	float				duration;
    NSUInteger			BufferID;
	bool				Shared;
	CDSoundSource		*SoundSource;
}

@property(nonatomic,readwrite, assign)	NSString	*SoundName;
@property(nonatomic,readwrite)			float		duration;
@property(nonatomic,readwrite)			NSUInteger	BufferID;
@property(nonatomic,readwrite)			bool		Shared;
@property(nonatomic,readwrite,assign)	CDSoundSource		*SoundSource;


+(id)soundInfoWithSoundName:(NSString*)Name andDuration:(float)dur andBufferID:(NSUInteger)buffID andShared:(bool)shared;
-(id)initInfoWithSoundName: (NSString*)Name andDuration:(float)dur andBufferID:(NSUInteger)buffID andShared:(bool)shared;
-(void)addReference;
-(void)removeReference;
@end

