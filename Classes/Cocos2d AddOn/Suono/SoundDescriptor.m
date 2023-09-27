//
//  SoundDescriptor.m
//  Prova
//
//  Created by mad4chip on 08/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SoundDescriptor.h"
#import "AudioActions.h"
#import "RunAction.h"
#import "ObjectiveCAddOn.h"
#import "CocosAddOn.h"

@implementation SoundDescriptor
@synthesize Name;
@synthesize AutoPan;
@synthesize FadeInTime;
@synthesize FadeOutTime;
@synthesize SoundId;
@synthesize SoundDuration;
@synthesize Repetitions;
@synthesize Delay;
@synthesize audioChannel;
@synthesize soundSource;

+(id)soundDescriptorWithName: (NSString*) SoundName
{
	return [[[self alloc] initWithName: SoundName soundDuration: 0 repetitions: 1 delay: 0 fadeInTime: 0 fadeOutTime: 0 autoPan: false ] autorelease];
}

+(id)soundDescriptorWithName: (NSString*) SoundName soundDuration: (float) Duration_ repetitions: (int)Repetitions delay: (float)delay fadeInTime: (float) FadeInTime fadeOutTime: (float) FadeOutTime autoPan: (bool) AutoPan
{
	return [[[self alloc] initWithName: SoundName soundDuration: Duration_ repetitions: Repetitions delay: delay fadeInTime: FadeInTime fadeOutTime: FadeOutTime autoPan: false] autorelease];
}

+(id)soundDescriptorFromDictionary: (NSDictionary*)SoundData
{
	NSString	*SoundName;
	NSString	*Value;
	bool		AutoPan_		= false;
	float		FadeInTime_		= 0;
	float		FadeOutTime_	= 0;
	float		Delay_			= 0;
	int			Repetitions_	= 1;
	

	if ([SoundData isKindOfClass: [NSString class]])
		SoundName	= (NSString*)SoundData;
	else
	{
		SoundName	= [SoundData localizedObjectForKey: @"file"];
		if ((Value = [SoundData objectForKey:@"soundpan"]))
			AutoPan_	= [Value boolValue];
		if ((Value = [SoundData objectForKey:@"fadeintime"]))
			FadeInTime_	= [Value floatValue];
		if ((Value = [SoundData objectForKey:@"fadeouttime"]))
			FadeOutTime_	= [Value floatValue];
		if ((Value = [SoundData objectForKey:@"delay"]))
			Delay_	= [Value floatValue];
		if ((Value = [SoundData objectForKey:@"repeat"]))
			Repetitions_	= [Value intValue];
	}
	NSAssert(SoundName, @"Please specify filename");
	return [[[self alloc] initWithName: SoundName soundDuration: 0 repetitions: Repetitions_ delay: Delay_ fadeInTime: FadeInTime_ fadeOutTime: FadeOutTime_ autoPan: AutoPan_] autorelease];
}

-(id)initWithName: (NSString*) SoundName soundDuration: (float) Duration_ repetitions: (int)Repetitions_ delay: (float)delay_ fadeInTime: (float) FadeInTime_ fadeOutTime: (float) FadeOutTime_ autoPan: (bool) AutoPan_ 
{
	if ((self = [super init]))
	{
		SoundManager *Manager;
		Manager		= [SoundManager sharedManager];
		Name		= [SoundName retain];
		[Manager preloadSound: Name];
		if (Duration_ == 0)
				SoundDuration	= [Manager soundDuration: Name];
		else	SoundDuration	= Duration_;
		AutoPan		= AutoPan_;
		FadeInTime	= FadeInTime_;
		FadeOutTime	= FadeOutTime_;
		Delay		= delay_;
		NSAssert(SoundDuration > FadeInTime + FadeOutTime, @"The sound is shorter than fade time");
		SoundId		= -1;
		soundSource	= nil;
	}
	return self;
}

-(CCAction*)getAudioActionWithRepetitions: (int)Rep
{
	if (Rep == 0)//LoopPlaySound gestisce in maniera autonoma i fade, in questo modo non ho bisogno di usare un RunAction
		return [LoopPlaySound actionWithDescriptor: self];
	else
	{
		CCFiniteTimeAction	*SoundAction;
		CCFiniteTimeAction	*Actions[4];
		int					i	= 0;

		Rep				= Rep * Repetitions;
		SoundAction		= [PlaySound actionWithDescriptor: self];
		if (Rep > 1)
			SoundAction	= [CCRepeat actionWithAction: (CCFiniteTimeAction*)SoundAction times: Rep];

		if (FadeInTime > 0)
			Actions[i++]	= [AudioFadeIn	actionWithDescriptor: self];
		if (FadeOutTime > 0)
		{
			Actions[i++]	= [CCDelayTime actionWithDuration: SoundDuration * Rep - (FadeInTime + FadeOutTime)];
			Actions[i++]	= [AudioFadeOut	actionWithDescriptor: self];
		}

		if (i > 0)
		{
			Actions[i]				= nil;
			if (i > 1)	Actions[0]	= [CCSequence actionsWithCArray: Actions];
			if (Actions[0])
				SoundAction	= [CCSpawn actionOne: SoundAction two: Actions[0]];
		}
		if (Delay)	SoundAction	= [CCSequence actionOne: [CCDelayTime actionWithDuration: Delay] two: SoundAction];
		return SoundAction;
	}
}

-(float)gain	{	return	soundSource.gain;	}
-(float)pitch	{	return	soundSource.pitch;	}
-(float)pan		{	return	soundSource.pan;	}

-(void)setGain:	(float)newValue	{	soundSource.gain	= newValue;	}
-(void)setPitch:(float)newValue	{	soundSource.pitch	= newValue;	}
-(void)setPan:	(float)newValue	{	soundSource.pan		= newValue;	}

-(void)playForTarget: (id)Target loop: (bool)Loop
{
	bool	shared	= true;
	if ((FadeInTime != 0) || (FadeOutTime != 0) || (AutoPan))
		shared	= false;
	if (soundSource)//il suono stà ancora suonando, lo riavvolgo
	{
		[soundSource rewind];
		[soundSource play];
	}
	else
	{
		SoundManager *Manager	= [SoundManager sharedManager];
		audioChannel	= [Manager playSound: Name forTarget: Target loop: Loop Shared: shared];
		soundSource		= audioChannel.toneSource;
		[soundSource retain];
	}
	CCScheduler	*sharedScheduler	= [CCScheduler sharedScheduler];
	[sharedScheduler unscheduleAllSelectorsForTarget: self];
	if (!Loop)
		[sharedScheduler scheduleSelector:@selector(stopTarget:) forTarget:self interval:SoundDuration paused:false];
}

-(bool)isPlaying
{
	return soundSource.isPlaying;
}

-(void)stopTarget:(float)timerDuration
{
	[self stop];
}
-(void)stop
{
	[soundSource stop];
	[[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget: self];
	[soundSource release];
	soundSource	= nil;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithName: Name soundDuration: SoundDuration repetitions: Repetitions delay: Delay fadeInTime: FadeInTime fadeOutTime: FadeOutTime autoPan: AutoPan];
	return copy;
}

-(void)dealloc
{
	[soundSource stop];
	[[SoundManager sharedManager] unloadSound: Name];
	[Name release];
	[super dealloc];
}
@end