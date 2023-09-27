//
//  ANCSprite.m
//  Prova
//
//  Created by mad4chip on 22/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "ANCSprite.h"
#import "ANCSpriteBatchNode.h"

#pragma mark -
#pragma mark ANCSpriteBatchNode

@implementation ANCSpriteBatchNode
#ifndef DISABLE_BATCH
@synthesize Father;
static NSMutableDictionary	*Batches		= nil;

+(void)addSprite: (ANCSprite*)Sprite toFather: (CCNode*)Father onZ: (int)z
{
	NSMutableDictionary	*BatchesFatherDict;
	NSValue				*Key;
	ANCSpriteBatchNode	*BatchNode;

	if (!Batches)	Batches	= [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	
	Key						= [NSValue valueWithPointer: Father];
	if (!(BatchesFatherDict = [Batches objectForKey: Key]))
	{
		BatchesFatherDict	= [NSMutableDictionary dictionaryWithCapacity: 10];
		[Batches setObject: BatchesFatherDict forKey: Key];
	}

	Key						= [NSValue valueWithPointer: Sprite.texture];
	if (!(BatchNode = [BatchesFatherDict objectForKey: Key]))
	{
		BatchNode				= [ANCSpriteBatchNode batchNodeWithTexture: Sprite.texture];
		BatchNode.Father		= Father;
		[BatchesFatherDict setObject: BatchNode forKey: Key];
		[Father addChild: BatchNode z: z];
	}	
	[BatchNode addChild: Sprite];
}

-(id)initWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity
{
	if ((self = [super initWithTexture:tex capacity:capacity]))
		Father	= nil;
	return self;
}

-(void)removeChild:(CCSprite *)sprite cleanup:(BOOL)doCleanup
{
	[super removeChild: sprite cleanup: doCleanup];
	if ([[self children] count] == 0)
		[self.parent removeChild: self cleanup: true];//causa il release e la deallocazione del batchnode
}

-(oneway void)release
{
	if (self.retainCount == 2)
	{
		if ((!Batches) || (!Father))	return;

		NSValue				*FatherKey			= [NSValue valueWithPointer: Father];
		NSMutableDictionary	*BatchesFatherDict	= [Batches objectForKey: FatherKey];
		Father									= nil;//qui retainCount = 2 la riga successiva fà scattare nuovamente [self release] porre Father = nil evita un loop

		[BatchesFatherDict removeObjectForKey: [NSValue valueWithPointer: self.texture]];	//rimuove il batchnode dal dictionary dei padri
		if ([BatchesFatherDict count] == 0)
		{
			[Batches removeObjectForKey: FatherKey];
			if ([Batches count] == 0)
			{
				[Batches release];
				Batches	= nil;
			}
		}
		[self dealloc];//[BatchesZDict removeObjectForKey: Key] non riesce a decrementare retainCount quindi non arriva mai a 0, devo deallocare esplicitamente
	}
	else	[super release];
}

#endif
@end

