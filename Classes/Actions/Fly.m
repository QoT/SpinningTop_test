//
//  MoveByJoystic.m
//  Prova
//
//  Created by mad4chip on 29/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Fly.h"
#import "functions.h"
#import "CocosAddOn.h"

@implementation Fly
-(float*)WalkLength	{	return &WalkLength[0];	};
-(int*)K			{	return &K[0][0];		};
-(float)Distance	{	return Distance;		};

+(id) actionWithWidth: (float)W andWalkLength: (float)WalkL
{
	return [[[self alloc] initWithWidth: W andWalkLength: WalkL] autorelease];
}

-(id) initWithWidth: (float)W andWalkLength: (float)WalkL
{
	if ((self = [super init]))
	{
		NSAssert(W != 0,		@"Width must be != 0");
		NSAssert(WalkL != 0,	@"WalkLength must be != 0");
		Width			= W;
		WalkLength[0]	= WalkL;
		WalkLength[1]	= WalkL;
	}
	return self;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	Distance		= ((float)rand())/RAND_MAX;
	LastPosition	= ((CCNode*)aTarget).position;
	OffSet			= ccpAdd([self getShift: 0], [self getShift: 1]);

	bool	Init	= false;
	if (stopSimilarAction)
	{
		NSArray	*Actions;
		if ((Actions = [aTarget getAllActionsByTag: tag_]))
		{
			for (Fly* Action in Actions)
				if (((void*)Action != (void*)self) &&
					([Action isKindOfClass: [Fly class]]))
				{
					memcpy(WalkLength, [Action WalkLength], sizeof(WalkLength));
					memcpy(K, [Action K], sizeof(K));
					Distance	= [Action Distance];
					Init	= true;
					break;
				}
		}
	}

	if (!Init)
		for (int i = 0; i < 2; i++)
		{
			switch (rand()%8)
			{
				case 0:		K[i][0]	= 1;	K[i][1]	= 1;	K[i][2]	= 1;	K[i][3]	= 2;	break;
				case 1:		K[i][0]	= 1;	K[i][1]	= 1;	K[i][2]	= 2;	K[i][3]	= 1;	break;	
				case 2:		K[i][0]	= 1;	K[i][1]	= 2;	K[i][2]	= 1;	K[i][3]	= 1;	break;
				case 3:		K[i][0]	= 2;	K[i][1]	= 1;	K[i][2]	= 1;	K[i][3]	= 1;	break;
					
				case 4:		K[i][0]	= 2;	K[i][1]	= 1;	K[i][2]	= 1;	K[i][3]	= 2;	break;	
				case 5:		K[i][0]	= 1;	K[i][1]	= 2;	K[i][2]	= 2;	K[i][3]	= 1;	break;
					
				case 6:		K[i][0]	= 2;	K[i][1]	= 1;	K[i][2]	= 1;	K[i][3]	= 2;	break;	
				case 7:		K[i][0]	= 1;	K[i][1]	= 2;	K[i][2]	= 2;	K[i][3]	= 1;	break;
			}
			WalkLength[i]	= WalkLength[i] / (0.8 * (K[i][0] + K[i][1] + K[i][2] + K[i][3]));
			CCLOG(@"Fly: (%u, %u, %u, %u) Wdth: %.2f, WalkLength: %2f", K[i][0], K[i][1], K[i][2], K[i][3], Width, WalkLength[i]);
		}
	
	[super startWithTarget: aTarget];
	if (!Init)	[self update: 0];//evita uno scatto se si è uccisa un azione simile
}

-(CGPoint) getShift: (int) i
{
	float	t		= Distance / ((1 + 10*i) * WalkLength[i]);
	t				= 2 * M_PI * t;//fmod(t , 1);
	float	W		= Width * (0.3 + 0.7*i);
	CGPoint	Shift	= ccp(W*sin(K[i][0]*t)*cos(K[i][1]*t), W*sin(K[i][2]*t)*cos(K[i][3]*t));
	Shift			= ccpAdd(Shift, ccp(Width*sin(4*t)*sin(t)/10, Width*sin(t)*cos(t)/10));
//	CCLOG(@"Shift %.2f %.2f (%.2f,%.2f)", Distance, t, Shift.x, Shift.y);
	return	Shift;
}

-(void) step: (ccTime) t
{
	CCNode	*Node	= target_;
	CGPoint	Position= Node.position;
	Distance		+= CGPointDistance(LastPosition, Position);
	LastPosition	= Position;

	Position		= ccpSub(Position, OffSet);
//	Position		= ccpAdd(Position, [self getShift: 0]);
	Position		= ccpAdd(Position, [self getShift: 1]);
	Node.position	= Position;
}

-(BOOL)isDone
{
	return false;
}
@end
