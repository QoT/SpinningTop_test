//
//  ANCParticleSystem.m
//  Farm Attack
//
//  Created by mad4chip on 24/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ANCParticleSystem.h"
#import "CocosAddOn.h"

@implementation ANCParticleSystem
@synthesize Name	= Name_;
-(void)setName: (NSString*)newName
{
	[Name_ release];
	Name_	= [newName retain];
}

@synthesize attachToNode	= attachToNode_;
-(void)setAttachToNode: (CCNode*)newNode
{
	[attachToNode_ release];
	attachToNode_	= [newNode retain];
}

@synthesize	Offset;

+(id) particleWithDictionary:(NSDictionary *)dictionary
{
	return [[[self alloc] initWithDictionary: dictionary] autorelease];
}

-(id) initWithTotalParticles:(NSUInteger) numberOfParticles
{
	if ((self = [super initWithTotalParticles: numberOfParticles]))
	{
		Name_			= nil;
		Offset			= CGPointZero;
	}
	return self;
}

-(void) update: (ccTime) dt
{
	if ((emissionRate)	&&
		(attachToNode_))
	{
		CGPoint	Position;
		if ([attachToNode_ respondsToSelector: @selector(imageCenter)])
				Position	= [attachToNode_ convertToWorldSpace: [(CCSprite*)attachToNode_ imageCenter]];
		else	Position	= [attachToNode_ convertToWorldSpace: CC_POINT_PIXELS_TO_POINTS(attachToNode_.anchorPointInPixels)];
		self.sourcePosition	= ccpAdd(Position, Offset);
		self.vertexZ		= attachToNode_.vertexZ;
	}
	[super update: dt];
}

-(void)pauseEmission
{
	active	= false;
	CCLOG(@"pauseEmission");
}
-(void)resumeEmission
{
	active	= true;
	CCLOG(@"resumeEmission");
}
-(void)pauseSystem
{
	active	= false;
	[self unscheduleUpdate];
	CCLOG(@"pauseSystem");
}
-(void)resumeSystem
{
	active	= true;
	[self scheduleUpdateWithPriority: 2];
	CCLOG(@"resumeSystem");
}

-(void)dealloc
{
	[attachToNode_	release];
	[Name_			release];
	[super			dealloc];
}
@end
