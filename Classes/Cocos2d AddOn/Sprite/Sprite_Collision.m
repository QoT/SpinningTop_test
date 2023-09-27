//
//  Sprite_Collision.m
//  Farm Attack
//
//  Created by mad4chip on 17/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//


//USARE
//USARE
//USARE
//USARE
//glBlendEquationOES(GL_MAX_EXT);

#import "Sprite_Collision.h"
#import "functions.h"

@implementation CCSprite (Sprite_Collision)
/*
 http://www.opengl.org/sdk/docs/man/xhtml/glPixelTransfer.xml
 http://pyopengl.sourceforge.net/documentation/manual/glBlendFunc.3G.html
 http://www.khronos.org/opengles/sdk/2.0/docs/man/glBlendFuncSeparate.xml
 */

-(id) CollisionWithSprite: (CCSprite *)Sprite
{
	return [self CollisionWithSprites: [NSArray arrayWithObject: Sprite] OnlyFirst: true];
}

-(id) CollisionWithSprites: (NSArray *)SpritesArr OnlyFirst: (bool) OnlyFirst
{
	return [self CollisionWithSprites: SpritesArr OnlyFirst: OnlyFirst FilterFunc: nil]; 
}

#if COLLISION_ALGORITHM	== OPTIMIZED_COLLISION
-(id) CollisionWithSprites: (NSArray *)SpritesArr OnlyFirst: (bool) OnlyFirst FilterFunc: (SEL) Filter
{
	bool			SelfAlias			= false;
	bool			SpriteAlias			= false;
	CCSprite		*Target;
	CCSprite		*SpriteTarget;
	id				Collisions			= nil;
	CGRect			SelfRect			= [self.parent convertRectToWorldSpace: [self TrimmedRect]];
	CGRect			SelfUntrimmedrect;
	CGPoint			SelfPosition;
	float			SelfVertexZ;

	if (self.usesBatchNode)
	{
		SelfAlias			= true;
		Target				= nil;
	}
	else
	{
		SelfPosition		= self.position;
		SelfVertexZ			= self.vertexZ;
		Target				= self;
		SelfAlias			= false;
	}
	if ((self.offsetPositionInPixels.x != 0) ||	//se la sprite ha una parte trasparente taglia fuori allora calcolo il rettangolo non tagliato
		(self.offsetPositionInPixels.y != 0))
			SelfUntrimmedrect	= [self.parent convertRectToWorldSpace: [self untrimmedRect]];
	else	SelfUntrimmedrect	= SelfRect;

	for (CCSprite *Sprite in SpritesArr)
	{
		CGRect	SpriteRect					= [Sprite.parent convertRectToWorldSpace: [Sprite TrimmedRect]];
		CGRect	Intersection				= CGRectIntersection(SelfRect, SpriteRect);
		int		Width						= Intersection.size.width;
		int		Height						= Intersection.size.height;
		if ((Height <= 0) || (Width <= 0))
			continue;
		if ((Filter) && (![self performSelector: Filter withObject: Sprite]))
			continue;

//						if (!Collisions)	Collisions	= [NSMutableArray arrayWithObject: Sprite];
//						else				[(NSMutableArray *)Collisions addObject:Sprite];
//						continue;

		//simple collisinons stops here
		CGPoint	SpritePosition;
		float	SpriteVertexZ;

		if (Sprite.usesBatchNode)
		{
			SpriteTarget		= [[Sprite copy] autorelease];
			SpriteAlias			= true;
		}
		else
		{
			SpriteTarget		= Sprite;
			SpriteAlias			= false;
			SpritePosition		= Sprite.position;
			SpriteVertexZ		= Sprite.vertexZ;
		}

		if ((Sprite.offsetPositionInPixels.x != 0) ||	//se la sprite ha una parte trasparente taglia fuori allora calcolo il rettangolo non tagliato
			(Sprite.offsetPositionInPixels.y != 0))
				SpriteRect					= [Sprite.parent convertRectToWorldSpace: [Sprite untrimmedRect]];
		SpriteTarget.position				= ccp(SpriteRect.origin.x - Intersection.origin.x + SpriteRect.size.width * SpriteTarget.anchorPoint.x,
												  SpriteRect.origin.y - Intersection.origin.y + SpriteRect.size.height * SpriteTarget.anchorPoint.y);
		if (!Target)	Target				= [[self copy] autorelease];
		Target.position						= ccp(SelfUntrimmedrect.origin.x - Intersection.origin.x + SelfUntrimmedrect.size.width * Target.anchorPoint.x,
												  SelfUntrimmedrect.origin.y - Intersection.origin.y + SelfUntrimmedrect.size.height * Target.anchorPoint.y);

//		Width	*= CC_CONTENT_SCALE_FACTOR();	da qui in poi mi servono i pixel non i punti ma sembra funzionare ugualmente
//		Height	*= CC_CONTENT_SCALE_FACTOR();	se non faccio la conversione che mi conporterebbe leggere 4 volte il numero di pixel

		CCRenderTexture	*Render				= [CCRenderTexture renderTextureWithWidth:MAX(Width, 16) height: MAX(Height, 16)]; // se Width o height sono < 16 non riesce ad allocare il buffer
		
		[Render begin];
		[Target visit];//self o sua copia
		unsigned int *RawSelfData			= malloc(Height * Width * BYTES_PER_PIXEL);
		glReadPixels(0, 0, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, RawSelfData);		//0xAABBGGRR

		glClearColor(0, 0, 0, 0);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
		[SpriteTarget visit];
		unsigned int *RawSpriteData			= malloc(Height * Width * BYTES_PER_PIXEL);
		glReadPixels(0, 0, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, RawSpriteData);	//0xAABBGGRR
		[Render end];
//USARE
//glBlendEquationOES(GL_MAX_EXT);

		//		NSData	*RawSelfNSData		= [NSData dataWithBytesNoCopy:RawSelfData length:Height * Width * BYTES_PER_PIXEL];
		//		NSData	*RawSpriteNSData	= [NSData dataWithBytesNoCopy:RawSpriteData length:Height * Width * BYTES_PER_PIXEL];
		//pixel organizzati in righe X + Y*WIDTH
		//riga0 riga1 riga2 riga3

/*		for (int x = 0; x < Width; x += ACCURACY*CC_CONTENT_SCALE_FACTOR())
			for (int y = 0; y < Height; y += ACCURACY*CC_CONTENT_SCALE_FACTOR())
				if ((RawSpriteData[x + y * Width] != 0) && 
					(RawSelfData[x + y * Width] != 0))
*/		for (int i = 0; i < Height * Width; i++)
			if ((RawSpriteData[i] != 0) && 
				(RawSelfData[i] != 0))
			{
				if (!Collisions)
				{
					if (OnlyFirst)	Collisions	= Sprite;
					else			Collisions	= [NSMutableArray arrayWithObject: Sprite];
				}
				else				[(NSMutableArray *)Collisions addObject:Sprite];
				goto COLL_DET;
			}
		
	COLL_DET:
		if (!SpriteAlias)
		{
			Sprite.position		= SpritePosition;	//ripristino la posizione della sprite
			Sprite.vertexZ		= SpriteVertexZ;
		}
		free(RawSpriteData);
		free(RawSelfData);

		if ((Collisions) && (OnlyFirst))	break;
	}
	if (!SelfAlias)
	{
		self.position		= SelfPosition;		//altrimenti convertRectToNodeSpace non funziona correttamente
		self.vertexZ		= SelfVertexZ;
	}
	return Collisions;
}

