//
//  button.m
//  Classroom Demo
//
//  Created by Nick Pannuto on 2/10/10.
//  Copyright 2010 Sneakyness, llc.. All rights reserved.
//

#import "SneakyButton.h"

@implementation SneakyButton

@synthesize enabled, value, active, isHoldable, isToggleable, rateLimit, radius;
-(void)setIsHoldable: (BOOL)newValue
{
	if (!newValue)
	{
		active	= false;
		value	= 0;
	}
	isHoldable	= newValue;
}

-(void)setIsToggleable: (BOOL)newValue
{
	if (!newValue)
	{
		active	= false;
		value	= 0;
	}
	isToggleable	= newValue;
}

-(void)setVisible:(BOOL)newVisible
{
	if (!newVisible)
	{
		self.value	= false;
		active		= false;
	}
	[super setVisible: newVisible];
}

-(void)setEnabled:(BOOL)Enabled
{
	if (!Enabled)
	{
		self.value	= false;
		active		= false;
	}
	enabled	= Enabled;
}

@synthesize Invokation;
-(void)setInvokation: (NSInvocation*)newInvokation
{
	[Invokation release];
	Invokation	= [newInvokation retain];
}

+(id)buttonWithRect:(CGRect)rect
{
	return [[[self alloc] initWithRect: rect target: nil selector: nil] autorelease];
}

+(id)buttonWithRect:(CGRect)rect target: (id)target selector: (SEL)selector
{
	return [[[self alloc] initWithRect: rect target: target selector: selector] autorelease];
}

-(id)initWithRect:(CGRect)rect target: (id)target selector: (SEL)selector
{
	if ((self = [super init]))
	{	
		bounds			= CGRectMake(0, 0, rect.size.width, rect.size.height);
		center			= CGPointMake(rect.size.width/2, rect.size.height/2);
		enabled			= true; //defaults to enabled
		active			= NO;
		value			= 0;
		isHoldable		= 0;
		isToggleable	= 0;
		radius			= 32.0f;
		rateLimit		= 1.0f/120.0f;
		self.position	= ccpAdd(rect.origin, center);

		if (target)
		{
			Invokation = [NSInvocation invocationWithMethodSignature: [target methodSignatureForSelector: selector]];
			[Invokation setTarget: target];
			[Invokation setSelector: selector];
			[Invokation retain];
		}
	}
	return self;
}

- (void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
}

- (void) onExit
{
	[super onExit];
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	self.value	= false;
	active		= false;
}

-(void)limiter:(float)delta
{
	value = 0;
	[self unschedule: @selector(limiter:)];
	active = NO;
}

- (void) setRadius:(float)r
{
	radius = r;
	radiusSq = r*r;
}

#pragma mark Touch Delegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ((!visible_) ||
		(!enabled))	return false;
	if (active) 	return NO;
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	location = [self convertToNodeSpace:location];
		//Do a fast rect check before doing a circle hit check:
	if(location.x < -radius || location.x > radius || location.y < -radius || location.y > radius)
		return NO;
	else
	{
		float dSq = location.x*location.x + location.y*location.y;
		if(radiusSq > dSq)
		{//tocco all'interno del cerchio del tasto
			active = YES;
			if (!isHoldable && !isToggleable)
			{
				value = 1;
				[self schedule: @selector(limiter:) interval:rateLimit];
			}
			else if (isHoldable)	value = 1;
			else if (isToggleable)	value = !value;
			[Invokation invoke];
			return YES;
		}
	}
	return NO;
}
/*
-(void)cleanup
{
	[Target release];//nel caso il target è un antenato del bottone evita un riferimento circolare che impedisce la deallocazione
	Target	= nil;
	[super cleanup];
}
*/
-(void) dealloc
{
	[Invokation release];
	[super dealloc];
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ((!visible_) ||
		(!enabled))	return;
	
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	location = [self convertToNodeSpace:location];
		//Do a fast rect check before doing a circle hit check:
	if(location.x < -radius || location.x > radius || location.y < -radius || location.y > radius)
		return;
	else
	{
		float dSq = location.x*location.x + location.y*location.y;
		if (radiusSq > dSq)
		{
			if (isHoldable)
			{
				value = 1;
				[Invokation invoke];
			}
		}
		else
		{
			if (isHoldable)	value = 0;
			active = NO;
			[Invokation invoke];
		}
	}
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ((!visible_) ||
		(!enabled))	return;
	if (isHoldable)
	{
		value = 0;
		[Invokation invoke];
	}
	if (isHoldable||isToggleable)
	{
		active = NO;
		[Invokation invoke];
	}
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self ccTouchEnded:touch withEvent:event];
}

@end
