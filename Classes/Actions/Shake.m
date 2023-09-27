//
//  MoveByJoystic.m
//  Prova
//
//  Created by mad4chip on 29/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Shake.h"

@implementation Shake

+(id) actionWithDuration: (ccTime) Time andWidth: (float)W repetitions: (int)rep
{
	return [[[self alloc] initWithDuration: Time andWidth: W repetitions: (int)rep] autorelease];
}

-(id) initWithDuration: (ccTime) Time andWidth: (float)W repetitions: (int)rep
{
	if ((self = [super initWithDuration: Time]))
	{
		NSAssert(W != 0,		@"Width must be != 0");

		K1		= (rand() % 3 + 1) * 2 - 1;	//1, 3, 5
		do	K2	= (rand() % 3 + 1) * 2 - 1;	//1, 3, 5
		while (K1 == K2);
		
		do	K3	= (rand() % 3 + 1) * 2 - 1;	//1, 3, 5
		while (K3 == K1);
		do	K4	= (rand() % 3 + 1) * 2 - 1;	//1, 3, 5
		while (K4 == K2);
		Width		= W / (0.8 * (K1 + K2 + K3 + K4));
		Repetitions	= rep;
	}
	return self;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	positionOffset	= ccpSub(((CCNode*)aTarget).position, [self getShift: 0]);
	[super startWithTarget: aTarget];
}

-(CGPoint)getShift: (ccTime) t
{
	CGPoint	Shift;
	t		= 2 * t * Repetitions * M_PI;
//	t		= fmod(t, 1) * M_PI;
	Shift	= ccp(Width*sin(K1*t)*cos(K2*t), Width*sin(K3*t)*cos(K4*t));
	Shift	= ccpMult(Shift, Width);
	return Shift;
}

-(void)stop
{
	[self update: 0];//rimette il target al suo posto se l'azione è interrotta prima
	[super stop];
}

-(void) update: (ccTime) t
{
	CCNode	*Node	= target_;
	Node.position	= ccpAdd([self getShift: t], positionOffset);
}
@end
