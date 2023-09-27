//
//  DisplayFrame.m
//  Prova
//
//  Created by mad4chip on 20/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCSetColor.h"


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCSetColor
+(id) actionWithColorRed:(GLshort)r green:(GLshort)g blue:(GLshort)b
{
	return [[[self alloc] initWithColorRed: r green: g blue: b] autorelease];
}

-(id) initWithColorRed:(GLshort)r green:(GLshort)g blue:(GLshort)b
{
	if( (self=[super init]) )
		Color	= ccc3(r, g, b);
	return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Tag = %i | Color = (%u, %u, %u) >",
			[self class],
			(unsigned int)self,
			tag_,
			Color.r, Color.g, Color.b
			];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithColorRed: Color.r green: Color.g blue: Color.b];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[((NSObject<CCRGBAProtocol>*)aTarget) setColor: Color];
}
@end
