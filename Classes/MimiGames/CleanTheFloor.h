//
//  OptionMenu.h
//  Prova
//
//  Created by Visone on 10/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import "cocos2d.h"
#import "ANCScene.h"
#import "ANCSprite.h"
#import "SneakyButtonSkinnedBase.h"
#import "MimiLandManager.h"

@interface CleanTheFloor : MimiLandManager
{
	ANCSprite		*Sponge;
	NSMutableArray	*Objects;
	NSMutableArray	*AllObjects;
	float			ObjectSpeed;
	float			LastCheck;
	float			Threshold;
}
@end
