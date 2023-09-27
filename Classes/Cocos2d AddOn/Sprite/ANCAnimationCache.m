//
//  ANCAnimationCache.m
//  Prova
//
//  Created by mad4chip on 26/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANCAnimationCache.h"
#import "GameConfig.h"
#import "ObjectiveCAddOn.h"
#import "functions.h"
#import "CocosAddOn.h"
/*
@interface  ANCDictionary : NSObject
{
	NSMutableDictionary	*Dict;
}
+(id)dictionaryWithCapacity: (int)Length;
-(id)initWithCapacity: (int)Length;
-(void)setObject: (id)obj forKey: (id)key;
-(void)removeObjectforKey: (id)key;
-(id)objectForKey: (id)key;
-(int)count;
@end

@implementation ANCDictionary

+(id)dictionaryWithCapacity: (int)Length
{
	return [[self alloc] initWithCapacity: Length];
}

-(id)initWithCapacity: (int)Length
{
	if ((self = [super init]))
		Dict	= [NSMutableDictionary dictionaryWithCapacity: Length];
	return self;
}

-(void)setObject: (id)obj forKey: (id)key
{
	[Dict setObject: obj forKey: key];
}

-(void)removeObjectforKey: (id)key
{
	[Dict removeObjectForKey: key];
}

-(id)objectForKey: (id)key
{
	return [Dict objectForKey: key];
}

-(int)count
{
	return [Dict count];
}

-(id)retain
{
	NSLog(@"retain OLD Retain count:%u", self.retainCount);
	id ret	= [super retain];
	NSLog(@"retain NEW Retain count:%u", self.retainCount);
	return ret;
}

-(void)release
{
	NSLog(@"retain OLD Retain count:%u", self.retainCount);
	[super release];
	NSLog(@"retain NEW Retain count:%u", self.retainCount);
}

-(void)dealloc
{
	[Dict release];
	[super dealloc];
}
@end
*/

@implementation ANCAnimationCache
static ANCAnimationCache *sharedAnimationCache_=nil;
@synthesize	animations	= animations_;
@synthesize	cleanInProgress;

+(ANCAnimationCache *)sharedAnimationCache
{
	if (!sharedAnimationCache_)
		sharedAnimationCache_ = [[ANCAnimationCache alloc] init];
	
	return sharedAnimationCache_;
}

