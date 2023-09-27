//
//  SneakyButtonSkinnedBase.m
//  SneakyInput
//
//  Created by Nick Pannuto on 2/19/10.
//  Copyright 2010 Sneakyness, llc.. All rights reserved.
//

#import "SneakyButtonSkinnedBase.h"
#import "SneakyButton.h"

@implementation SneakyButtonSkinnedBase

@synthesize defaultSprite, activatedSprite, disabledSprite, pressedSprite;

+(id)buttonWithRect:(CGRect)rect Sprite: (CCSprite*)Sprite ActivatedSprite: (CCSprite*)ActivatedSprite PressedSprite: (CCSprite*)PressedSprite DisabledSprite: (CCSprite*)DisabledSprite target: (id)target selector:(SEL)selector;
{
	return [[[self alloc] initWithRect:rect Sprite:Sprite ActivatedSprite:ActivatedSprite PressedSprite:PressedSprite DisabledSprite:DisabledSprite target: target selector: selector] autorelease];
}

+(id)buttonWithRect:(CGRect)rect Sprite: (CCSprite*)Sprite ActivatedSprite: (CCSprite*)ActivatedSprite PressedSprite: (CCSprite*)PressedSprite DisabledSprite: (CCSprite*)DisabledSprite
{
	return [[[self alloc] initWithRect:rect Sprite:Sprite ActivatedSprite:ActivatedSprite PressedSprite:PressedSprite DisabledSprite:DisabledSprite target: nil selector: nil] autorelease];
}

-(id)initWithRect:(CGRect)rect Sprite: (CCSprite*)Sprite ActivatedSprite: (CCSprite*)ActivatedSprite PressedSprite: (CCSprite*)PressedSprite DisabledSprite: (CCSprite*)DisabledSprite target: (id)target selector:(SEL)selector;
{
	if ((self = [super initWithRect: rect target: target selector: selector]))
	{
		self.defaultSprite		= Sprite;
		self.activatedSprite	= ActivatedSprite;
		self.disabledSprite		= DisabledSprite;
		self.pressedSprite		= PressedSprite;

		self.defaultSprite.visible		= false;
		self.activatedSprite.visible	= false;
		self.disabledSprite.visible		= false;
		self.pressedSprite.visible		= false;

		CurrentImage			= nil;
		self.visible			= true;
	}
	return self;
}

-(void) dealloc
{
	[defaultSprite release];
	[activatedSprite release];
	[disabledSprite release];
	[pressedSprite release];
	[super dealloc];
}

- (void) watchSelf
{
	CCSprite	*ShowImage;
	if		(!enabled)		ShowImage	= disabledSprite;
	else if (active)		ShowImage	= pressedSprite;
	else if (value == 0)	ShowImage	= defaultSprite;
	else					ShowImage	= activatedSprite;

	if ((void*)ShowImage != (void*)CurrentImage)
	{
		CurrentImage.visible	= false;
		CurrentImage			= ShowImage;
		CurrentImage.visible	= true;
	}
}

- (void) setContentSize:(CGSize)s
{
	[super setContentSize: s];
	radius						= s.width/2;
	radiusSq					= radius*radius;
}

- (void) setDefaultSprite:(CCSprite *)aSprite
{
	[defaultSprite release];
	defaultSprite = [aSprite retain];
	if(aSprite)
		[self setContentSize:defaultSprite.contentSize];
}

- (void) setActivatedSprite:(CCSprite *)aSprite
{
	[activatedSprite release];
	activatedSprite = [aSprite retain];
}

- (void) setDisabledSprite:(CCSprite *)aSprite
{
	[disabledSprite release];
	disabledSprite = [aSprite retain];
}

- (void) setPressedSprite:(CCSprite *)aSprite
{
	[pressedSprite release];
	pressedSprite = [aSprite retain];
}

-(void)setPosition:(CGPoint)Position
{
	defaultSprite.position		= Position;
	activatedSprite.position	= Position;
	disabledSprite.position		= Position;
	pressedSprite.position		= Position;
	[super setPosition: Position];
}

-(void)setAnchorPoint:(CGPoint)Anchor
{
	defaultSprite.anchorPoint	= Anchor;
	activatedSprite.anchorPoint	= Anchor;
	disabledSprite.anchorPoint	= Anchor;
	pressedSprite.anchorPoint	= Anchor;
	[super setAnchorPoint: Anchor];
}

-(void)setVisible:(BOOL)newVisible
{
	[super setVisible: newVisible];
	if (newVisible)
	{
		CurrentImage	= nil;
		[self schedule: @selector(watchSelf)];
		[self watchSelf];
	}
	else
	{
		defaultSprite.visible		= false;
		activatedSprite.visible		= false;
		disabledSprite.visible		= false;
		pressedSprite.visible		= false;
		[self unschedule: @selector(watchSelf)];
	}
}
@end
