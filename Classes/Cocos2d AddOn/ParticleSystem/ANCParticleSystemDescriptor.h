//
//  ANCParticleSystem.h
//  Farm Attack
//
//  Created by mad4chip on 24/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import "cocos2d.h"
#import "ANCParticleSystem.h"
#import "ANCParticleSystemManager.h"

#define KEEP_DURATION	0

typedef enum
{
	PARTICLE_POSITION_ABSOLUTE	= 0,//absolute
	PARTICLE_POSITION_RELATIVE,		//relative
	PARTICLE_POSITION_FOLLOW_ENTITY	//follow
} TParticleBehaviour;
#define PARTICLE_POSITION_DEFAULT	PARTICLE_POSITION_RELATIVE

@interface ParticleSystemDescriptor : NSObject
{
	bool				stopWithAnimation;
	float				delay;
	float				duration;
	int					repetitions;
	CGPoint				Offset;
	CGPoint				Scale;
	TParticleBehaviour	Behaviour;
	NSString			*FileName;
	ANCParticleSystem	*ParticleSystem;
	ANCParticleSystemManager	*Manager;
}
@property (readonly, nonatomic)		bool				stopwithanimation;
@property (readonly, nonatomic)		float				delay;
@property (readonly, nonatomic)		float				duration;
@property (readonly, nonatomic)		int					repetitions;
@property (readonly, nonatomic)		CGPoint				Offset;
@property (readonly, nonatomic)		CGPoint				Scale;
@property (readonly, nonatomic)		TParticleBehaviour	Behaviour;
@property (readonly, nonatomic)		NSString			*FileName;
@property (readonly, nonatomic)		ANCParticleSystem	*ParticleSystem;

+(id)particleSystemDescriptorFromDictionary: (NSDictionary*)DescriptionData;
+(id)particleSystemDescriptorWithName: (NSString*)Name_;
+(id)particleSystemDescriptorWithName: (NSString*)Name_ delay: (float) delay_ duration: (float) duration_ repetitions: (int) repetitions_ offset: (CGPoint)offset_ scale: (CGPoint)scale_ behaviour: (TParticleBehaviour)behaviour_ stopWithAnimation: (bool)stopWithAnimation_;
-(id)initParticleSystemDescriptorWithName: (NSString*)Name_ delay: (float) delay_ duration: (float) duration_ repetitions: (int) repetitions_ offset: (CGPoint)offset_ scale: (CGPoint)scale_ behaviour: (TParticleBehaviour)behaviour_ stopWithAnimation: (bool)stopWithAnimation_;
-(void)getParticleSystemForNode: (CCNode*) Node;
-(void)resumeForDuration: (CCNode*)Node;
-(CCFiniteTimeAction*)getParticleSystemAction;
-(void)killSystem;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------

@interface KillParticle : CCAction
{
	ParticleSystemDescriptor	*Particle;
}

+(id)actionWithParticleSystem: (ParticleSystemDescriptor*)Particle_;
-(id)initWithParticleSystem: (ParticleSystemDescriptor*)Particle_;
@end
