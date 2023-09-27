#import "cocos2d.h"
#import "SoundDescriptor.h"
#import "ANCParticleSystemDescriptor.h"

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface ANCAnimation : CCAnimation
{
	float						WalkLength;
	bool						HideOnEnd;
	SoundDescriptor				*Sound;
	ParticleSystemDescriptor	*Particle;
}

@property (readonly,  nonatomic)		float						duration;
@property (readwrite, nonatomic)		float						WalkLength;
@property (readwrite, nonatomic)		bool						HideOnEnd;
@property (readwrite, nonatomic, assign)SoundDescriptor				*Sound;
@property (readwrite, nonatomic, assign)ParticleSystemDescriptor	*Particle;

@end

