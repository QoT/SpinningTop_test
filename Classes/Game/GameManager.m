//
//  GameManager.m
//  Prova
//
//  Created by mad4chip on 14/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "CocosAddOn.h"
#import "GameManager.h"
#import "functions.h"
#import "ANCAnimationCache.h"
#import "SoundManager.h"
#import "GameManager_CreateScene.h"
#import "ObjectiveCAddOn.h"
#import "SimpleCache.h"


static GameManager	*GameMgr	= nil;

@implementation GameManager
@synthesize GameData;
//@synthesize LowMemDevice;

+(GameManager*)Manager
{
	if (!GameMgr)
	{
		GameMgr	= [self initGameManager];
		[GameMgr retain];
	}
	return GameMgr;
}

+(id)initGameManager
{
	return [[[self alloc] initGameManager] autorelease];
}

-(id)initGameManager
{
	if ((self = [super init]))
	{
		InitVars();
		GameData			= [[GameDataObject gameData] retain];
		PreviousScene		= -1;
		CurrentSceneGroup	= nil;
		SceneGroups			= [[NSMutableArray		arrayWithCapacity: 1] retain];
		SceneObjects		= [[NSMutableDictionary dictionaryWithCapacity: 1] retain];
		SoundManager *sharedManager	= [SoundManager sharedManager];
		[sharedManager setBackgroundVolume:	GameData.MusicVolume];
		[sharedManager setVolume:			GameData.EffectVolume];
		[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(memoryWarning:)name:@"UIApplicationDidReceiveMemoryWarningNotification" object:nil];
/*		if ((([DeviceTypeName isEqualToString: @"iPod"])	&& (DeviceVersion <= 2))	||	//iPod					gen 1,2
			(([DeviceTypeName isEqualToString: @"iPhone"])	&& (DeviceVersion <= 2)))		//iPhone e iPhone 3G	gen 1,2
		{
			LowMemDevice	= true;
			NSLog(@"Low memory device");
		}
		else
		{
			LowMemDevice	= false;
			NSLog(@"High memory device");
		}
		LowMemDevice	= true;
*/
	}
	return self;
}

-(void)memoryWarning:(UIApplication *)application
{
	CCDirector		*director		= [CCDirector sharedDirector];
	NSMutableArray	*SceneStack		= [director GetSceneStack];
	ANCScene		*RunningScene	= (ANCScene*)[director runningScene];
	for (int i = 0; i < [SceneStack count]; i++ )
	{
		ANCScene *Scene = [SceneStack objectAtIndex:i];
		if (([Scene receivedMemoryWarning]) && (RunningScene != Scene))
		{	
			//se è true rimuovo
			[director removeSceneFromStackByTag:Scene.tag];
			i--;
		}
	}
	[[SimpleCache sharedManager] removeAllCaches];
	[[ANCAnimationCache sharedAnimationCache] removeUnusedAnimations];
}

-(void)addSceneGroup: (NSArray*)ScenesID
{
	[SceneGroups addObject: ScenesID];
}

-(void)preloadScene: (int)SceneID
{
	ANCScene	*Scene	= [self createScene: SceneID];
	Scene.tag			= SceneID;
	[[CCDirector sharedDirector] preloadScene: Scene];
}

#define	RUN_SCENE				10
#define	REPLACE_SCENE			11
#define	PUSH_SCENE				12

-(void)addObject:(id)Object forScene: (int)SceneID
{
	NSAssert(SceneID >= 0, @"SceneID must be >= 0");
	NSNumber	*Key	= [NSNumber numberWithInt: SceneID];
	if (!Object)
			[SceneObjects removeObjectForKey: Key];
	else	[SceneObjects setObject: Object forKey: Key];
}

-(id)getObjectForScene: (int)SceneID
{
	return [SceneObjects objectForKey: [NSNumber numberWithInt: SceneID]];
}