#elif COLLISION_ALGORITHM == FAILSAFE_COLLISION
/*
*/

#elif COLLISION_ALGORITHM == SIMPLE_COLLISION
-(id) CollisionWithSprites: (NSArray *)SpritesArr OnlyFirst: (bool) OnlyFirst FilterFunc: (SEL) Filter
{
	id				Collisions		= nil;
	CGRect			SelfRect		= self.boundingBox;
	
	for (CCSprite *Sprite in SpritesArr)
	{
		CGRect	Intersection				= CGRectIntersection(SelfRect, Sprite.boundingBox);
		int		Width						= Intersection.size.width;
		int		Height						= Intersection.size.height;
		if ((Height <= 0) || (Width <= 0))
			continue;
		if ((Filter) && (![self performSelector: Filter withObject: Sprite]))
			continue;
		
		if (!Collisions)
		{
			if (OnlyFirst)
				return Sprite;
			else	Collisions	= [NSMutableArray arrayWithObject: Sprite];
		}
		else		[(NSMutableArray *)Collisions addObject:Sprite];
	}
	return Collisions;
}
#else
#error(Select a collison algorithm);
#endif
@end


#ifdef COLLISION_TEST
#import "ANCSprite.h"
#import "ANCAnimationCache.h"

@implementation CollisionTestScene : CCScene

+(id)NewTestScene
{
	return [[[super alloc] NewTestScene] autorelease];
}

-(id)NewTestScene
{
	if ((self = [super init]))
	{
		[[ANCAnimationCache sharedAnimationCache] loadAtlasFile: @"Boss_brucone.plist"];
		CCLayerColor	*Layer	= [CCLayerColor layerWithColor: ccc4(0,0,0,0)];
		[self addChild: Layer];

		TestBullets	= [[NSMutableArray arrayWithCapacity: 0] retain];
		for (int x = 0; x < ScreenSize.width; x += TEST_IMAGE_SPACING_X)
			for (int y = 0; y < ScreenSize.height; y += TEST_IMAGE_SPACING_Y)
			{
				TestImage				= [ANCSprite spriteWithFile: @"ball.png"];
				TestImage.position		= ccp(x, y);
				TestImage.anchorPoint	= ccp(0.5,0.5);
				TestImage.scale			= 3;
				[Layer addChild: TestImage];
				[TestBullets addObject: TestImage];
			}
		TestImage				= [ANCSprite spriteWithFile: @"anello_4.png"];
		TestImage.position		= ccp(ScreenSize.width / 2, ScreenSize.height / 2);
		TestImage.scale			= 1;
		TestImage.anchorPoint	= ccp(0.5,0.5);
		[Layer addChild: TestImage z: -1];

		SpriteRectangle				= [ColoredSquareSprite squareWithColor: ccc4(0, 255, 0, 32) size: CGSizeZero];
		SpriteRectangle.anchorPoint	= ccp(0,0);
		[Layer addChild: SpriteRectangle z: 10];

//		[TestImage runAction: [CCRotateBy actionWithDuration: 300 angle: 3600]];
		[self scheduleUpdate];
	}
	return self;
}

-(void)update: (ccTime)dt
{
	CGRect	SpriteRect			= [TestImage TrimmedRect];
	SpriteRectangle.position	= SpriteRect.origin;
	SpriteRectangle.size		= SpriteRect.size;
	
	CCSprite *Sprite;
	for (Sprite in TestBullets)
		Sprite.color	= ccc3(255, 255, 255);

	NSArray	*Collisions	= [TestImage CollisionWithSprites: TestBullets OnlyFirst: false];
	for (Sprite in Collisions)
		Sprite.color	= ccc3(255, 128, 128);
}
@end

#endif