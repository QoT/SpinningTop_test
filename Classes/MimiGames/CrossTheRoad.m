//
//  OptionMenu.m
//  Prova
//
//  Created by Visone on 10/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossTheRoad.h"
#import "GameManager.h"
#import "functions.h"
#import "ObjectiveCAddOn.h"
#import "CocosAddOn.h"

@implementation CrossTheRoad

-(id)initMenu
{
	if ((self = [super initWithFile: CROSSTHEROAD_PLIST SceneManager: [GameManager Manager]]))
	{
		Mimi.MovePath.anchorPoint	= CGPointZero;
		Mimi.MoveRect				= [Mimi.MovePath boundingBox];
		Mimi.StartRect				= [Start TrimmedRect];
	}
	return self;
}

-(bool)RoleHandler: (CCNode*)Node andData: (NSDictionary*)Dictionary
{
	NSString	*Role	= [Dictionary localizedObjectForKey: @"role"];
	if		([Role isEqualToString: @"start"])	Start	= (ANCSprite*)Node;
	else if ([Role isEqualToString: @"finish"])	Finish	= (ANCSprite*)Node;
	return [super RoleHandler: Node andData: Dictionary];
}

-(void)topUpdateEvent: (MimiEvents)Event position: (CGPoint)position
{
	if (Event == MIMITOP_EXIT_MOVE_RECT)
		[self forceLose];
	else if ((Event == MIMITOP_TOUCH_MOVED) &&
		(CGRectContainsPoint([Finish TrimmedRect], Mimi.TopPosition)))
	{
		[self finishGame];
		return;
	}
	[super topUpdateEvent: Event position: position];
}

-(TGameResult)getGameResult
{
	//implementare!!!!!!
	return (TGameResult){3, 1000};
}

@end
