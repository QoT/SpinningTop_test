#import "ANCAnimation.h"

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation ANCAnimation
@synthesize WalkLength;
@synthesize HideOnEnd;
@synthesize	Sound;
-(void)setSound: (SoundDescriptor*)SoundName
{
	[Sound release];
	Sound	= [SoundName retain];
}

@synthesize Particle;
-(void)setParticle: (ParticleSystemDescriptor*)ParticleName
{
	[Particle release];
	Particle	= [ParticleName retain];
}

-(float)duration
{
	return delay_ * [frames_ count];
}


-(id) initWithFrames:(NSArray*)array delay:(float)delay
{
	if ((self = [super initWithFrames: array delay: delay]))
		Sound	= nil;
	return self;
}
- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | frames:%d, delay:%.2f, name: %@, WalkLength:%.2f, HideOnEnd: %@,\n Audio: %@>",
			[self class],
			(unsigned int)self,
			[frames_ count],
			delay_,
			name_,
			WalkLength,
			(HideOnEnd)?(@"true"):(@"false"),
			Sound.Name
			];
}

-(void)dealloc
{
	[Sound release];
	[super dealloc];
}
@end