//
//  AudioFade.m
//  Prova
//
//  Created by mad4chip on 08/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioActions.h"
#import "functions.h"

@implementation AudioAction

+(id)actionWithDescriptor: (SoundDescriptor*) Descriptor
{
	return [[[self alloc] initWithDescriptor: Descriptor] autorelease];
}

-(id)initWithDescriptor: (SoundDescriptor*) Descriptor
{
	if ((self = [super init]))
	{
		Playing	= false;
		Sound	= [Descriptor retain];
	}
	return self;
}
/*
-(void)startWithTarget:(id)target
{
	Playing	= false;
	[super startWithTarget:target];
}
*/
-(BOOL)isDone
{
	return false;
}

-(void)dealloc
{
	[self stop];
	[Sound release];
	[super dealloc];
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation LoopPlaySound
-(void)stop
{
	if (Playing)
	{
		CCLOG(@"LoopPlaySound start fade out");
		if (Sound.FadeOutTime > 0)//se c'è un fadeOut non fermo il suono e creo l'azione di fadeOut
				[[CCActionManager sharedManager] addAction: [AudioFadeOut actionWithDescriptor: Sound] target: target_ paused: false];
		else	[Sound stop];
		Playing	= false;//evita di fermare il suono alla deallocazione dell'azione
	}
	[super stop];
}

-(void) step: (ccTime) dt
{
	if (!Playing)
	{
		Playing	= true;
		[Sound playForTarget: target_ loop: true];
		if (Sound.FadeInTime > 0)
		{
			CCAction *Fade	= [AudioFadeIn actionWithDescriptor: Sound];
			Fade.tag		= tag_;
			[[CCActionManager sharedManager] addAction: Fade target: target_ paused: false];
		}
	}
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation AudioAutoPan
-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget: aTarget];
	lastXPosition	= ((CCNode*)aTarget).position.x;
}

-(void) update: (ccTime) t
{
	if (lastXPosition != ((CCSprite*)target_).position.x)
	{
		float PanResult	= ((((CCSprite*)target_).position.x)/ScreenSize.width) - 1;
		Sound.pan	= PanResult * MAX_PAN;
		lastXPosition = ((CCSprite*)target_).position.x;
	}
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation AudioActionInterval

+(id)actionWithDescriptor: (SoundDescriptor*) Descriptor
{
	return [[[self alloc] initWithDescriptor: Descriptor] autorelease];
}

-(id)initWithDescriptor: (SoundDescriptor*) Descriptor
{
	if ((self = [super initWithDuration: Descriptor.SoundDuration]))
	{
		Playing	= false;
		Sound	= [Descriptor retain];
	}
	return self;
}
/*
-(void)startWithTarget:(id)target
{
	Playing	= false;
	[super startWithTarget:target];
}
*/
-(void)dealloc
{
	[self stop];
	[Sound release];
	[super dealloc];
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation PlaySound
-(void)stop
{
	if (Playing)
	{
		[Sound stop];
		Playing	= false;
	}
	[super stop];
}

-(void) update: (ccTime) time
{
	if (!Playing)
	{
		Playing	= true;
		[Sound playForTarget: target_ loop: false];
	}
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation AudioFadeIn
-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget: aTarget];
	[self update: 0];
}

-(void) update: (ccTime) t
{
	Sound.gain	= t;
	CCLOG(@"Current gain %.2f, %.2f", Sound.gain, t);
}

-(void)stop
{
	[self update: 1];
	[super stop];
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation AudioFadeOut
-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget: aTarget];
	initialGain	= Sound.gain;
}

-(void)stop
{//usato per fermare i suoni partiti con loopPlaySound
	[Sound stop];
	[super stop];
}

-(void) update: (ccTime) t
{
	Sound.gain	= (1-t) * initialGain;
}
@end
