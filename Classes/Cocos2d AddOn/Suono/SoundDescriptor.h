//
//  SoundDescriptor.h
//  Prova
//
//  Created by mad4chip on 08/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"

@interface SoundDescriptor : NSObject
{
	NSString		*Name;
	float			SoundDuration;
	bool			AutoPan;
	float			FadeInTime;
	float			FadeOutTime;
	float			Delay;
	int				Repetitions;
	AudioChannel	*audioChannel;
	CDSoundSource	*soundSource;
}

@property (readonly, nonatomic)		NSString		*Name;
@property (readonly, nonatomic)		float			SoundDuration;
@property (readonly, nonatomic)		int				Repetitions;
@property (readwrite, nonatomic)	bool			AutoPan;
@property (readwrite, nonatomic)	float			FadeInTime;
@property (readwrite, nonatomic)	float			FadeOutTime;
@property (readonly, nonatomic)		float			Delay;
@property (readwrite, nonatomic)	ALuint			SoundId;
@property (readwrite, nonatomic,assign)	AudioChannel	*audioChannel;
@property (readwrite, nonatomic,assign)	CDSoundSource	*soundSource;



@property (readwrite, nonatomic)	float		gain;
@property (readwrite, nonatomic)	float		pitch;
@property (readwrite, nonatomic)	float		pan;


+(id)soundDescriptorWithName: (NSString*) SoundName;
+(id)soundDescriptorWithName: (NSString*) SoundName soundDuration: (float) Duration_ repetitions: (int)Repetitions delay: (float)delay fadeInTime: (float) FadeInTime fadeOutTime: (float) FadeOutTime autoPan: (bool) AutoPan;
+(id)soundDescriptorFromDictionary: (NSDictionary*)SoundData;
-(id)initWithName: (NSString*) SoundName soundDuration: (float) Duration_ repetitions: (int)Repetitions_ delay: (float)delay_ fadeInTime: (float) FadeInTime_ fadeOutTime: (float) FadeOutTime_ autoPan: (bool) AutoPan_;
-(CCAction*)getAudioActionWithRepetitions: (int)Rep;
-(void)playForTarget: (id)Target loop: (bool)Loop;
-(bool)isPlaying;
-(void)stop;
@end
