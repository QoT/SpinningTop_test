//
//
//  Prova
//
//  Created by mad4chip on 25/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameDataObject.h"
#import "SoundManager.h"
#import "GameCenterManager.h" 
#import "functions.h"
#import "ObjectiveCAddOn.h"


@implementation GameDataObject

@synthesize Video;

@synthesize Status;
-(void)setStatus:(NSMutableDictionary *)newStatus
{
	[Status release];
	Status = newStatus;
	[Status retain];
}


@synthesize MusicVolume;
-(void)setMusicVolume: (float)newMusicVolume
{
	MusicVolume				= newMusicVolume;
	SoundManager *manager	= [SoundManager sharedManager];
	manager.backgroundVolume= newMusicVolume;
}

@synthesize EffectVolume;
-(void)setEffectVolume: (float)newEffectVolume
{
	EffectVolume			= newEffectVolume;
	SoundManager *manager	= [SoundManager sharedManager];
	manager.volume			= newEffectVolume;
}

+(id)gameData
{
	return [[[self alloc] initData] autorelease];
}

-(id)initData
{
	if ((self = [super init]))
	{
		if (![self loadGameData])
		{
			[self initGameData];
			Video		= 1;//mostra il video introduttivo
			[self initExtraData];
			[self saveGameData];
		}
	}
	return self;
}

-(void)initGameData
{
	//carico in Status il plist di partenza
	Status					= [NSMutableDictionary dictionaryWithContentsOfFile:@"Games.plist"];
}

-(void)initExtraData
{
	MusicVolume		= DEFAULT_MUSIC_VALUE;
	EffectVolume	= DEFAULT_EFFECT_VALUE;
}

-(void)saveGameData
{
	NSUserDefaults		*Defaults		= [NSUserDefaults standardUserDefaults];
	
	[Defaults setObject: Status forKey: @"Status"];
	NSDictionary	*Options	= [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithFloat: MusicVolume],		@"MusicVolume",
								   [NSNumber numberWithFloat: EffectVolume],	@"EffectVolume",
								   nil];
	[Defaults setObject: Options forKey: @"Options"];
	[Defaults synchronize];
	
	//GAMECENTER
	/*
	GameCenterManager *sharedGameCenterManager = [GameCenterManager sharedGameCenterManager];
	for (NSString* Award in Awards_)
	{
		float Value = [[Awards_ objectForKey: Award] floatValue];
		[sharedGameCenterManager updateArchivements: Award percentComplete: Value];
	}
	[sharedGameCenterManager submitScore:Points[POINTS_INDEX] Category: LEADERBOARD_NAME];
	[GameCenterManager saveState];
	 */
}

-(void)saveGameStatus: (NSMutableDictionary*)NewStatus
{
	//aggiorna le variabili di stato alla fine della partita
	NSNumber			*Value;
	NSUserDefaults		*Defaults		= [NSUserDefaults standardUserDefaults];
	Value = [NSNumber numberWithInt:1];
	NSMutableDictionary *Stage =  [[[Defaults objectForKey: CurrentWorld] objectForKey:@"stages"] objectAtIndex: [Value intValue]];
	if([[Stage objectForKey:@"stars"] intValue] != -1)
	{
		Value = [NSNumber numberWithInt:[[NewStatus objectForKey:@"stars"]intValue]];
		[Stage setObject: Value forKey:@"stars"];
		Value = [NSNumber numberWithInt:[[NewStatus objectForKey:@"point"]intValue]];
		[Stage setObject:Value forKey:@"points"];
		
	}
	[Defaults synchronize];
}

-(bool)loadGameData
{
	NSNumber		*Value;
	NSUserDefaults	*Defaults			= [NSUserDefaults standardUserDefaults];
	if (!(Status = [Defaults objectForKey: @"Status"]))
		return false;
	
	NSDictionary	*Options;
	if (!(Options	= [Defaults	objectForKey: @"Options"]))		return false;
	if (!(Value		= [Options	objectForKey: @"MusicVolume"]))	return false;
	MusicVolume		= [Value floatValue];
	if (!(Value		= [Options	objectForKey: @"EffectVolume"]))return false;
	EffectVolume	= [Value floatValue];
	return true;
}

-(void)initGameCenter
{
	GameCenterManager *sharedGCManager;
	sharedGCManager		= [GameCenterManager sharedGameCenterManager];
	[sharedGCManager authenticateLocalPlayer];
	[GameCenterManager loadState];
}

-(void)unlockWorld:(NSString*)WorldName
{
	NSUserDefaults		*Defaults		= [NSUserDefaults standardUserDefaults];
	[[Defaults objectForKey: WorldName] setObject: [NSNumber numberWithBool: false] forKey: @"locked"];
	[Defaults synchronize];

}
-(void)unlockStage:(NSString*)WorldName stage:(int)Stage
{
	NSUserDefaults		*Defaults		= [NSUserDefaults standardUserDefaults];
	[[[[Defaults objectForKey: WorldName] objectForKey:@"stages"] objectAtIndex: Stage] setObject: [NSNumber numberWithBool: false] forKey: @"locked"];
	[Defaults synchronize];
}

-(void)dealloc
{
	[Status		release];
	[super dealloc];
}
	
@end
