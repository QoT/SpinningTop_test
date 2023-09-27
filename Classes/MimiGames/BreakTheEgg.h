//
//  OptionMenu.h
//  Prova
//
//  Created by Visone on 10/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import "cocos2d.h"
#import "ANCSprite.h"
#import "MimiLandManager.h"
#import "ANCParticleSystemDescriptor.h"

@interface BreakTheEgg : MimiLandManager
{
	ANCSprite	*Egg;
	ANCSprite	*Fracture;
	ANCSprite	*Eyes;
	ANCSprite	*Chick;
	ANCSprite	*Nest;
	CCLayer		*ChickLayer;
	ParticleSystemDescriptor	*EggPieces;
	int			HitNum;
	int			TotalHitNum;
	int			FrameCount;
}
@end
