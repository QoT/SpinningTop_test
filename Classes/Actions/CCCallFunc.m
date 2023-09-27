//
//  CCCallFunc.m
//  Farm Attack
//
//  Created by mad4chip on 01/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCallFunc.h"


@implementation CCCallFuncOO
@synthesize  object1 = object1_;

+(id) actionWithTarget: (id) t selector:(SEL) s object:(id)object object:(id)object1 
{
	return [[[self alloc] initWithTarget:t selector:s object:object object:object1] autorelease];
}

-(id) initWithTarget:(id) t selector:(SEL) s object:(id)object object:(id)object1 
{
	if( (self=[super initWithTarget:t selector:s object:object] ) )
		self.object1 = object1;
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithTarget:targetCallback_ selector:selector_ object:object_ object:object1_];
	return copy;
}


-(void) execute
{
	[targetCallback_ performSelector:selector_ withObject:object_ withObject:object1_];
}

- (void) dealloc
{
	[object1_ release];
	[super dealloc];
}
@end
