//
//  AudioFade.h
//  Prova
//
//  Created by mad4chip on 08/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SoundDescriptor.h"
#import "cocos2d.h"

#define MAX_PAN	1

@interface AudioAction : CCAction
{
	SoundDescriptor	*Sound;
	bool			Playing;
}

+(id)actionWithDescriptor: (SoundDescriptor*) Descriptor;
-(id)initWithDescriptor: (SoundDescriptor*) Descriptor;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------
@interface LoopPlaySound : AudioAction
{}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------
@interface AudioAutoPan : AudioAction
{
	float	lastXPosition;
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------------------
@interface AudioActionInterval : CCActionInterval
{
	SoundDescriptor	*Sound;
	bool			Playing;
}

+(id)actionWithDescriptor: (SoundDescriptor*) Descriptor;
-(id)initWithDescriptor: (SoundDescriptor*) Descriptor;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------
@interface PlaySound : AudioActionInterval
{}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------
@interface AudioFadeIn : AudioActionInterval
{}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------
@interface AudioFadeOut : AudioActionInterval
{
	float	initialGain;
}
@end


