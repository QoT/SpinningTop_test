//
//  OptionMenu.m
//  Prova
//
//  Created by Visone on 10/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BreakTheEgg.h"
#import "GameManager.h"
#import "functions.h"
#import "ObjectiveCAddOn.h"
#import "SneakyButtonSkinnedBase.h"
#import "Screw.h"
#import "CocosAddOn.h"

@implementation BreakTheEgg

-(id)initMenu
{
	if ((self = [super initWithFile: BREAKTHEEGG_PLIST SceneManager: [GameManager Manager]]))
	{
		TotalHitNum	= [[ConfigurationContent objectForKey: @"totalhitnum"] intValue];
		TotalHitNum++;//il primo tocco non lo considero
		FrameCount	= [[[Egg getState: @""] frames] count] - 1;
		EggPieces	= [ParticleSystemDescriptor particleSystemDescriptorFromDictionary: [ConfigurationContent objectForKey: @"eggpiecesparticle"]];
		[EggPieces retain];
	}
	return self;
}

-(bool)RoleHandler: (CCNode*)Node andData: (NSDictionary*)Dictionary
{
	NSString	*Role	= [Dictionary localizedObjectForKey: @"role"];
	if		([Role isEqualToString: @"egg"])			Egg			= (ANCSprite*)Node;
	else if	([Role isEqualToString: @"fracture"])		Fracture	= (ANCSprite*)Node;
	else if	([Role isEqualToString: @"eyes"])			Eyes		= (ANCSprite*)Node;
	else if	([Role isEqualToString: @"chick"])			Chick		= (ANCSprite*)Node;
	else if	([Role isEqualToString: @"chick layer"])	ChickLayer	= (CCLayer*)Node;
	else if	([Role isEqualToString: @"nest"])			Nest		= (ANCSprite*)Node;
	return [super RoleHandler: Node andData: Dictionary];
}

-(void)resetGame
{
	[self unschedule: @selector(finishGame)];
	ChickLayer.position	= CGPointZero;
	Nest.position		= CGPointZero;
	[ChickLayer stopAllActions];
	[Chick		stopAllActions];
	[Nest		stopAllActions];
	[Eyes		stopAllActions];
	Eyes.position	= CGPointZero;
	Chick.position	= CGPointZero;
	[super resetGame];
}

-(void)initGame
{
	[EggPieces	killSystem];
	[Eyes		runState: @"0@eyes"			times: 0];
	[Egg		runState: @"%0@egg"			times: 0];
	[Fracture	runState: @"%0@fracture"	times: 0];
	HitNum		= 0;
	[super initGame];
}


-(void)topUpdateEvent: (MimiEvents)Event position: (CGPoint)position
{
	if ((Event == MIMITOP_TOUCH_BEGIN) &&
		(CGRectContainsPoint([Egg TrimmedRect], Mimi.TopPosition)))
	{//in ogni caso la trottola non può perdere contatto con lo schermo per più di maxExitTime
		CCAction	*Jump;
		HitNum++;
		if (HitNum > 1)
		{
			if (HitNum >= TotalHitNum)
			{
				[Egg		runState: [NSString stringWithFormat: @"%u@egg",		FrameCount] times: 0];
				[Fracture	runState: [NSString stringWithFormat: @"%u@fracture",	FrameCount] times: 0];

				Jump	= [CCSequence actions:  [CCJumpBy actionWithDuration: 0.2 position: ccp(10, 0)  height: 40 jumps: 1],
												[CCJumpBy actionWithDuration: 0.2 position: ccp(-10, 0) height: 40 jumps: 1],
												nil];
				Jump	= [CCRepeatForever actionWithAction: (CCActionInterval*)Jump];
				[Eyes		runState: @"eyes" times: 0];
				[Eyes		runAction: [Jump copy]];
				[Chick		runAction: Jump];
				[EggPieces getParticleSystemForNode: Egg];
				Mimi.Enable	= false;//disabilito la trottola dirante il ritardo
				[self schedule: @selector(finishGame) interval: 3];
			}
			else
			{
				Jump	= [CCJumpBy actionWithDuration: 0.2 position: ccp(3, 2) height: 5 jumps: 3];
				Jump	= [CCSequence actions: [CCMoveTo actionWithDuration: 0 position: CGPointZero], Jump, [(CCActionInterval*)Jump reverse], nil];
				[ChickLayer	runAction: [Jump copy]];
				[Nest		runAction: Jump];

				int	FrameNum	= ((float)HitNum / TotalHitNum) * FrameCount;
				[Egg		runState: [NSString stringWithFormat: @"%u@egg",		FrameNum] times: 0];
				[Fracture	runState: [NSString stringWithFormat: @"%u@fracture",	FrameNum] times: 0];
			}
		}
	}
	[super topUpdateEvent:Event position:position];
}

-(TGameResult)getGameResult
{
	//implementare!!!!!!
	return (TGameResult){3, 1000};
}

-(void)dealloc
{
	[EggPieces release];
	[super dealloc];
}
@end
