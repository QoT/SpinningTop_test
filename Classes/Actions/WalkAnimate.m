//
//  WalkAnimate.m
//  Prova
//
//  Created by mad4chip on 18/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WalkAnimate.h"
#import "functions.h"

@implementation WalkAnimate
@synthesize animation;

-(NSArray *)frames	{ return animation.frames;	}

+(id) actionWithAnimation: (ANCAnimation*) Animation
{
	return [[[self alloc] initWithAnimation: Animation] autorelease];
}

-(id) initWithAnimation: (ANCAnimation*) Animation
{
	if( (self=[super init]) )
	{
		NSAssert(Animation, @"Animation must be not nil");
		animation		= [Animation retain];
	}
	return self;
}

-(void) dealloc
{
	[animation release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{//target_ è impostato da super
	[super startWithTarget:aTarget];
	Remainder		= 0;
	LastPosition	= [(CCNode*)target_ convertToWorldSpace: CGPointZero];
	LastFrame		= 0;

	NSArray*	Frames		= [animation frames];
	[target_ setDisplayFrame: [Frames objectAtIndex: 0]];
//NSLog(@"Frame: %u", 0);
}

-(void) step:(ccTime) DeltaT
{
	NSArray*	Frames		= [animation frames];
	int			FrameNum	= [Frames count];
	int			FrameIncrement;
	float		WalkLength;

	WalkLength	= animation.WalkLength;
	NSAssert(WalkLength != 0, @"Error WalkLength must be != 0");
/*	if (WalkLength == 0)
	{//animazione non sincronizzata, WalkLength, Remainder sono tempi
		WalkLength	= animation.delay;	
		Remainder	+= DeltaT;
	}
	else
*/	{//animazione sincronizzata, WalkLength, Remainder sono distanze
		CGPoint	CurrentPosition;
		CurrentPosition	= [(CCNode*)target_ convertToWorldSpace: CGPointZero];
		if (CurrentPosition.x - LastPosition.x >= 0)
				Remainder	-= CGPointDistance(LastPosition, CurrentPosition);
		else	Remainder	+= CGPointDistance(LastPosition, CurrentPosition);
		LastPosition	= CurrentPosition;
//		CCLOG(@"Distance %.2f", Remainder);
	}

	FrameIncrement	= floor(Remainder / WalkLength);
	if (FrameIncrement != 0)
	{
		Remainder		-= WalkLength * FrameIncrement;
		FrameIncrement	+= LastFrame;
		while (FrameIncrement < 0)			FrameIncrement	+= FrameNum;
		while (FrameIncrement >= FrameNum)	FrameIncrement	-= FrameNum;
		if (FrameIncrement != LastFrame)
		{
			LastFrame	= FrameIncrement;
			CCSpriteFrame	*Frame	= [Frames objectAtIndex: LastFrame];
			if (![target_ isFrameDisplayed: Frame])
				[target_ setDisplayFrame: Frame];
//NSLog(@"Frame: %u %X", LastFrame, target_);
		}
	}		
}

-(BOOL) isDone	{	return false;	}

-(void) update:(ccTime)time
{}

-(NSString*)description
{
	return [NSString stringWithFormat:@"<%@ = %08X\n\tTarget = %@\n\tAnimation = %@>",
			[self class],
			(unsigned int)self,
			[target_ description],
			[animation description]];
}
@end
