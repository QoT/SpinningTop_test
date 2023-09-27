//
//  CCMask.m
//  Masking
//
//  Created by Gilles Lesire on 22/04/11.
//  Copyright 2011 iCapps. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "SpriteMask.h"
#import "CocosAddOn.h"

@implementation MaskedSprite

@synthesize needUpdate;
@synthesize releaseImageAndMask;
@synthesize invertMask;
-(void)setInvertMask:(bool)invert
{
	invertMask	= invert;
	needUpdate	= true;
}

@synthesize Image	= Image_;
@synthesize Mask	= Mask_;
-(void)setImage: (CCSprite*)image
{
	[Image_ release];
	[Image_ onExit];
	Image_		= [image retain];
	needUpdate	= true;
	[Image_ onEnter];//mette running il nodo
}

-(void)setMask: (CCSprite*)mask
{
	[Mask_ release];
	[Mask_ onExit];
	Mask_		= [mask retain];
	needUpdate	= true;
	[Mask_ onEnter];//mette running il nodo
}

-(void)forceUpdate	{	needUpdate	= true;	}

+(id)maskedSpriteWithImage:(CCSprite *)image andMask:(CCSprite *)mask
{
	return [[[self alloc] initWithSpriteWithImage: image andMask: mask] autorelease];
}

+(id)maskedSpriteWithImage:(CCSprite *)image andMask:(CCSprite *)mask invertMask: (bool)invert;
{
	return [[[self alloc] initWithSpriteWithImage: image andMask: mask invertMask: invert] autorelease];
}

-(id)initWithSpriteWithImage:(CCSprite *)image andMask:(CCSprite *)mask
{
	return [self initWithSpriteWithImage: image andMask: mask invertMask: false];
}

-(id)initWithSpriteWithImage:(CCSprite *)image andMask:(CCSprite *)mask invertMask: (bool)invert
{
	if ((self = [super init]))
	{
		self.flipY			= true;
		RenderTexture		= nil;
		MaskFrame			= nil;
		ImageFrame			= nil;
		self.Mask			= mask;
		self.Image			= image;
		needUpdate			= true;
		releaseImageAndMask	= true;
		invertMask			= invert;
		[self applyMask];
	}
	return self;
}

-(void)applyMask
{
	if ((!Image_) || (!Mask_))
		return;
	if ((!needUpdate)							&&
		(![Mask_ isTransformDirty])				&&
		(![Image_ isTransformDirty])			&&
		([Mask_ isFrameDisplayed: MaskFrame])	&&
		([Image_ isFrameDisplayed: ImageFrame]))
			return;

	needUpdate				= false;
	CGPoint	MaskPosition	= Mask_.position;
	CGPoint	ImagePosition	= Image_.position;

	CGRect	MaskRect		= [Mask_ untrimmedRect];//rettangolo scalato e ruotato
	Mask_.position			= ccpSub(Mask_.position,  MaskRect.origin);
	Image_.position			= ccpSub(Image_.position, MaskRect.origin);

	if (!RenderTexture)
	{
		RenderTexture		= [CCRenderTexture renderTextureWithWidth: MaskRect.size.width height: MaskRect.size.height];
		[RenderTexture retain];
		MaskRect.origin	= CGPointZero;
		[self setTexture:		RenderTexture.sprite.texture];
		[self setTextureRect:	MaskRect];
	}

	if (!invertMask)					// SRC				DEST
	{
		[RenderTexture beginWithClear:0 g:0 b:0 a:0];
		glColorMask(0, 0, 0, 1);
		[Mask_	setBlendFunc:(ccBlendFunc){GL_SRC_ALPHA,	GL_ZERO}];
		[Mask_	visit];
	}
	else
	{
		[RenderTexture beginWithClear:0 g:0 b:0 a:1];
		glColorMask(0, 0, 0, 1);
		glBlendEquation(GL_FUNC_REVERSE_SUBTRACT);//Alpha_result = Alpha_destination destination_blend_Alpha - Alpha_source source_blend_A
		[Mask_	setBlendFunc:(ccBlendFunc){GL_SRC_ALPHA,	GL_ONE}];
		[Mask_	visit];
		glBlendEquation(GL_FUNC_ADD);
	}
	glColorMask(1, 1, 1, 1);
									// SRC				DEST
	[Image_	setBlendFunc:(ccBlendFunc){GL_DST_ALPHA,	GL_ZERO}];//GL_ONE_MINUS_DST_ALPHA
	[Image_	visit];
	[RenderTexture end];

	Mask_.position	= MaskPosition;
	[Mask_ nodeToParentTransform];//resetta il flag isTransformDirty altrimenti scatta sempre l'aggiornamento automatico
	[MaskFrame release];
	MaskFrame	= [[Mask_ displayedFrame] retain];

	Image_.position	= ImagePosition;
	[Image_ nodeToParentTransform];
	[ImageFrame release];
	ImageFrame	= [[Image_ displayedFrame] retain];
}

-(void)onEnterTransitionDidFinish
{
	[self applyMask];
	[super onEnterTransitionDidFinish];
	if (releaseImageAndMask)
	{
		[RenderTexture	release];
		RenderTexture	= nil;

		[Image_ release];
		Image_		= nil;
		[ImageFrame release];
		ImageFrame	= nil;

		[Mask_ release];
		Mask_		= nil;
		[MaskFrame release];
		MaskFrame	= nil;
	}
}

-(void)visit
{
	[self applyMask];
	[super visit];
}

-(void)dealloc
{
	[RenderTexture	release];
	[Image_			release];
	[Mask_			release];
	[super dealloc];
}
@end
