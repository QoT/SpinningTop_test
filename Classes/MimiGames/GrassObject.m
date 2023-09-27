//
//  Screw.m
//  SpinningTop
//
//  Created by mad4chip on 14/11/12.
//
//

#import "GrassObject.h"
#import "CocosAddOn.h"

@implementation GrassObject

@synthesize isLive;
-(void)setIsLive:(bool)newLive
{
	isLive	= newLive;
	if (isLive)	[self Live];
	else		[self Dead];
}

@synthesize Type;
-(void)setType: (NSString*)String
{
	[Type release];
	Type	= [String retain];
}

+(id)grassWithType: (NSString*) type
{
	GrassObject	*Obj	= [self spriteWithFile: type];
	Obj.Type	= [[type componentsSeparatedByString: @"@"] objectAtIndex: 0];
	return Obj;
}

-(void)Dead	{	[self runState: [NSString stringWithFormat: @"1@%@", Type] times: 0];	}
-(void)Live	{	[self runState: [NSString stringWithFormat: @"0@%@", Type] times: 0];	}
@end
