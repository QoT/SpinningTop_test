//
//  MoveByJoystic.m
//  Prova
//
//  Created by mad4chip on 29/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoveByJoystic.h"
#import "functions.h"
//#import "CocosAddOn.h"

#pragma mark -
#pragma mark MoveByJoystic
@implementation MoveByJoystic

+(id) actionWithJoystick: (SneakyJoystick*) Joy maxSpeed: (float*)Speed andRect: (CGRect) RectArea
{
	return [[[self alloc] initWithJoystick: Joy maxSpeed: Speed andRect: (CGRect) RectArea] autorelease];
}

-(id) initWithJoystick: (SneakyJoystick*) Joy maxSpeed: (float*)Speed andRect: (CGRect) RectArea
{
	if( (self=[super init]) )
	{
		Joystick		= [Joy retain];
		MaxSpeed		= Speed;
		RectArea.origin	= RectArea.origin;
		Area			= RectArea;
	}
	return self;
}

-(void) dealloc
{
	[Joystick release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
}

-(void) step: (ccTime) t
{
	CGPoint	Movement	= Joystick.velocity;
	if ((Movement.x == 0) && (Movement.y == 0))
		return;
#ifdef USE_LINEAR_JOYSTICK
	Movement	= ccpMult(Movement, *MaxSpeed * t);
#else
	Movement	= ccp(sqrt(fabs(Movement.x)) * fsign(Movement.x), sqrt(fabs(Movement.y)) * fsign(Movement.y));
	Movement	= ccpMult(Movement, *MaxSpeed * t);
#endif
	CGPoint	TargetPosition	= ccpAdd(((CCNode*)target_).position, Movement);
	float	temp;

	if ((TargetPosition.x < (temp = CGRectGetMinX(Area))) ||
		(TargetPosition.x > (temp = CGRectGetMaxX(Area))))
			TargetPosition	= ccp(temp, TargetPosition.y);

	if ((TargetPosition.y < (temp	= CGRectGetMinY(Area))) ||
		(TargetPosition.y > (temp	= CGRectGetMaxY(Area))))
			TargetPosition	= ccp(TargetPosition.x, temp);

	[target_ setPosition: TargetPosition];
//	CCLOG(@"MoveByJoystic position: %.2f,%.2f", TargetPosition.x, TargetPosition.y);
}

-(BOOL) isDone
{
	return NO;
}

@end
