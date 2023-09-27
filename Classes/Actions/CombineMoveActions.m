//
//  CombineAction.m
//  Prova
//
//  Created by mad4chip on 19/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CombineMoveActions.h"


@implementation CombineMoveAction
+(id) actionWithXAction: (CCActionInterval*) XAction_ andYAction: (CCActionInterval*) YAction_
{
	return [[[self alloc] initWithXAction: XAction_ andYAction: YAction_] autorelease];
}

-(id) initWithXAction: (CCActionInterval*) XAction_ andYAction: (CCActionInterval*) YAction_
{
	NSAssert(XAction.duration == YAction.duration, @"CombineMoveAction needs two actions with the same duration");
	if ((self = [super initWithDuration: XAction_.duration]))
	{
		XAction	= [XAction_ retain];
		YAction	= [YAction_ retain];
	}
	return self;
}

-(void)dealloc
{
	[XAction release];
	[YAction release];
	[super dealloc];
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[XAction startWithTarget: aTarget];
	[YAction startWithTarget: aTarget];
	[super startWithTarget: aTarget];
}

-(void) update: (ccTime) t
{
	float	temp;
	[XAction update: t];
	temp						= ((CCNode*)target_).position.x;
	[YAction update: t];
	((CCNode*)target_).position	= ccp(temp, ((CCNode*)target_).position.y);
}
@end
