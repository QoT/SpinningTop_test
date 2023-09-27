//
//  SimpleCache.m
//  Prova
//
//  Created by mad4chip on 10/04/11.
//  Copyright 2011 Mad4chip . All rights reserved.
//

#import "SimpleCache.h"

@implementation SimpleCachesHolder
static SimpleCachesHolder	*CachesHolder_		= nil;

+(id)sharedManager
{
	if (!CachesHolder_)
		CachesHolder_	= [[SimpleCachesHolder alloc] init];
	return CachesHolder_;
}

-(id)init
{
	if ((self = [super init]))
	{
		Caches	= [[NSMutableDictionary alloc] initWithCapacity: 0];
	}
	return self;
}

-(void)removeAllCaches
{
	NSArray		*CachesNames	= [Caches allKeys];
	for (int i = 0; i < [CachesNames count]; i++)
	{
		NSString	*Name	= [CachesNames objectAtIndex: i];
		SimpleCache	*Cache	= [Caches objectForKey: Name];
		if (!Cache.autoDelete)	[Caches removeObjectForKey: Name];
	}
}

-(void) dealloc
{
	[Caches release];
	[super dealloc];
}

-(SimpleCache*)createCacheWithName: (NSString*)Name andAutoDelete: (bool)AutoDelete
{
	SimpleCache	*Cache	= [Caches objectForKey: Name];
	if (!Cache)
	{
		Cache	= [SimpleCache cacheWithAutoDelete: AutoDelete];
		[Caches setObject: Cache forKey: Name];
	}
	else if (Cache.autoDelete) [Cache addReference];
	return Cache;
}

-(void)removeCacheName: (NSString*)Name
{
	SimpleCache	*Cache	= [Caches objectForKey: Name];
	if (Cache.autoDelete)
			[Cache removeReference];
	else	[Caches removeObjectForKey: Name];
}

-(void)removeCache: (SimpleCache*)Cache
{
	for (NSString *Key in Caches)
	{
		SimpleCache	*Elem	= [Caches objectForKey: Key];
		if ((void*)Cache == (void*)Elem)
			[Caches removeObjectForKey: Key];
	}
}
@end


//-------------------------------------------------------------------------------------------------------------------------------------------------
@implementation SimpleCache
@synthesize autoDelete;

+(id)sharedManager
{
	return [SimpleCachesHolder sharedManager];
}

+(void)removeAllCaches
{
	[[SimpleCachesHolder sharedManager] removeAllCaches];
}

+(id)cacheWithAutoDelete: (bool)autoDelete_
{
	return [[[self alloc] initWithAutoDelete: autoDelete_] autorelease];
}

-(id)initWithAutoDelete: (bool)autoDelete_
{
	if ((self = [super init]))
	{
		Cache		= [[NSMutableDictionary alloc] initWithCapacity: 0];
		autoDelete	= autoDelete_;
	}
	return self;
}

-(void) dealloc
{
	[Cache release];
	[super dealloc];
}

-(void)setObject:(id)anObject forKey:(id)aKey
{
	[Cache setObject: anObject forKey: aKey];
}
-(id)objectForKey: (id)aKey
{
	return [Cache objectForKey: aKey];
}

-(void)removeObjectForKey: (id)aKey
{
	[Cache removeObjectForKey: aKey];
}

-(oneway void)release
{
	SimpleCachesHolder	*Holder	= [SimpleCachesHolder sharedManager];
	if ((autoDelete) &&//la cache si auto eliminana
		(self.retainCount == 2))
	{
		autoDelete	= false;//evita la ricorsione poichè la riga successiva chiama nuovamente release
		[Holder removeCache: self];//non riuscirà a fa decrementare il retainCount per cui debbo deallocare esplicitamente
		[self dealloc];
	}
	else	[super release];
}

-(void)addReference
{
	[self retain];
}

-(void)removeReference
{
	[self release];
}

-(void)removeUnusedData
{
	NSArray	*Keys	= [Cache allKeys];
	for (NSString *Key in Keys)
	{
		id Elem	= [self objectForKey: Key];
		if ((Elem) && ([Elem retainCount] == 1))
			[self removeObjectForKey: Key];
	}
}
@end
