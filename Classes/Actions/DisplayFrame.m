//
//  DisplayFrame.m
//  Prova
//
//  Created by mad4chip on 20/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DisplayFrame.h"


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation DisplayFrame
+(id) actionWithSpriteFrame: (CCSpriteFrame*)Frame
{
	return [[[self alloc] initWithSpriteFrame: Frame] autorelease];
}

-(id) initWithSpriteFrame: (CCSpriteFrame*)Frame
{
	if( (self=[super init]) )
	{
		Frame2Display = [Frame retain];
	}
	return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Tag = %i | Frame = %@ >",
			[self class],
			(unsigned int)self,
			tag_,
			[Frame2Display class]
			];
}

-(void) dealloc
{
	[Frame2Display release];
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithSpriteFrame: Frame2Display];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	NSAssert([aTarget isKindOfClass: [CCSprite class]], @"Terget must be a CCSprite class");
	[super startWithTarget:aTarget];
	((CCSprite*)aTarget).visible	= true;
	if (![aTarget isFrameDisplayed: Frame2Display])
		[aTarget setDisplayFrame: Frame2Display];
}
@end
