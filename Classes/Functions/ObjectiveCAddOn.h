//
//  ObjectiveCAddOn.h
//  Prova
//
//  Created by mad4chip on 31/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@interface NSMutableArray (mutableArrayAddOn)
-(void)arrayUnique;
-(void)addObjects: (id)object, ...;
@end

//---------------------------------------------------------------------------------------------------------------------------------
@interface NSArray (arrayAddOn)
-(NSMutableArray*)arrayIntersect: (NSArray*)Array;
-(id)randomObject;
@end

//---------------------------------------------------------------------------------------------------------------------------------
@interface NSDictionary (LocalizedSearch)
-(id)localizedObjectForKey:(id)aKey;
@end

//---------------------------------------------------------------------------------------------------------------------------------
#if COCOS2D_DEBUG >= 1
@interface NSObject (debugAlloc)
+(void)enableDebugAlloc;
+(id)debugAlloc;
-(void)debugDealloc;
+(void)allocationReportContinue;
+(void)allocationSnapShot;
+(void)allocationReport: (NSInteger) SnapShot;
+(void)allocationReport: (NSInteger) SnapShot base: (NSInteger) BaseSnapShot;
@end
#endif