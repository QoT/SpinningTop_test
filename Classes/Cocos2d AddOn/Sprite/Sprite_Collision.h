//
//  Sprite_Collision.h
//  Farm Attack
//
//  Created by mad4chip on 17/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import "GameConfig.h"
#import "CocosAddOn.h"

#define	OPTIMIZED_COLLISION		0	//optimzed NOT TESTED YET
#define	FAILSAFE_COLLISION		1	//full non transparent image collision, not aware of scale and rotation
#define	SIMPLE_COLLISION		2	//rect intersection

#define	BYTES_PER_PIXEL			4
#define	ACCURACY				1

#define TEST_IMAGE_SPACING_X	10
#define TEST_IMAGE_SPACING_Y	10


@interface CCSprite (Sprite_Collision)
-(id) CollisionWithSprite: (CCSprite *)Sprite;
-(id) CollisionWithSprites: (NSArray *)SpritesArr OnlyFirst: (bool) OnlyFirst;
-(id) CollisionWithSprites: (NSArray *)SpritesArr OnlyFirst: (bool) OnlyFirst FilterFunc: (SEL) Filter;
@end


#ifdef COLLISION_TEST
#import "ColoredSquareSprite.h"

@interface CollisionTestScene : CCScene
{
	CCSprite			*TestImage;
	NSMutableArray		*TestBullets;
	ColoredSquareSprite	*SpriteRectangle;
}

+(id)NewTestScene;
-(id)NewTestScene;
@end
#endif