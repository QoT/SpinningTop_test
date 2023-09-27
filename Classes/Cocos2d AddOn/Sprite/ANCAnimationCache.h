//
//  ANCAnimationCache.h
//  Prova
//
//  Created by mad4chip on 26/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "ANCSprite.h"
#import "ANCAnimation.h"

@interface ANCAnimationCache : NSObject
{
	NSMutableDictionary	*animations_;
	NSLock				*Lock;
	bool				cleanInProgress;
	int					cleanLockOut;
}
@property (readonly, nonatomic)		NSMutableDictionary *animations;
@property (readwrite, nonatomic)	bool				cleanInProgress;

+(ANCAnimationCache *)sharedAnimationCache;
-(NSString*)description;
-(void)removeAllAnimations;
-(void)lockCache;
-(void)unlockCache;
-(void) addAnimation:(ANCAnimation*)animation name:(NSString*)name;
-(void) addAnimation:(ANCAnimation*)animation name:(NSString*)name forObj: (NSString*)objName;
-(void) removeAnimationByName:(NSString*)name forTarget: (ANCSprite*)Target;
-(bool) animationExist:(NSString*)name forObj: (NSString*)objName;
-(ANCAnimation*) animationByName:(NSString*)name;
-(ANCAnimation*) animationByName:(NSString*)name forObj: (NSString*)objName;
-(ANCAnimation*) animationByName:(NSString*)name forTarget: (ANCSprite*)Target;
-(void)loadAtlasFile:(NSString *)File;
-(bool) loadAnimationsIntoTarget: (ANCSprite*)Target;
-(void)lockAnimationsForObj: (NSString*)objName;
-(void)unlockAnimationsForObj: (NSString*)objName;
-(void)removeUnusedAnimations;
-(void)removeUnusedAnimationsAsync;
-(void)__removeUnusedAnimationsAsync:(id)Unused;
-(void)lockOutClean;
-(void)unlockClean;
@end
