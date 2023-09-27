//
//  RunAction.m
//  Prova
//
//  Created by mad4chip on 20/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RunAction.h"


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation RunAction
@synthesize RealTarget;
@synthesize ActionToRun;
-(void)setRealTarget: (id)Target
{
	[RealTarget release];
	RealTarget	= [Target retain];
}

+(id) actionWithActionToRun: (CCAction*)action
{
	return [[[self alloc] initWithActionToRun: action andTarget: nil forceInstant: false] autorelease];
}

+(id) actionWithActionToRun: (CCAction*)action andTarget: (id)Target
{
	return [[[self alloc] initWithActionToRun: action andTarget: Target forceInstant: false] autorelease];
}

+(id) actionWithActionToRun: (CCAction*)action forceInstant: (bool) forceInstant;
{
	return [[[self alloc] initWithActionToRun: action andTarget: nil forceInstant: forceInstant] autorelease];
}

+(id) actionWithActionToRun: (CCAction*)action andTarget: (id)Target forceInstant: (bool) forceInstant
{
	return [[[self alloc] initWithActionToRun: action andTarget: Target forceInstant: forceInstant] autorelease];
}

-(id) initWithActionToRun: (CCAction*)action andTarget: (CCNode*)Target forceInstant: (bool) forceInstant
{
	if ((!forceInstant) && ([action isKindOfClass: [CCActionInterval class]]))
			duration_		= ((CCActionInterval*)action).duration;
	else	duration_		= 0;
	
	if ((self = [super initWithDuration: duration_]))
	{
		ActionToRun			= [action retain];
		RealTarget			= [Target retain];
	}
	return self;
}

-(void) startWithTarget:(id)aTarget
{
//	CCLOG([self description]);
	[super startWithTarget:aTarget];
	if (RealTarget)
	{
		[RealTarget stopAction: ActionToRun];
		[((CCNode *)RealTarget) runAction: ActionToRun];//previene l'errore action already running
	}
	else
	{
		[aTarget stopAction:	ActionToRun];
		[((CCNode *)aTarget)	runAction: ActionToRun];	//previene l'errore action already running
	}
/*	[ActionToRun release];
	ActionToRun	= nil;
	[RealTarget release];
	RealTarget	= nil;
*/
}
//se duration != 0 non può ritornare sempre true altrimenti i repeat impazziscono
/*
-(BOOL) isDone
{
	return true;
}*/

-(void) update: (ccTime) time	{}

/*
//vuoto in modo da non esguire conti inutili, leggo tutti i parametri dall'azione eseguita
-(void) step: (ccTime) dt		{}
-(BOOL) isDone
{
	return [ActionToRun isDone];
}
* /
-(ccTime)elapsed
{
	if ([ActionToRun isKindOfClass: [CCActionInterval class]])
		return ((CCActionInterval*)ActionToRun).elapsed;
	else	return 0;
}
*/
-(void) dealloc
{
	[RealTarget release];
	[ActionToRun release];
	[super dealloc];
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Tag = %i | action = %@ | target = %@>", [self class], (unsigned int)self, tag_, [ActionToRun description], (RealTarget)?([RealTarget description]):([target_ description])];
}
@end
