//
//  SimpleCache.h
//  Prova
//
//  Created by mad4chip on 10/04/11.
//  Copyright 2011 Mad4chip . All rights reserved.
//

//semplice cache ad uso generico uso

@class SimpleCache;

@interface SimpleCachesHolder : NSObject
{
	NSMutableDictionary	*Caches;
}

+(id)sharedManager;
-(SimpleCache*)createCacheWithName: (NSString*)Name andAutoDelete: (bool)AutoDelete;
-(void)removeCacheName: (NSString*)Name;
-(void)removeCache: (SimpleCache*)Cache;
-(void)removeAllCaches;//rimuove solo le cache create senza autoDelete, queste si eliminano da sole eliminando chi le usa
@end

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface SimpleCache : NSObject
{
	NSMutableDictionary	*Cache;
	bool				autoDelete;
}
@property (readonly, nonatomic)	bool	autoDelete;

+(id)sharedManager;
+(id)cacheWithAutoDelete: (bool)autoDelete_;
-(id)initWithAutoDelete: (bool)autoDelete_;
-(void)setObject:(id)anObject forKey:(id)aKey;
-(id)objectForKey: (id)aKey;
-(void)removeObjectForKey: (id)aKey;
-(void)addReference;
-(void)removeReference;
-(void)removeUnusedData;
+(void)removeAllCaches;//rimuove solo le cache create senza autoDelete, queste si eliminano da sole eliminando chi le usa
@end
