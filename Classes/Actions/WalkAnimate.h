//
//  WalkAnimate.h
//  Prova
//
//  Created by mad4chip on 18/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//	Se l'animazione slitta in avanti ridurre WalkLength, 
//	se slitta all'indietro aumentarlo

#import "cocos2d.h"
#import "ANCSprite.h"

@interface WalkAnimate : CCAction
{
	ANCAnimation		*animation;
	float				Remainder;
	CGPoint				LastPosition;
	int					LastFrame;
}
@property (readwrite,nonatomic,retain)	ANCAnimation	*animation;
@property (readonly)					NSArray				*frames;

+(id) actionWithAnimation: (ANCAnimation*) Animation;
-(id) initWithAnimation: (ANCAnimation*) Animation;
@end
