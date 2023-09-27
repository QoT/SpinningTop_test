//
//  ANCParticleSystem.m
//  Farm Attack
//
//  Created by mad4chip on 24/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ANCParticleSystemDescriptor.h"
#import "ANCParticleSystemManager.h"
#import "RunAction.h"
#import "ObjectiveCAddOn.h"
#import "CocosAddOn.h"
#import "ANCSprite.h"

@implementation ParticleSystemDescriptor
@synthesize	stopwithanimation;
@synthesize	delay;
@synthesize	duration;
@synthesize	repetitions;
@synthesize	FileName;
@synthesize	ParticleSystem;
@synthesize	Offset;
@synthesize	Scale;
@synthesize	Behaviour;

+(id)particleSystemDescriptorFromDictionary: (NSDictionary*)DescriptionData
{
	bool				stopWithAnimation_	= false;
	float				delay_				= 0;
	float				duration_			= KEEP_DURATION;
	int					repetitions_		= 1;
	CGPoint				offset_				= CGPointZero;
	CGPoint				scale_				= ccp(1,1);
	TParticleBehaviour	behaviour_			= PARTICLE_POSITION_DEFAULT;
	NSString			*FileName_;
	NSString			*Value;
	
	if ([DescriptionData isKindOfClass: [NSString class]])
		FileName_	= (NSString*)DescriptionData;
	else
	{
		FileName_	= [DescriptionData localizedObjectForKey: @"file"];
		if ((Value = [DescriptionData objectForKey:@"repeat"]))		repetitions_	= [Value intValue];
		if ((Value = [DescriptionData objectForKey:@"duration"]))	duration_		= [Value floatValue];
		if ((Value = [DescriptionData objectForKey:@"position"]))	offset_			= CGPointFromString(Value);
		if ((Value = [DescriptionData objectForKey:@"scale"]))
		{
			delay_			= [Value floatValue];
			if (delay_ == 0)
					scale_	= CGPointFromString(Value);
			else	scale_	= ccp(delay_, delay_);
		}
		if ((Value = [DescriptionData objectForKey:@"delay"]))		delay_			= [Value floatValue];
		if ((Value = [DescriptionData objectForKey:@"behaviour"]))
		{
			if ([Value isEqualToString: @"absolute"])			behaviour_	= 	PARTICLE_POSITION_ABSOLUTE;
			else if ([Value isEqualToString: @"relative"])		behaviour_	= 	PARTICLE_POSITION_RELATIVE;
			else if ([Value isEqualToString: @"system_follow"])	behaviour_	= 	PARTICLE_POSITION_SYSTEM_FOLLOW_ENTITY;
			else if ([Value isEqualToString: @"source_follow"])	behaviour_	= 	PARTICLE_POSITION_SOURCE_FOLLOW_ENTITY;
			else	NSAssert(false, @"Unknown behaviour");
		}
		if ((Value = [DescriptionData objectForKey:@"stopwithanimation"]))
			stopWithAnimation_	= [Value boolValue];
	}
	NSAssert(FileName_, @"Please specify filename");
	return [[[self alloc] initParticleSystemDescriptorWithName: FileName_ delay: delay_ duration: duration_ repetitions: repetitions_ offset: offset_ scale: scale_ behaviour: behaviour_ stopWithAnimation: stopWithAnimation_] autorelease];
}

+(id)particleSystemDescriptorWithName: (NSString*)Name_
{
	return [[[self alloc] initParticleSystemDescriptorWithName: Name_ delay: 0 duration: KEEP_DURATION repetitions: 1 offset: CGPointZero scale: ccp(1,1) behaviour: PARTICLE_POSITION_DEFAULT stopWithAnimation: false] autorelease];
}

+(id)particleSystemDescriptorWithName: (NSString*)Name_ delay: (float) delay_ duration: (float) duration_ repetitions: (int) repetitions_ offset: (CGPoint)offset_ scale: (CGPoint)scale_ behaviour: (TParticleBehaviour)behaviour_ stopWithAnimation: (bool)stopWithAnimation_
{
	return [[[self alloc] initParticleSystemDescriptorWithName: Name_ delay: delay_ duration: duration_ repetitions: repetitions_ offset: offset_ scale: scale_  behaviour: behaviour_ stopWithAnimation: stopWithAnimation_] autorelease];
}

-(id)initParticleSystemDescriptorWithName: (NSString*)Name_ delay: (float) delay_ duration: (float) duration_ repetitions: (int) repetitions_ offset: (CGPoint)offset_ scale: (CGPoint)scale_ behaviour: (TParticleBehaviour)behaviour_ stopWithAnimation: (bool)stopWithAnimation_
{
	if ((self = [super init]))
	{
		stopWithAnimation	= stopWithAnimation_;
		delay				= delay_;
		duration			= duration_;
		repetitions			= repetitions_;
		Offset				= offset_;
		Scale				= scale_;
		Behaviour			= behaviour_;
		FileName			= [Name_ retain];
		ParticleSystem		= nil;
		NSDictionary	*Config	= [[ANCParticleSystemManager sharedParticleSystemManager] preloadParticleSystemWithFile: FileName];
		if (duration == KEEP_DURATION)
			duration	= [[Config objectForKey: @"duration"] floatValue];
	}
	return self;
}

