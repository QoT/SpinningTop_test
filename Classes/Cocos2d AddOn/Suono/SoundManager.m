//
//  MusicDeshion.m
//  Prova
//
//  Created by Visone on 17/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"
#import <AudioToolbox/AudioServices.h>


static  SoundManager *sharedSoundManager	= nil;

@implementation SoundManager
@synthesize Ready;
@synthesize vibrationEnable;
@synthesize CurrentBackground;

-(void)setBackgroundVolume: (float) Volume	{	audioManager.backgroundMusic.volume	= Volume;	}
-(float)backgroundVolume					{	return	audioManager.backgroundMusic.volume;	}
-(void)setVolume: (float) Volume			{	soundEngine.masterGain	= Volume;				}
-(float)volume								{	return	soundEngine.masterGain;					}
-(void)vibrate
{
	if(vibrationEnable)
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

-(bool)LoadCompleted
{
	if ((!Ready) || (PreloadQueue))
			return	false;
	else	return	true;
}

+(SoundManager*)sharedManager
{
	if(sharedSoundManager == nil)
		sharedSoundManager	= [[SoundManager alloc] initSoundEngine];
	return 	sharedSoundManager;
}

-(id)initSoundEngine
{
	if ((self = [super init]))
	{
		MusicCollection		= [[NSMutableArray arrayWithCapacity: CHANNELNUM] retain];
		audioManager		= [CDAudioManager sharedManager];
		[audioManager setResignBehavior: kAMRBStopPlay autoHandle: YES];
		soundEngine			= audioManager.soundEngine;
		CurrentBackground	= nil;
		PreloadQueue		= nil;
		Lock				= [[NSLock alloc] init];
		for (int i = 0; i < CHANNELNUM; i++)
			AudioChannels[i]				= [[AudioChannel initAudioChannel]retain];		//vuoto
		Ready				= false;
		vibrationEnable		= true;
		[soundEngine setSourceGroupEnabled :0 enabled: true];
		if ([CDAudioManager sharedManagerState] != kAMStateInitialised)
				[NSThread detachNewThreadSelector:@selector(__initSoundEngine:) toTarget: self withObject:nil];
		else	[self __initSoundEngine: nil];
	}
	return self;
}

-(void)__initSoundEngine:(NSObject*) data
{
	[CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];
	while ([CDAudioManager sharedManagerState] != kAMStateInitialised)
		[NSThread sleepForTimeInterval:0.1];
	[soundEngine defineSourceGroups: [NSMutableArray arrayWithObject: [NSNumber numberWithInt: CHANNELNUM]]];
	Ready	= true;
}

-(void)preloadSounds: (NSArray*)SoundNames async: (bool)Async
{
	NSAssert(Ready, @"SoundManager not ready yet!!");
	bool		PreloadInProgress;

	[Lock lock];
	if (!PreloadQueue)
	{
		PreloadInProgress	= false;
		if ([SoundNames isKindOfClass: [NSString class]])
				PreloadQueue	= [[NSMutableArray arrayWithObject: SoundNames] retain];
		else	PreloadQueue	= [[NSMutableArray arrayWithArray: SoundNames] retain];
	}
	else
	{
		PreloadInProgress	= true;
		if ([SoundNames isKindOfClass: [NSString class]])
				[PreloadQueue addObject: SoundNames];
		else	[PreloadQueue addObjectsFromArray: SoundNames];
	}
	if (Async)
	{
		if (!PreloadInProgress)
			[NSThread detachNewThreadSelector:@selector(___preloadSounds:) toTarget: self withObject:nil];
		[Lock unlock];
		return;
	}
	else
	{
		[Lock unlock];
		if (!PreloadInProgress)
			[self ___preloadSounds: nil];
		else while (true)
		{
			[NSThread sleepForTimeInterval: 0.100];
			[Lock lock];
			if (!PreloadQueue)
			{
				[Lock unlock];
				return;
			}
			[Lock unlock];
		}
	}
}

-(void)___preloadSounds: (id)Obj
{
	NSAutoreleasePool *autoreleasepool;
    NSUInteger			SoundId;
	SoundInfo	*soundInfo;
	NSString	*SoundName;
	bool		Replace;	
	bool		Sync	= [NSThread isMainThread];
	if (!Sync)
	{
		autoreleasepool	= [[NSAutoreleasePool alloc] init];
		[[NSThread currentThread] setThreadPriority: 0.5];
	}

	while (true)
	{
		[Lock lock];
		if ((!PreloadQueue) || ([PreloadQueue count] == 0))
		{
			[PreloadQueue release];
			PreloadQueue	= nil;
			[Lock unlock];
			if (!Sync)	[autoreleasepool drain];
			return;
		}
		SoundName	= [PreloadQueue lastObject];
		[PreloadQueue removeLastObject];

		int index	= [self __getSoundId: SoundName shared:true error: false];
		if (index == -1)
		{//suono non presente in libreria
			SoundId			= [MusicCollection indexOfObject: [NSNull null]];
			if (SoundId == NSNotFound)
			{
				Replace		= false;
				SoundId		= [MusicCollection count];
			}
			else	Replace	= true;

			if (![soundEngine loadBuffer: SoundId filePath:SoundName])
			{
				[Lock unlock];
				NSAssert1(false, @"Error loading file %@", SoundName);//marina
				continue;
			}
			soundInfo		= [SoundInfo soundInfoWithSoundName: SoundName andDuration: [soundEngine bufferDurationInSeconds: SoundId] andBufferID: SoundId andShared:true];
			if (Replace)
					[MusicCollection replaceObjectAtIndex: SoundId withObject: soundInfo];
			else	[MusicCollection addObject: soundInfo];
		}
		else
		{
			SoundInfo	*soundInfo	= [MusicCollection objectAtIndex: index];
			[soundInfo addReference];
		}
		[Lock unlock];
	}
}

-(void)asyncPreloadSound: (NSString*)SoundName;
{
	[self preloadSounds: (NSArray*)SoundName async: true];
}

-(void)asyncPreloadSounds: (NSArray*)SoundNames;
{
	[self preloadSounds: SoundNames async: true];
}

-(void)preloadSound: (NSString*)SoundName
{
	[self preloadSounds: (NSArray*)SoundName async: false];
}

-(void)preloadSounds: (NSArray*)SoundNames
{
	[self preloadSounds: SoundNames async: false];
}

-(void)unloadSound: (NSString*)SoundName
{
	if (!SoundName)	return;
	[Lock lock];
	int			index		= [self __getSoundId: SoundName shared: true error: true];
	SoundInfo	*soundInfo	= [MusicCollection objectAtIndex: index];
	if ([soundInfo retainCount] == 1)
	{//suono caricato solo una volta
		[soundEngine unloadBuffer: index];
		[MusicCollection replaceObjectAtIndex: index withObject: [NSNull null]];//sostituisco l'oggetto senza eliminarlo per evitare lo slittamento degli indici
	}
	else	[soundInfo removeReference];
	[Lock unlock];
}

//non è protetto da mutexandShared:(bool)shared
-(int)__getSoundId: (NSString*)SoundName shared:(bool)shared error: (bool)Error
{
	int		index;
	int		Found	= -1;
	for (index = 0; index < [MusicCollection count]; index++)
	{
		SoundInfo *Elem = [MusicCollection objectAtIndex:index];
		if (((NSNull*)Elem != [NSNull null]) &&
			([Elem.SoundName isEqualToString: SoundName]))
		{
			Found	= index;
			CCLOG(@"Found value %d", Found);
			if ((Elem.Shared && shared) || (AudioChannels[index].toneSource.isPlaying))
				return index;
		}
	}
	if (Found >= 0)
	{
		index	= [MusicCollection count];
		CCLOG(@"Cannot share buffer using another one %d", index);
		if (![soundEngine loadBuffer: index filePath:SoundName])
			NSAssert1(false, @"Error loading file %@", SoundName);
	}
	else
	{
		NSAssert1(!Error,	@"Sound %@ not found", SoundName);
		return -1;
	}
	return index;
}

-(float)soundDuration: (NSString*)SoundName
{
	[Lock lock];
	int			index	= [self __getSoundId: SoundName shared:true error: true];
	SoundInfo	*temp	= [MusicCollection objectAtIndex: index];
	[Lock unlock];
	return temp.duration;
}

-(void)stopAllSounds
{
	NSAssert(Ready, @"SoundManager not ready yet!!");
	[soundEngine stopAllSounds];
}

-(void)stopAllSoundsForTarget: (id) Target
{
	NSAssert(Ready, @"SoundManager not ready yet!!");
	NSAssert(Target,@"Target must be != nil");
	for (int i = 0; i < CHANNELNUM; i++)
		if ((void*)AudioChannels[i].Target == (void*)Target)
			[AudioChannels[i].toneSource stop];
}

-(void)pauseAllSoundsForTarget: (id) Target
{
	NSAssert(Ready, @"SoundManager not ready yet!!");
	NSAssert(Target,@"Target must be != nil");
	for (int i = 0; i < CHANNELNUM; i++)
		if ((void*)AudioChannels[i].Target == (void*)Target)
			[AudioChannels[i].toneSource pause];
}

-(void)resumeAllSoundsForTarget: (id) Target
{
	NSAssert(Ready, @"SoundManager not ready yet!!");
	NSAssert(Target,@"Target must be != nil");
	for (int i = 0; i < CHANNELNUM; i++)
		if ((void*)AudioChannels[i].Target == (void*)Target)
			[AudioChannels[i].toneSource play];
}

-(void)pause
{
	NSAssert(Ready, @"SoundManager not ready yet!!");
	for (int i = 0; i < CHANNELNUM; i++)
	{
		if ([AudioChannels[i].toneSource isPlaying])
			[AudioChannels[i].toneSource pause];
		else
		{//se il canale non stà suonando rimuovo il riferimen to al target ed al toneSource per evitare che al resume partano suoni spuri
			AudioChannels[i].Target		= nil;	
			AudioChannels[i].toneSource	= nil;
		}
	}
}

-(void)resume
{
	NSAssert(Ready, @"SoundManager not ready yet!!");
	for (int i = 0; i < CHANNELNUM; i++)
		[AudioChannels[i].toneSource play];
}

-(int)__findAvailableChannel
{
	NSTimeInterval	OlderTime	= [NSDate timeIntervalSinceReferenceDate];
	int				OlderIndex;
//cerco un canale libero
	for (int i = 0; i < CHANNELNUM; i++)
		if (![AudioChannels[i].toneSource isPlaying])// || (![self isPlaying: AudioChannels[i].resouceID]))
			return i;
		else if (AudioChannels[i].StartTime < OlderTime)
		{
			OlderTime	= AudioChannels[i].StartTime;
			OlderIndex	= i;
		}
	CCLOG(@"No available channels, stoping the oldest");
//non ci sono canali liberi, fermo il suono più vecchio
	return	OlderIndex;
}

-(AudioChannel*)playSound: (NSString*)SoundName forTarget: (id) Target loop: (bool)Loop Shared:(bool)shared
{
	return [self playSound: SoundName forTarget: Target pitch: 1 pan: 0 gain: 1 loop: Loop Shared:shared];
}

-(AudioChannel*)playSound: (NSString*)SoundName forTarget: (id) Target pitch: (float)Pitch pan: (float)Pan gain: (float)Gain loop: (bool)Loop Shared:(bool)shared
{
	NSAssert(Ready, @"SoundManager not ready yet!!");
	//ricerca del suono nell'array Music Collection
	int index	= [self __getSoundId: SoundName shared: shared error: true];
	int	i		= [self __findAvailableChannel];
	CCLOG(@"SoundID %u name %@ Pitch %.2f, Pan %.2f, Gain %.2f, Loop %u, Shared %u", i, SoundName, Pitch, Pan, Gain, Loop, shared);
//	[AudioChannels[i].toneSource release];
	AudioChannels[i].Target		= Target;
	AudioChannels[i].SoundId	= index;
	AudioChannels[i].StartTime	= [NSDate timeIntervalSinceReferenceDate];
	AudioChannels[i].toneSource	= [soundEngine soundSourceForSound:index sourceGroupId:0];

	[AudioChannels[i].toneSource setPan:Pan];
	[AudioChannels[i].toneSource setGain:Gain];
	[AudioChannels[i].toneSource setPitch:Pitch];
	[AudioChannels[i].toneSource setLooping:Loop];	
	if (![AudioChannels[i].toneSource play])
		CCLOG(@"Play %@ doesn't start!!", SoundName);

	return AudioChannels[i];
}

-(CDSoundSource*)soundSourceForSound: (NSUInteger)resourceID
{
	NSAssert(Ready, @"SoundManager not ready yet!!");
	CDSoundSource *toneSource = [soundEngine soundSourceForSound: resourceID sourceGroupId:0];
//	[toneSource play];
	return	toneSource;
}
				 
-(void)playBackgroundMusic: (NSString*)SoundName
{
	NSAssert(Ready, @"SoundManager not ready yet!!");
	if (!SoundName)
	{//è stato chiesto di fermare il suono
		[self stopBackgroundMusic];
		return;
	}
	if ([CurrentBackground isEqualToString: SoundName])
	{
		[audioManager resumeBackgroundMusic];
		return;//il suono è già in esecuzione non lo fermo
	}
	[CurrentBackground release];
	CurrentBackground	= [SoundName retain];
	[audioManager playBackgroundMusic: SoundName loop: true];
}

-(void)pauseBackgroundMusic
{
	[audioManager pauseBackgroundMusic];
}

-(void)resumeBackgroundMusic
{
	[audioManager resumeBackgroundMusic];
}

-(void)stopBackgroundMusic
{
	[CurrentBackground release];
	CurrentBackground	= nil;
	[audioManager stopBackgroundMusic];
}

-(void)dealloc
{
	[Lock release];
	[CurrentBackground release];
	[PreloadQueue release];
	[MusicCollection release];
	for(int i=0;i<CHANNELNUM;i++)
		[AudioChannels[i] release];
	[super dealloc];
}

@end

//------------------------------------------------------------------------------------------------------------------------------------
@implementation SoundInfo
@synthesize SoundName;
@synthesize duration;
@synthesize Shared;
@synthesize BufferID;
@synthesize SoundSource;


-(void)setSoundName: (NSString*)SName
{
	[SoundName release];
	SoundName = SName;
	[SoundName retain];
}

+(id)soundInfoWithSoundName:(NSString*)Name andDuration:(float)dur andBufferID:(NSUInteger)buffID andShared:(bool)shared
{
	return [[[self alloc] initInfoWithSoundName:Name andDuration:dur andBufferID:buffID andShared:shared] autorelease];
}

-(id)initInfoWithSoundName: (NSString*)Name andDuration:(float)dur andBufferID:(NSUInteger)buffID andShared:(bool)shared
{
	if ((self = [super init]))
	{
		self.SoundName	= Name;
		duration		= dur;
		BufferID		= buffID;	
		Shared			= shared;
		SoundSource		= [[SoundManager sharedManager] soundSourceForSound:BufferID];
		[SoundSource retain];
	}
	return self;
}

-(void)addReference
{
	[self retain];
}

-(void)removeReference
{
	[self release];
}

-(void)dealloc
{
	[SoundSource release];
	[SoundName release];
	[super dealloc];
}

-(NSString*)description
{
	return	[NSString stringWithFormat:@"<%@ = %08X SoundName: %@ duration: %.2f retaincount: %d>", [self class], (unsigned int)self, SoundName, duration, [self retainCount]];
}
@end

//------------------------------------------------------------------------------------------------------------------------------------
@implementation AudioChannel
@synthesize Target;
@synthesize SoundId;
@synthesize StartTime;
@synthesize toneSource;

-(void)setToneSource:(CDSoundSource *)newToneSource
{
	[toneSource stop];
	[toneSource release];
	toneSource	= newToneSource;
	[toneSource retain];
}

+(id)initAudioChannel
{
	return [[[self alloc] initAudioChannel] autorelease];
}

-(id)initAudioChannel
{
	if ((self = [super init]))
	{
		Target			= nil;
		StartTime		= 0;
		SoundId			= -1;	
		toneSource		= nil;
	}
	return self;
}

-(void)dealloc
{
	[toneSource release];
	[super dealloc];
}

@end

