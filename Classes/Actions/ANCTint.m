//
//  ANCSetColorAndOpacity.m
//  Farm Attack
//
//  Created by mad4chip on 28/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ANCTint.h"


@implementation ANCSetTint
+(id) actionWithColorRed:(GLshort)r green:(GLshort)g blue:(GLshort)b
{
	return [[[self alloc] initWithTint: ccc4(r, g, b, 255)] autorelease];
}

+(id) actionWithTintRed:(GLshort)r green:(GLshort)g blue:(GLshort)b opacity: (GLshort)o
{
	return [[[self alloc] initWithTint: ccc4(r, g, b, o)] autorelease];
}

+(id) actionWithColor: (ccColor3B)t
{
	return [[[self alloc] initWithTint: ccc4(t.r, t.g, t.b, 255)] autorelease];
}

+(id) actionWithTint: (ccColor4B)t
{
	return [[[self alloc] initWithTint: t] autorelease];
}

-(id) initWithTint: (ccColor4B)t
{
	if ((self = [super init]))
		Tint	= t;
	return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Tag = %i | Tint = (%u, %u, %u, %u) >",
			[self class],
			(unsigned int)self,
			tag_,
			Tint.r, Tint.g, Tint.b, Tint.a
			];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithTint: Tint];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[((NSObject<CCRGBAProtocol>*)aTarget) setColor: ccc3(Tint.r, Tint.g, Tint.b)];
	[((NSObject<CCRGBAProtocol>*)aTarget) setOpacity: Tint.a];
}
@end

//-----------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation ANCTintTo
+(id) actionWithDuration:(ccTime)t andTint: (ccColor4B)tint
{
	return [[[self alloc] initWithDuration:t andTint: tint] autorelease];
}

+(id) actionWithDuration:(ccTime)t red:(GLubyte)r green:(GLubyte)g blue:(GLubyte)b
{
	return [[[self alloc] initWithDuration:t andTint: ccc4(r, g, b, 255)] autorelease];
}

+(id) actionWithDuration:(ccTime)t red:(GLubyte)r green:(GLubyte)g blue:(GLubyte)b opacity: (GLshort)o
{
	return [[[self alloc] initWithDuration:t andTint: ccc4(r, g, b, o)] autorelease];
}

-(id) initWithDuration: (ccTime) t andTint: (ccColor4B)tint
{
	if( (self=[super initWithDuration: t] ) )
		to_ = tint;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] andTint: to_];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];

	ccColor3B temp	= [(id<CCRGBAProtocol>) target_ color];
	from_			= ccc4(temp.r, temp.g, temp.b, [(id<CCRGBAProtocol>) target_ opacity]);
}

-(void) update: (ccTime) t
{
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target_;
	[tn setColor: ccc3(from_.r + (to_.r - from_.r) * t, from_.g + (to_.g - from_.g) * t, from_.b + (to_.b - from_.b) * t)];
	[tn setOpacity: from_.a + (to_.a - from_.a) * t];
}
@end

//-----------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation ANCTintBy
-(void) update: (ccTime) t
{
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target_;
	[tn setColor:ccc3( from_.r + to_.r * t, from_.g + to_.g * t, from_.b + to_.b * t)];
	[tn setOpacity: from_.a + to_.a * t];
}

- (CCActionInterval*) reverse
{
	return [ANCTintBy actionWithDuration:duration_ andTint: ccc4(-to_.r, -to_.g, -to_.b, -to_.a)];
}
@end

