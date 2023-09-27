//
//  OptionMenu.m
//  Prova
//
//  Created by Visone on 10/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CleanTheFloor.h"
#import "GameManager.h"
#import "functions.h"
#import "ObjectiveCAddOn.h"
#import "SneakyButtonSkinnedBase.h"
#import "Screw.h"

@implementation CleanTheFloor

-(id)init
{
	if ((self = [super init]))
	{
		Objects		= [NSMutableArray arrayWithCapacity: 0];
		[Objects	retain];
		AllObjects	= [NSMutableArray arrayWithCapacity: 0];
		[AllObjects	retain];
	}
	return self;
}

-(id)initMenu
{
	if ((self = [super initWithFile: CLEANTHEFLOOR_PLIST SceneManager: [GameManager Manager]]))
	{
		ObjectSpeed	= [[ConfigurationContent objectForKey: @"objectspeed"] floatValue];
		Threshold	= [[ConfigurationContent objectForKey: @"threshold"] floatValue];
		Mimi.AttachedNode	= Sponge;
	}
	return self;
}

-(bool)RoleHandler: (CCNode*)Node andData: (NSDictionary*)Dictionary
{
	NSString	*Role	= [Dictionary localizedObjectForKey: @"role"];
	if		([Role isEqualToString: @"sponge"])			Sponge		= (ANCSprite*)Node;
	else if	([Role isEqualToString: @"object"])			[AllObjects	addObject: Node];
	return [super RoleHandler: Node andData: Dictionary];
}

-(void)resetGame
{
	[self unscheduleUpdate];
	[Sponge stopAllActions];
	[super resetGame];
}

-(void)initGame
{
	[super initGame];
	[Mimi.PaperSheet clearSprite];
	[Objects removeAllObjects];
	[Objects addObjectsFromArray: AllObjects];
	for (CCNode *Node in Objects)
	{
		Node.position	= RandomPointInRect(Mimi.MoveRect);
		Node.rotation	= drandInRange(0, 360);
		Node.visible	= true;
	}
	LastCheck	= 0;
}

-(void)startGame
{
	[Sponge runAction: [CCRepeatForever actionWithAction: [CCRotateBy actionWithDuration: 1 angle: 180]]];
	[self scheduleUpdate];
	[super startGame];
}

-(void)update: (float)dT
{
	//NSLog(@"%.2f", [Mimi.PaperSheet getCoverageFactorMask: ccc4(0, 0, 0, 255) RefColor: ccc4(0, 0, 0, 0) Step: 1]);
	// 0 completamente pulito
	// 1 sporco
	for (int i = 0; i < [Objects count];)
	{
		CCNode		*Object	= [Objects objectAtIndex: i];
		if ((Object.visible) && (CGRectContainsPoint([Mimi.AttachedNode boundingBox], Object.position)))
		{
			CGPoint		Point	= RandomPointOutsideScreen([Object contentSize]);
			float		Distance= CGPointDistance(Object.position, Point);
			float		Time	= Distance/ObjectSpeed;
			CCFiniteTimeAction	*Action	= [CCJumpTo actionWithDuration: Time position: Point height: sqrtf(Distance) jumps: 1];
			[Object runAction: Action];
			Action				= [CCRotateBy actionWithDuration: Time angle: Time * 180];
			[Object runAction: Action];
			[Objects removeObject: Object];
		}
		else i++;
	}
	if (ElapsedTime > LastCheck + 1)
	{//verifica se hai pulito tutto 1 volta al secondo
		LastCheck	= ElapsedTime;
		[NSThread detachNewThreadSelector: @selector(checkClean) toTarget: self withObject: nil];
	}
}

-(void)checkClean
{
	if (![[CCTextureCache sharedTextureCache] getAuxGLcontext])
		CCLOG(@"Error getting context");

	if ([Mimi.PaperSheet getCoverageFactorMask: ccc4(0, 0, 0, 255) RefColor: ccc4(0, 0, 0, 0) Step: 4] == Threshold)
		[self performSelectorOnMainThread: @selector(finishGame) withObject: nil waitUntilDone: false];

	[[CCTextureCache sharedTextureCache] releaseAuxGLcontext];
}

-(TGameResult)getGameResult
{
	TGameResult	Result;
	float perc = [Mimi.PaperSheet getCoverageFactorMask: ccc4(0, 0, 0, 255) RefColor: ccc4(0, 0, 0, 0) Step: 1];
	if (perc <= 0.2)		Result.star = 3;	//pulito 3 stelle
	else if (perc <= 0.4)	Result.star = 2;	//mediamente pulito 2 stelle
	else if (perc <= 0.6)	Result.star = 1;	//poco pulito 1 stella
	else if (perc <= 0.8)	Result.star = 0;	//Sporco 0 stella
	else					Result.star	= -1;	//perso
	Result.points	= (1 - perc) * 1000;
	return	Result;
}

-(void)dealloc
{
	[AllObjects release];
	[Objects	release];
	[super dealloc];
}
@end
