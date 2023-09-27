//
//  SneakyJoystickSkinnedBase.m
//  SneakyJoystick
//
//  Created by CJ Hanson on 2/18/10.
//  Copyright 2010 Hanson Interactive. All rights reserved.
//

#import "SneakyJoystickSkinnedBase.h"

@implementation SneakyJoystickSkinnedBase

@synthesize backgroundSprite, touchedBackgroundSprite, thumbSprite, touchedThumbSprite;

+(id)joystickWithRadius: (float)Radius BGSprite: (CCSprite*)BGSprite ThumbSprite: (CCSprite*)ThumbSprite TouchedBGSprite: (CCSprite*)TouchedBGSprite TouchedThumbSprite: (CCSprite*)TouchedThumbSprite
{
	return [[[self alloc] initWithRadius: (float)Radius BGSprite: BGSprite ThumbSprite: ThumbSprite TouchedBGSprite: TouchedBGSprite TouchedThumbSprite: TouchedThumbSprite] autorelease];
}

-(id)initWithRadius: (float)Radius BGSprite: (CCSprite*)BGSprite ThumbSprite: (CCSprite*)ThumbSprite TouchedBGSprite: (CCSprite*)TouchedBGSprite TouchedThumbSprite: (CCSprite*)TouchedThumbSprite
{
	if ((self = [super initWithRadius: Radius]))
	{
		self.backgroundSprite			= BGSprite;
		self.touchedBackgroundSprite	= TouchedBGSprite;
		self.thumbSprite				= ThumbSprite;
		self.touchedThumbSprite			= TouchedThumbSprite;
		self.anchorPoint				= ccp(0.5, 0.5);
		[self schedule:@selector(updatePositions)];
		[self setContentSize: CGSizeMake(2*Radius, 2*Radius)];
	}
	return self;
}

- (void) dealloc
{
	[backgroundSprite release];
	[touchedThumbSprite release];
	[touchedBackgroundSprite release];
	[thumbSprite release];
	[super dealloc];
}

- (void) updatePositions
{
	if (thumbSprite)
		thumbSprite.position	= touchedThumbSprite.position	=  [self convertToWorldSpaceAR: self.stickPosition];
	if ((touchedThumbSprite) && (self.touched))
	{
		thumbSprite.visible				= false;
		touchedThumbSprite.visible		= true;
	}
	else
	{
		thumbSprite.visible				= true;
		touchedThumbSprite.visible		= false;			
	}
	if ((touchedBackgroundSprite) && (self.touched))
	{
		backgroundSprite.visible		= false;
		touchedBackgroundSprite.visible	= true;
	}
	else
	{
		backgroundSprite.visible		= true;
		touchedBackgroundSprite.visible	= false;			
	}
}

- (void) setBackgroundSprite:(CCSprite *)aSprite
{
	[backgroundSprite release];
	backgroundSprite = [aSprite retain];
}

- (void) setTouchedBackgroundSprite:(CCSprite *)aSprite
{
	[touchedBackgroundSprite release];
	touchedBackgroundSprite = [aSprite retain];
	touchedBackgroundSprite.visible	= false;
}

- (void) setThumbSprite:(CCSprite *)aSprite
{
	[thumbSprite release];
	thumbSprite = [aSprite retain];
	if (!aSprite)
		[self setThumbRadius:0];
}

- (void) setTouchedThumbSprite:(CCSprite *)aSprite
{
	[touchedThumbSprite release];
	touchedThumbSprite = [aSprite retain];
	touchedThumbSprite.visible	= false;
}

-(void)setPosition:(CGPoint)Position
{
	backgroundSprite.position			= Position;
	thumbSprite.position				= Position;
	touchedBackgroundSprite.position	= Position;
	touchedThumbSprite.position			= Position;
	[super setPosition: Position];
}

-(void)setAnchorPoint:(CGPoint)Anchor
{
	backgroundSprite.anchorPoint		= Anchor;
	thumbSprite.anchorPoint				= Anchor;
	touchedBackgroundSprite.anchorPoint	= Anchor;
	touchedThumbSprite.anchorPoint		= Anchor;
	[super setAnchorPoint: Anchor];
}

-(void)setVisible:(BOOL)newVisible
{
	[super setVisible: newVisible];
	if (newVisible)
		[self updatePositions];
	else
	{
		backgroundSprite.visible			= false;
		thumbSprite.visible					= false;
		touchedBackgroundSprite.visible		= false;
		touchedThumbSprite.visible			= false;
	}
}
@end