+(id)alloc
{
	NSAssert(sharedAnimationCache_ == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

-(NSString*)description
{
	NSString	*Output		= @"";
	int			Animations	= 0;
	int			Files		= [animations_ count];
	for (NSString *File in animations_)
	{
		Output								= [Output stringByAppendingFormat: @"\n\"%@\" =", File];
		NSDictionary	*animationsForFile	= [animations_ objectForKey: File];
		for (NSString *Name in animationsForFile)
		{
			Output	= [Output stringByAppendingFormat: @"\t\"%@\" = %@\n", Name, [[animationsForFile objectForKey: Name] description]];
			Animations++;
		}
	}
	return	[Output stringByAppendingFormat: @"ANCAnimationCache cache content %d files, %d animations\n", Files, Animations];
}

-(void)removeAllAnimations
{
	NSLog(@"Clearing all caches");
	[Lock lock];
	[animations_ removeAllObjects];
	[Lock unlock];
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
	[[CCTextureCache sharedTextureCache] removeAllTextures];

//	for(GLuint	i=0; i<1000; i++)
//		glDeleteTextures(1, &i);
}

-(id) init
{
	if( (self=[super init]) )
	{
		Lock			= [[NSLock alloc] init];
		animations_		= [[NSMutableDictionary alloc] initWithCapacity: 20];
		cleanInProgress	= false;
		cleanLockOut	= 0;
	}
	return self;
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	sharedAnimationCache_	= nil;
	[Lock release];
	[animations_ release];
	[super dealloc];
}

-(void)lockCache	{	[Lock lock];	}
-(void)unlockCache	{	[Lock unlock];	}

-(void) addAnimation:(ANCAnimation*)animation name:(NSString*)name
{
	[self addAnimation:animation name: name forObj: nil];
}

-(void)addAnimation:(ANCAnimation*)animation name:(NSString*)name forObj: (NSString*)objName
{
	if (!objName)
	{
		NSArray	*nameParts	= [name componentsSeparatedByString: @"@"];
		NSAssert([nameParts count] == 2, @"Please specify objName");
		name				= [nameParts objectAtIndex: 0];
		objName				= [nameParts objectAtIndex: 1];
	}
	if (!name)	name	= objName;

	[Lock lock];
	NSMutableDictionary	*objDict	= [animations_ objectForKey: objName];
	if (!objDict)
	{
		objDict		= [NSMutableDictionary dictionaryWithCapacity: 5];
		[animations_ setObject: objDict forKey: objName];
	}
	[objDict setObject: animation forKey:name];
	[Lock unlock];
}

-(void) removeAnimationByName:(NSString*)name forTarget: (ANCSprite*)Target
{
	if ((!Target.animations) && (![self loadAnimationsIntoTarget: Target]))
		return;
	if (!name)	name	= Target.Filename;
	[Lock lock];//elimina l'animazione col nome Name ed anche col nome File se è quella di default
	if ([Target.animations objectForKey: Target.Filename] == [Target.animations objectForKey: name])
		[Target.animations removeObjectForKey: Target.Filename];
	[Target.animations removeObjectForKey: name];
	[Lock unlock];
}

-(bool) animationExist:(NSString*)name forObj: (NSString*)objName
{
	[Lock lock];
	NSMutableDictionary	*Animations = [animations_ objectForKey: objName];

	if (!Animations)
	{
		[Lock unlock];
		return false;
	}
	if (!name)	name	= objName;
	id Result	= [Animations objectForKey: name];
	[Lock unlock];

	if (Result)	 return true;
	return false;
}

-(ANCAnimation*) animationByName:(NSString*)name
{
	return [self animationByName: name forObj: nil];
}

-(ANCAnimation*) animationByName:(NSString*)name forObj: (NSString*)objName
{
	if (!objName)
	{
		NSArray	*nameParts	= [name componentsSeparatedByString: @"@"];
		NSAssert([nameParts count] == 2, @"Please specify objName");
		name				= [nameParts objectAtIndex: 0];
		objName				= [nameParts objectAtIndex: 1];
	}
	if (!name)	name	= objName;

	[Lock lock];
	NSMutableDictionary	*objDict	= [animations_ objectForKey: objName];
	if (!objDict)
	{
		[Lock unlock];
		return nil;
	}
	ANCAnimation	*Animation	= [objDict objectForKey:name];
	[Lock unlock];
	return Animation;
}

-(ANCAnimation*) animationByName:(NSString*)name forTarget: (ANCSprite*)Target
{
	if ((!Target.animations) && (![self loadAnimationsIntoTarget: Target]))
		return nil;
	if (!name)	name	= Target.Filename;
	[Lock lock];
	id Result	= [Target.animations objectForKey: name];
	[Lock unlock];

	return Result;
}

-(bool) loadAnimationsIntoTarget: (ANCSprite*)Target
{
	if (!Target.Filename)	return false;
	[Lock lock];
	NSMutableDictionary	*Animations = [animations_ objectForKey: Target.Filename];
	if (!Animations)
	{
		[Lock unlock];
		return false;
	}
	Target.animations	= Animations;//verrà ritenuto da ANCSprite
	[Lock unlock];
	return true;
}

-(void)loadAtlasFile:(NSString *)File
{
	if ([File isKindOfClass: [NSArray class]])
	{
		for (NSString *Value in (NSArray*)File)
			[self loadAtlasFile: Value];
		return;
	}
	if ([File isEqualToString: @""])	return;

	if (![[CCTextureCache sharedTextureCache] getAuxGLcontext])
		CCLOG(@"Error getting context");


	ANCAnimation	*Animation;
	CCTexture2D		*Texture;
	if(![[File pathExtension] isEqualToString:@"plist"])
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath: [CCFileUtils fullPathFromRelativePath:File]])
		{
			Texture		= [[CCTextureCache sharedTextureCache] addImage: File];
			if (Texture)
			{
				[[CCTextureCache sharedTextureCache] releaseAuxGLcontext];
				return;
			}
		}
		NSAssert1(false, @"Unable to load image %@", File);
	}

	CCSpriteFrameCache	*FrameCache			= [CCSpriteFrameCache sharedSpriteFrameCache];//ottiene un'istanza della cache dei frame
	NSDictionary		*FileContent		= [NSDictionary dictionaryWithContentsOfFile: [CCFileUtils fullPathFromRelativePath:File]];
	NSString			*Atlas				= [FileContent localizedObjectForKey:@"atlas"];
	
	NSAssert1(FileContent, @"Unable to load file %@", File);
	if (!Atlas)//file plist standard
	{
		if (![FrameCache addSpriteFramesWithFile:File])
			NSAssert1(false, @"Unable to load file %@", File);
		[[CCTextureCache sharedTextureCache] releaseAuxGLcontext];
		return;
	}
	
	//file plist per le animazioni
	if ((![Atlas isKindOfClass: [NSArray class]])			&&
		(![[Atlas pathExtension] isEqualToString:@"plist"])	&&
		(![Atlas isEqualToString: @""]))
	{//file immagine normale
		if (![[CCTextureCache sharedTextureCache] addImage: Atlas forKey: File])
			NSAssert1(false, @"Unable to load image %@", File);
		[[CCTextureCache sharedTextureCache] releaseAuxGLcontext];
		return;
	}

	if ([self animationExist: File forObj: File ])
	{
		[[CCTextureCache sharedTextureCache] releaseAuxGLcontext];
		return;//plist già caricato
	}

	NSDictionary		*States				= [FileContent localizedObjectForKey:@"states"];
	NSString			*DefaultState		= [FileContent localizedObjectForKey:@"defaultstate"];
	int					DefaultFrame		= -1;
	
	if ([Atlas isKindOfClass: [NSArray class]])
	{
		for (NSString *Value in (NSArray*)Atlas)
			if (![FrameCache addSpriteFramesWithFile: Value])	NSAssert1(false, @"Unable to load file %@", Value);
	}
	else if	((![Atlas isEqualToString: @""]) &&
			 (![FrameCache addSpriteFramesWithFile: Atlas]))	NSAssert1(false, @"Unable to load file %@", Atlas);
	
	NSAssert1((States) && ([States count] != 0), @"Nothing to load from file %@", File);
	if (!DefaultState)
	{
		DefaultState	= [[States allKeys] objectAtIndex: 0];
		CCLOG(@"Default state not found using %@ as default", DefaultState);
	}
	else
	{
		NSArray				*DefaultParts		= [DefaultState componentsSeparatedByString: @"@"];
		if ([DefaultParts count] == 2)
		{
			DefaultState						= [DefaultParts objectAtIndex: 1];
			DefaultFrame						= [[DefaultParts objectAtIndex: 0] intValue];
		}
	}
	NSMutableDictionary	*Aliases	= [NSMutableDictionary dictionaryWithCapacity: 0];
	for (NSString *StateName in States)
	{
		NSString		*Value;
		NSDictionary	*State			= [States objectForKey:StateName];
		NSMutableArray	*Frames			= [NSMutableArray arrayWithCapacity: 20];
		if ([State isKindOfClass: [NSString class]])
		{
			if ([States objectForKey: State])//alias
			{
				[Aliases setObject: State forKey: StateName];
				continue;
			}
			NSString		*FrameName	= (NSString*)State;
			CCSpriteFrame	*Frame		= [FrameCache spriteFrameByName: FrameName];
			NSAssert1(Frame, @"Unable to retrive frame %@ from cache", FrameName);
			[Frames addObject: Frame];

			Animation				= [ANCAnimation animationWithFrames: Frames];
			Animation.WalkLength	= 0;//l'animazione ha un solo frame quindi questi parametri non hanno senso
			Animation.delay			= DEFAULT_FRAME_DELAY;
			Animation.HideOnEnd		= false;
		}
		else
		{
			NSArray			*FramesIndexes	= [State localizedObjectForKey:@"frames"];
			NSAssert1(FramesIndexes,	@"Specify FramesIndexes in %@", File);
			for (NSDictionary *FrameIndex in FramesIndexes)
			{
				NSString	*FrameNameMask	= [FrameIndex localizedObjectForKey:@"framename"];
				NSAssert1(FrameNameMask,	@"Specify framename in %@", File);
				Value		= [FrameIndex localizedObjectForKey:@"from"];
				NSAssert1(Value, @"Missing from value for state %@", StateName);
				int	From	= [Value intValue];
				Value		= [FrameIndex localizedObjectForKey:@"to"];
				NSAssert1(Value, @"Missing to value for state %@", StateName);
				int	To		= [Value intValue];
				if (From >= To)
					for (;From >= To; From--)
					{
						NSString		*FrameName	= [NSString stringWithFormat:FrameNameMask, From];
						CCSpriteFrame	*Frame		= [FrameCache spriteFrameByName: FrameName];
						if (!Frame)		Frame		= [CCSpriteFrame frameWithFile: FrameName];
						NSAssert1(Frame, @"Unable to retrive frame %@ from cache", FrameName);
						[Frames addObject: Frame];
					}
				else
					for (;From <= To; From++)
					{
						NSString		*FrameName	= [NSString stringWithFormat:FrameNameMask, From];
						CCSpriteFrame	*Frame		= [FrameCache spriteFrameByName: FrameName];
						if (!Frame)		Frame		= [CCSpriteFrame frameWithFile: FrameName];
						NSAssert1(Frame, @"Unable to retrive frame %@ from cache", FrameName);
						[Frames addObject: Frame];
					}
			}

			Animation				= [ANCAnimation animationWithFrames: Frames];
			Value					= [State objectForKey:@"WalkLength"];
			if (Value)	Animation.WalkLength	= [Value floatValue] * SpeedFactor;
			else		Animation.WalkLength	= 0;

			Value					= [State objectForKey:@"HideOnEnd"];
			if (Value)	Animation.HideOnEnd		= [Value boolValue];
			else		Animation.HideOnEnd		= false;

			if ((Value = [State objectForKey:@"framerate"]))
					Animation.delay			= (float)1 / [Value floatValue];
			else	Animation.delay			= DEFAULT_FRAME_DELAY;

			if ((Value = [State localizedObjectForKey:@"audio"]))
				Animation.Sound		= [SoundDescriptor soundDescriptorFromDictionary: (NSDictionary*)Value];

			if ((Value = [State localizedObjectForKey:@"particle"]))
				Animation.Particle	= [ParticleSystemDescriptor particleSystemDescriptorFromDictionary: (NSDictionary*)Value];
		}

#if COCOS2D_DEBUG > 0
		Animation.name			= StateName;
#endif
		[self addAnimation: Animation name: StateName forObj: File];
		if ([DefaultState isEqualToString: StateName])
		{
			if (DefaultFrame != -1)
			{
				Frames		= [NSArray arrayWithObject: [[Animation frames] objectAtIndex: DefaultFrame]];
				Animation	= [ANCAnimation animationWithFrames: Frames];
				[self addAnimation: Animation name: File forObj: File];
				[FrameCache addSpriteFrame: [Frames lastObject] name: File];
			}			
			else	[self addAnimation: Animation name: File forObj: File];
			DefaultState	= nil;
		}
	}
	
	for (NSString *StateName in Aliases)
	{
		ANCAnimation	*Animation	= [self animationByName: [Aliases objectForKey: StateName] forObj: File];
		NSAssert(Animation, @"Unable to find Animation to alias");
		[self	addAnimation: Animation name: StateName forObj: File];
		if ([DefaultState isEqualToString: StateName])
		{
			if (DefaultFrame != -1)
			{
				NSArray *Frames	= [NSArray arrayWithObject: [[Animation frames] objectAtIndex: DefaultFrame]];
				Animation		= [ANCAnimation animationWithFrames: Frames];
				[self addAnimation: Animation name: File forObj: File];
				[FrameCache addSpriteFrame: [Frames lastObject] name: File];
			}
			else	[self addAnimation: Animation name: File forObj: File];
			DefaultState	= nil;
		}		
	}
	NSAssert1(!DefaultState, @"Default state not found in file %@", File);
	[[CCTextureCache sharedTextureCache] releaseAuxGLcontext];
}

