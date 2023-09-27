//
//  ObjectiveCAddOn.m
//  Prova
//
//  Created by mad4chip on 31/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectiveCAddOn.h"
#import "functions.h"

@implementation NSMutableArray (mutableArrayAddOn)
-(void)arrayUnique
{
	int	count	= [self count];
	if (count <= 2)	return;
	for (int i = count - 2; i >= 0; i--)
	{
		id	Obj	= [self objectAtIndex: i];
		for (int j = count - 1; j > i; j--)
			if ([Obj isEqual: [self objectAtIndex: j]])
			{
				[self removeObjectAtIndex: j];
				count--;
				break;
			}
	}
}

-(void)addObjects: (id)object, ...
{
	va_list args;
	va_start(args, object);
	
	while (object)
	{
		[self addObject: object];
		object = va_arg(args, id);
	}
	va_end(args);
}
@end

//---------------------------------------------------------------------------------------------------------------------------------
@implementation NSArray (arrayAddOn)
-(NSMutableArray*)arrayIntersect: (NSArray*)Array
{
	NSMutableArray	*Result	= [NSMutableArray arrayWithCapacity: 0];
	NSArray			*Array1;

	if ([self count] < [Array count])
	{
		Array1	= Array;
		Array	= self;
	}
	else	Array1	= self;

	for (id Element in Array)
		if ([Array1 indexOfObject: Element] != NSNotFound)
			[Result addObject: Element];
	return Result;
}

-(id)randomObject
{
	if ([self count] == 0) return nil;
	return [self objectAtIndex: randInRange(0, [self count])];
}
@end

//---------------------------------------------------------------------------------------------------------------------------------
@implementation NSDictionary (LocalizedSearch)
-(id)localizedObjectForKey:(id)aKey
{
	id			Ret;
	if ([aKey respondsToSelector: @selector(stringByAppendingFormat:)])
	{//la chiave è una stringa
		if ((Ret	= [self objectForKey: [((NSString*)aKey) stringByAppendingFormat: @"-%@-%@",PreferredLanguage, DeviceTypeName]]))
			return Ret;
		if ((Ret	= [self objectForKey: [((NSString*)aKey) stringByAppendingFormat: @"-%@-%@",DeviceTypeName, PreferredLanguage]]))
			return Ret;
		if ((Ret = [self objectForKey: [((NSString*)aKey) stringByAppendingFormat: @"-%@", DeviceTypeName]]))
			return Ret;
		if ((Ret = [self objectForKey: [((NSString*)aKey) stringByAppendingFormat: @"-%@", PreferredLanguage]]))
			return Ret;
	}
	return	[self objectForKey: aKey];
}
@end

//---------------------------------------------------------------------------------------------------------------------------------
#ifdef DEBUGALLOC
#import "JRSwizzle.h"
#import "ccCArray.h"

ccCArray	*ObjectArray		= nil;
ccCArray	*snapShots			= nil;
bool		queryInProgress		= false;
ccCArray	*SnapShotObj		= nil;
ccCArray	*BaseSnapShotObj	= nil;
int			ObjIndex;

@implementation NSObject (debugAlloc)
+(void)enableDebugAlloc
{
	NSAssert(ObjectArray == nil, @"DebugAlloc already inizialized");
	ObjectArray	= ccCArrayNew(1000);
	snapShots	= ccCArrayNew(1000);
	[self jr_swizzleClassMethod: @selector(alloc) withClassMethod: @selector(debugAlloc) error: nil];
	[self jr_swizzleMethod: @selector(dealloc) withMethod: @selector(debugDealloc) error: nil];
}

+(id)debugAlloc
{
	NSAssert(ObjectArray != nil, @"DebugAlloc NOT inizilized");
	id	Return	= [[self class] debugAlloc];
	if ((!queryInProgress) && (ccCArrayGetIndexOfValue(ObjectArray, Return) == NSNotFound))
		ccCArrayAppendValueWithResize(ObjectArray, Return);
	return Return;
}

-(void)debugDealloc
{
	NSAssert(ObjectArray != nil, @"DebugAlloc NOT inizilized");
	ccCArrayRemoveValue(ObjectArray, self);
	[self debugDealloc];
}

+(void)allocationSnapShot
{
	ccCArray	*snapShot	= ccCArrayNew(ObjectArray->num);
	ccCArrayAppendArray(snapShot, ObjectArray);
	ccCArrayAppendValueWithResize(snapShots, snapShot);
}

+(void)allocationReport: (NSInteger) SnapShot
{
	queryInProgress	= true;
	if (SnapShot < 0)		SnapShotObj		= ObjectArray;
	else					SnapShotObj		= (ccCArray*)ObjectArray->arr[SnapShot];
	BaseSnapShotObj	= nil;
	NSLog(@"Total objects allocated %d", SnapShotObj->num);
	ObjIndex	= -1;
	[NSObject allocationReportContinue];
}

+(void)allocationReport: (NSInteger) SnapShot base: (NSInteger) BaseSnapShot
{
	queryInProgress	= true;
	if (SnapShot < 0)		SnapShotObj		= ObjectArray;
	else					SnapShotObj		= (ccCArray*)snapShots->arr[SnapShot];
	if (BaseSnapShot < 0)	BaseSnapShotObj	= ObjectArray;
	else					BaseSnapShotObj	= (ccCArray*)snapShots->arr[BaseSnapShot];
	NSLog(@"Total objects allocated %d",		ObjectArray->num);
	NSLog(@"Total objects in snapshot %d",		SnapShotObj->num);
	NSLog(@"Total objects in base snapshot %d",BaseSnapShotObj->num);
	ObjIndex	= -1;
	[NSObject allocationReportContinue];
}

+(void)allocationReportContinue
{
	NSAssert(SnapShotObj, @"Please set report criteria first");
	queryInProgress	= true;
	int	n	= 0;
	while (true)
	{
		if (++ObjIndex >= SnapShotObj->num)
			break;
		NSString	*Description;
		id			Obj			= SnapShotObj->arr[ObjIndex];
		if ((BaseSnapShotObj != nil) && (ccCArrayGetIndexOfValue(BaseSnapShotObj, Obj) != NSNotFound))
			continue;

		NSString	*ClassName	= NSStringFromClass([Obj class]);		
		if (([ClassName rangeOfString: @"NSPlaceholder"].location == NSNotFound) && ([Obj respondsToSelector: @selector(description)]))
				Description	= [NSString stringWithFormat: @"%@ %@", ClassName, [Obj description]];
		else	Description	= ClassName;
		NSLog(@"%u: %08X %@", n++, (unsigned int)Obj, Description);
	}
	NSLog(@"Report END");
	SnapShotObj		= nil;
	queryInProgress	= false;	
}
@end
#endif