-(ANCScene*)ChangeScene: (NSUInteger)SceneID
{
	return [self ChangeScene: SceneID withObject: nil];
}

-(ANCScene*)ChangeScene: (NSUInteger)SceneID withObject: (id)Object
{
	CCDirector	*Director		= [CCDirector sharedDirector];
	ANCScene	*RunningScene	= (ANCScene*)[Director runningScene];
	ANCScene	*Scene			= nil;

	if (SceneID == PREVIOUS_SCENE)
		SceneID	= PreviousScene;
	NSAssert(SceneID >= 0, @"Scene ID must be > 0");

	if (Director.nextScene)//c'è già un cambio di scena in atto annullo la richiesta, causerebbe la deallocazione della scena
		return nil;

	if (Object)	[self addObject: Object forScene: SceneID];

	if (RunningScene)
	{
		if (RunningScene.tag == SceneID)//evita cambi di scena inutili, causerebbe la deallocazione della scena
			return RunningScene;
		if (RunningScene.tag >= 0)
			PreviousScene	= RunningScene.tag;
	}

	NSNumber	*SceneNumber	= [NSNumber numberWithUnsignedInt: SceneID];
	if ((CurrentSceneGroup) && ([CurrentSceneGroup indexOfObject: SceneNumber] != NSNotFound))
	{
		bool	push;
		if ((RunningScene.tag < 0) ||//se la scena a video non appartiene allo stesso gruppo, o ha tag invalido allora la rinpiazzo
			([CurrentSceneGroup indexOfObject: [NSNumber numberWithInt: RunningScene.tag]] == NSNotFound))
				push	= false;
		else	push	= true;
		Scene			= [Director runSceneFromStackByTag: SceneID pushCurrent: push];
		
		if (!Scene)
		{
			Scene		= [self createScene:SceneID];
			Scene.tag	= SceneID;
			if (push)	[Director pushScene: Scene];
			else		[Director replaceScene: Scene];
		}
		else NSLog(@"Scene recovered from the stack");
		
	}
	else
	{
		NSLog(@"Changing scenegroup clearing the stack");
		for (NSArray *Group in SceneGroups)
		{
			if ([Group indexOfObject: SceneNumber] != NSNotFound)
			{//trovato il gruppo di appartenenza della scena
				for (Scene in [Director scenesStack])
				{//scorre le scene cariche e cancella gli oggetti di quelle non presenti nel nuovo gruppo
					if (Scene.tag >= 0)
					{
						SceneNumber	= [NSNumber numberWithUnsignedInt: Scene.tag];
						if ([Group indexOfObject: SceneNumber] == NSNotFound)
							[self addObject: nil forScene: Scene.tag];
					}
				}

				for (SceneNumber in [SceneObjects allKeys])
				{//scorre gli oggetti carichi e cancella gli oggetti di quelle non presenti nel nuovo gruppo
					if ([Group indexOfObject: SceneNumber] == NSNotFound)
						[self addObject: nil forScene: [SceneNumber intValue]];
				}

				Scene				= [LoadingScene loadingSceneWithArray: Group pressToContinue: (RunningScene == nil) sceneToRun:SceneID];
				Scene.tag			= -1;//ID non valido, sarà rimpiazzato nello stack
				CurrentSceneGroup	= Group;
				break;
			}
		}
		[Director clearSceneStack];	//svuoto lo stack delle scene
		[[ANCAnimationCache sharedAnimationCache] removeAllAnimations];

		if (!Scene)
		{//scena fuori gruppo
			Scene				= [self createScene: SceneID];
            if (Scene == nil) {
                return nil;
            }
            
			Scene.tag			= SceneID;
			CurrentSceneGroup	= nil;
			for (SceneNumber in [SceneObjects allKeys])
			{//scorre gli oggetti carichi e cancella gli oggetti di quelle non presenti nel nuovo gruppo
				if ([SceneNumber intValue] != SceneID)
					[self addObject: nil forScene: [SceneNumber intValue]];
			}
		}

		if (!RunningScene)
				[Director runWithScene: Scene];
		else	[Director replaceScene: Scene];
	}
	return Scene;
}