-(void)lockOutClean
{
	while (true)
	{
		[Lock lock];
		if (cleanInProgress)
		{
			[Lock unlock];
			[NSThread sleepForTimeInterval: 0.100];
		}
		else break;
	}
	CCLOG(@"cleanLockOut: %d +1", cleanLockOut);
	cleanLockOut++;
	[Lock unlock];
}

-(void)unlockClean
{
	CCLOG(@"unlockClean: %d -1", cleanLockOut);
	[Lock lock];
	cleanLockOut--;
	NSAssert(cleanLockOut >= 0, @"Wrong cleanLockOut value");
	[Lock unlock];
}

-(void)lockAnimationsForObj: (NSString*)objName
{
	[Lock lock];
	NSMutableDictionary	*objDict	= [animations_ objectForKey: objName];
	if (objDict)	[objDict retain];//l'analisi qui dà un errore ma è tutto corretto
	[Lock unlock];
}

-(void)unlockAnimationsForObj: (NSString*)objName
{
	[Lock lock];
	NSMutableDictionary	*objDict	= [animations_ objectForKey: objName];
	if (objDict)	[objDict release];//l'analisi qui dà un errore ma è tutto corretto
	[Lock unlock];	
}

-(void)removeUnusedAnimations
{
	[self __removeUnusedAnimationsAsync: nil];
}

