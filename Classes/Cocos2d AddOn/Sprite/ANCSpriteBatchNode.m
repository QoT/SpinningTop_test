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
@synthesize BatchesDict;
static NSMutableDictionary	*Batches		= nil;

+(void)addSprite: (ANCSprite*)Sprite toFather: (CCNode*)Father onZ: (int)z
{
	NSMutableDictionary	*BatchesFatherDict;
	NSMutableDictionary	*BatchesTextureDict;
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
	if (!(BatchesTextureDict = [BatchesFatherDict objectForKey: Key]))
	{
		BatchesTextureDict	= [NSMutableDictionary dictionaryWithCapacity: 10];
		[BatchesTextureDict setObject: BatchesFatherDict  forKey: [NSValue valueWithPointer: nil]];
		[BatchesFatherDict  setObject: BatchesTextureDict forKey: Key];
	}	
	
	Key						= [NSNumber numberWithInt: z];
	if (!(BatchNode = [BatchesTextureDict objectForKey: Key]))
	{
		BatchNode				= [ANCSpriteBatchNode batchNodeWithTexture: Sprite.texture];
		BatchNode.BatchesDict	= BatchesTextureDict;
		[BatchesTextureDict setObject: BatchNode forKey: Key];
		[Father addChild: BatchNode z: z];
	}
	[BatchNode addChild: Sprite];
}

-(id)initWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity
{
	if ((self = [super initWithTexture:tex capacity:capacity]))
	{
		autoDeallocate	= true;
		BatchesDict		= nil;
	}
	return self;
}

-(void)removeChild:(CCSprite *)sprite cleanup:(BOOL)doCleanup
{
	[super removeChild: sprite cleanup: doCleanup];
	if (([[self children] count] == 0) && (autoDeallocate))
		[self.parent removeChild: self cleanup: true];//causa il release e la deallocazione del batchnode
}

-(void) reorderChild:(CCSprite*)child z:(NSInteger)z
{
	autoDeallocate	= false;
	[super reorderChild: child z: z];
	autoDeallocate	= true;
}

-(oneway void)release
{
	if (self.retainCount == 2)
	{
		if ((!Batches) || (!BatchesDict))	return;
		NSMutableDictionary	*BatchesZDict	= BatchesDict;
		BatchesDict	= nil;//qui retainCount = 2 la riga successiva fà scattare nuovamente [self release] porre BatchesDict = nil evita un loop
		NSNumber	*Key	= [NSNumber numberWithInt: zOrder_];
		[BatchesZDict removeObjectForKey: Key];	//rimuove il batchnode dal dictionary delle texture
		if ([BatchesZDict count] == 1)//il backreference
		{
			NSMutableDictionary	*BatchesTextureDict	= [BatchesZDict objectForKey: [NSValue valueWithPointer: nil]];	//ottengo il backreference
			[BatchesTextureDict removeObjectForKey: [NSValue valueWithPointer: self.texture]];	//rimuove il batchnode dal dictionary dei padri
			if ([BatchesTextureDict count] == 0)//vuoto non c'è il backreference
			{
				for (id Key in Batches)
				{
					id	Obj	= [Batches objectForKey: Key];
					if ((void*)Obj == (void*)BatchesTextureDict)
					{
						[Batches removeObjectForKey: Key];
						break;
					}
				}
				if ([Batches count] == 0)
				{
					[Batches release];
					Batches	= nil;
				}
			}
		}
		[self dealloc];//[BatchesZDict removeObjectForKey: Key] non riesce a decrementare retainCount quindi non arriva mai a 0, devo deallocare esplicitamente
	}
	else	[super release];
}
#endif
@end

