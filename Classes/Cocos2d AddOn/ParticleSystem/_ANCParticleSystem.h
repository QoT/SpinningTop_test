//
//  ANCParticleSystem.h
//  Farm Attack
//
//  Created by mad4chip on 24/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import "cocos2d.h"

typedef enum
{
	PARTICLE_POSITION_ABSOLUTE	= 0,		//absolute
	PARTICLE_POSITION_RELATIVE,				//relative
	PARTICLE_POSITION_SYSTEM_FOLLOW_ENTITY,	//the entire particle system follow the entity
	PARTICLE_POSITION_SOURCE_FOLLOW_ENTITY	//the emitting source follow the entity
} TParticleBehaviour;
#define PARTICLE_POSITION_DEFAULT	PARTICLE_POSITION_RELATIVE

@interface ANCParticleSystem : CCParticleSystemQuad
{
	NSString			*Name_;
	CCNode				*attachToNode_;
	CGPoint				Offset;
	TParticleBehaviour	Behaviour;
}

@property (readwrite, nonatomic, assign)	NSString			*Name;
@property (readwrite, nonatomic, assign)	CCNode				*attachToNode;
@property (readwrite, nonatomic, assign)	bool				sourceFollowNode;
@property (readwrite, nonatomic)			CGPoint				Offset;
@property (readwrite, nonatomic)			TParticleBehaviour	Behaviour;


+(id) particleWithDictionary:(NSDictionary *)dictionary;
-(void)updatePosition;
-(void)pauseEmission;
-(void)resumeEmission;
-(void)stopSystem;
-(void)resumeSystem;

@end