-(void)removeUnusedAnimationsAsync
{
	[NSThread detachNewThreadSelector:@selector(__removeUnusedAnimationsAsync:) toTarget: self withObject:nil];
}

-(void)__removeUnusedAnimationsAsync:(id)Unused
{
	NSAutoreleasePool *autoreleasepool;
	bool	Sync	= [NSThread isMainThread];
	if (!Sync)
	{
		autoreleasepool	= [[NSAutoreleasePool alloc] init];
		[[NSThread currentThread] setThreadPriority: 0.5];
	}

	NSMutableArray	*AnimationsToRemove	= [NSMutableArray arrayWithCapacity: 4];
	NSArray			*Keys;

	while (true)
	{
		[Lock lock];
		if (cleanInProgress || cleanLockOut)
		{
			[Lock unlock];
			[NSThread sleepForTimeInterval: 0.100];
		}
		else break;
	}
	cleanInProgress	= true;
	Keys			= [animations_ allKeys];

	if (Keys)
	{
		for (NSString *objName in Keys)
		{
			NSMutableDictionary	*objDict	= [animations_ objectForKey: objName];
			if ((objDict) && ([objDict retainCount] == 1))
			{
				if (Sync)	NSLog(@"Removing animations for object %@", objName);
				else		NSLog(@"Async removing animations for object %@", objName);
				[AnimationsToRemove addObject: objName];
			}
		}
		if ([AnimationsToRemove count] != 0)
			[animations_ removeObjectsForKeys: AnimationsToRemove];
	}
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	cleanInProgress	= false;
	CCLOG(@"Clean finished");
	[Lock unlock];
	if (!Sync)	[autoreleasepool drain];
}
@end