-(void)getParticleSystemForNode: (CCNode*) Node
{
	if (ParticleSystem)	[ParticleSystem release];
	ParticleSystem						= [[ANCParticleSystemManager sharedParticleSystemManager] newParticleSystemWithFile: FileName];
	[ParticleSystem retain];
	if (Behaviour == PARTICLE_POSITION_SOURCE_FOLLOW_ENTITY)
	{
		ParticleSystem.attachToNode		= Node;
		ParticleSystem.sourceFollowNode	= true;//il punto di emissione del particle system segue il nodo
	}
	else if	(Behaviour == PARTICLE_POSITION_SYSTEM_FOLLOW_ENTITY)
	{
		ParticleSystem.attachToNode		= Node;//tutto il particle system segue il nodo
		ParticleSystem.sourceFollowNode	= false;
	}
	else	ParticleSystem.attachToNode	= nil;
	ParticleSystem.position				= CGPointZero;
	ParticleSystem.anchorPoint			= CGPointZero;
	ParticleSystem.Offset				= Offset;
	ParticleSystem.vertexZ				= Node.vertexZ;
	ParticleSystem.scaleX				= Scale.x;
	ParticleSystem.scaleY				= Scale.y;

	[ParticleSystem updatePosition];
	[ParticleSystem resetSystem];
	[ParticleSystem resumeSystem];//scheduleupdate

	CCActionInterval	*Action		= [CCCallFuncO	actionWithTarget: self selector: @selector(resumeForDuration:) object: Node];
	if (delay > 0)
	{
		Action		= [CCSequence actionOne: [CCDelayTime	actionWithDuration: delay]
									two: Action];
		if (repetitions < 0)		Action	= (CCActionInterval*)[CCRepeatForever actionWithAction: Action];
		else if (repetitions > 1)	Action	= [CCRepeat actionWithAction: Action times: repetitions];
	}
	Action.tag	= (NSInteger)ParticleSystem;
	[[ANCParticleSystemManager sharedParticleSystemManager] runAction: Action];
	if ((duration == -1) || (stopwithanimation))
	{
		Action		= [KillParticle actionWithParticleSystem: ParticleSystem];
		Action.tag	= ANIMATION_TAG;
		[Node runAction: Action];
	}
}

-(void)resumeForDuration: (CCNode*)Node
{
	ParticleSystem.visible				= true;
	if (!ParticleSystem.active)
		[ParticleSystem resetSystem];

	ParticleSystem.duration		= duration;
	if (Behaviour != PARTICLE_POSITION_ABSOLUTE)
	{
//		CGPoint	Position				= [Node.parent convertToWorldSpace: Node.position];
//		Position						= ccpSub(Position, ParticleSystem.position);
//		ParticleSystem.sourcePosition	= ccpAdd(Position, Offset);
        if ([Node respondsToSelector: @selector(imageCenter)])
                ParticleSystem.sourcePosition	= ccpAdd(Offset, [Node convertToWorldSpace: [(CCSprite*)Node imageCenter]]);
        else	ParticleSystem.sourcePosition	= ccpAdd(Offset, [Node convertToWorldSpace: CC_POINT_PIXELS_TO_POINTS(Node.anchorPointInPixels)]);
	}
}

-(CCFiniteTimeAction*)getParticleSystemAction
{
	return	[CCCallFuncN actionWithTarget: self selector: @selector(getParticleSystemForNode:)];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initParticleSystemDescriptorWithName: FileName delay: delay duration: duration repetitions: repetitions offset: Offset scale: Scale behaviour: Behaviour stopWithAnimation: stopWithAnimation];
	return copy;
}

-(void)killSystem
{
	CCLOG(@"killSystem %@", ParticleSystem.Name);
	[ParticleSystem pauseEmission];
}

-(void)dealloc
{
	[[ANCParticleSystemManager sharedParticleSystemManager] unloadParticleSystemWithFile: FileName];
	[ParticleSystem release];
	[FileName release];
	[super dealloc];
}
@end


//------------------------------------------------------------------------------------------------------------------------------------------------------------------

@implementation KillParticle

+(id)actionWithParticleSystem: (ANCParticleSystem*)Particle_
{
	return [[[self alloc] initWithParticleSystem: Particle_] autorelease];
}

-(id)initWithParticleSystem: (ANCParticleSystem*)Particle_
{
	if ((self = [super init]))
	{
		Particle	= [Particle_ retain];
	}
	return self;
}

-(void)stop
{
	CCLOG(@"killSystem %@", Particle.Name);
	[Particle pauseEmission];
	[Particle release];
	Particle	= nil;
	[super stop];
}

-(void) step: (ccTime) dt
{}

-(BOOL)isDone
{
	return false;
}

-(void)dealloc
{
	[Particle pauseEmission];
	[Particle release];
	[super dealloc];
}
@end