-(void)dealloc
{
	[SceneGroups release];
	[SceneObjects release];
	[GameData release];
	[super dealloc];
}
@end

//------------------------------------------------------------------------------------------------------------------------
@implementation LoadingScene
@synthesize Progress;
-(void)setProgress: (float)newProgress
{
	Progress_	= newProgress;
//update bar
}

+(id)loadingSceneWithArray: (NSArray*)Scenes pressToContinue: (bool)Continue sceneToRun:(NSUInteger)sceneId
{
	return [[[self alloc] initWithSceneWithArray: Scenes pressToContinue: Continue sceneToRun:(int)sceneId] autorelease];
}

-(id)initWithSceneWithArray: (NSArray*)Scenes pressToContinue: (bool)Continue sceneToRun:(int)sceneId
{
	if ((self = [super initWithFile: LOADING_PLIST SceneManager:nil]))
	{
		SceneID			= sceneId;
		Preload			= [Scenes mutableCopy];//dà già un oggetto con retain
		ScenesCount		= [Preload count] + 1;//+1 per la pulizia della cache
		NSAssert(ScenesCount, @"Please provide a scenes array");
		self.Progress	= 0;
		Clean			= false;
		PressToContinue.isEnabled		= false;//setIsEnable rende visibile la normalimage se non c'è la disabledimage
		PressToContinue.visible			= false;
		if (!Continue)
			PressToContinue					= nil;
		[self scheduleUpdate];
	}
	return self;
}

-(bool)RoleHandler:(CCNode *)Node andData:(NSDictionary *)Dictionary
{
	NSString	*Role	= [Dictionary localizedObjectForKey: @"role"];
	if ([Role isEqualToString:@"forcone"]) 
		Fork = (ANCSprite*)Node;
	else if ([Role isEqualToString:@"press to continue"])
		PressToContinue	= (ANCMenuButton*)Node;
	else if ([Role isEqualToString:@"loading"])
		Loading	= (CCLabelBMFont*)Node;
	return	true;
}

-(void)update: (float)DeltaT
{
	if (!Clean)
	{
		[[ANCAnimationCache sharedAnimationCache] removeAllAnimations];
		Clean	= true;
	}
	else
	{
		GameManager *Manager	= [GameManager Manager];
		NSNumber *Index	= [Preload lastObject];
		[Manager preloadScene: [Index intValue]];
		[Preload removeLastObject];
		if ([Preload count] == 0)
		{
			[Fork runState:@"" times:1];
			if (PressToContinue)
			{
				Loading.visible				= false;
				PressToContinue.isEnabled	= true;
				PressToContinue.visible		= true;

				CCSequence *Change = [CCRepeatForever actionWithAction: [CCBlink actionWithDuration: 10 blinks: 10]];
				[PressToContinue.normalImage runAction: Change];
			}
			else	
			{
				CCFiniteTimeAction	*Animation;
				Animation					= [CCSequence actionOne: [Fork getStateAction: @"" times:1]
																two: [CCCallFuncO actionWithTarget: self selector: @selector(ChangeSceneObj:) object: [NSNumber numberWithInt:SceneID]]];
				[Fork runAction: Animation];
			}
			[self unscheduleUpdate];
		}		
	}
	self.Progress	+= 1.0f / ScenesCount;
}

-(void)BtnClick:(CCMenuItem *)Button
{
	[[GameManager Manager] ChangeScene: SceneID];
}

-(void) ChangeSceneObj: (NSNumber*)Scene
{
	[[GameManager Manager] ChangeScene: [Scene intValue]];
}

-(void)dealloc
{
	[Preload release];
	[super dealloc];
}
@end
