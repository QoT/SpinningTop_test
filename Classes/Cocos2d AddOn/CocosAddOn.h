
//
//  CocosAddOn.h
//  Prova
//
//  Created by mad4chip on 25/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCTextureCache.h"
#import "functions.h"

@interface CCArray (ANCAddOn)
-(void) swapObjectAtIndex: (NSUInteger)index1 andObjectAtIndex: (NSUInteger)index2;
-(void) sortUsingSelector: (SEL)comparator;
-(NSString*)description;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



@interface CCNode (CCNodeAddOn)
-(void)setColorAndOpacity: (ccColor4B)color;
-(ccColor4B)colorAndOpacity;
-(void) setTransform: (CGTransform)Transform;
-(CGTransform) getTransform;
-(void)scaleToSize: (CGSize)NewSize keepAspect: (bool)Aspect;
-(void)hideNode;
-(void)showNode;
-(CGPoint)convertNodeToParentSpace:(CGPoint)nodePoint;
-(CGPoint)convertParentToNodeSpace:(CGPoint)parentPoint;
-(CGPoint)convertParentToNodeSpaceAR:(CGPoint)worldPoint;
-(CGPoint)convertNodeToParentSpaceAR:(CGPoint)nodePoint;

-(CGRect)convertRectNodeToParentSpace: (CGRect) Rectangle;
-(CGRect)convertRectParentToNodeSpace: (CGRect) Rectangle;
-(CGRect)convertRectNodeToParentSpaceAR: (CGRect) Rectangle;
-(CGRect)convertRectParentToNodeSpaceAR: (CGRect) Rectangle;

-(CGRect)convertRectToWorldSpace: (CGRect) Rectangle;
-(CGRect)convertRectToNodeSpace: (CGRect) Rectangle;
-(CGRect)convertRectToWorldSpaceAR: (CGRect) Rectangle;
-(CGRect)convertRectToNodeSpaceAR: (CGRect) Rectangle;

-(CGFloat) width;
-(CGFloat) height;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface CCLayer (CCLayerAddOn)
-(void)disableMenus;
-(void)enableMenus;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

@interface CCSprite (CCSpriteAddOn)
-(void)setScaleAndFlip: (CGPoint)Value;
-(void)setScaleAndFlipX: (float)Value;
-(void)setScaleAndFlipY: (float)Value;
-(CGFloat) width;
-(CGFloat) untrimmedWidth;
-(CGFloat) height;
-(CGFloat) untrimmedHeight;
-(CGRect) TrimmedRect;
-(CGRect)untrimmedRect;
-(CGPoint) imageCenter;
-(CGPoint) imageCenterAR;
-(id) copyWithZone: (NSZone*) zone;
-(void)setUnflippedOffsetPositionFromCenter: (CGPoint)Offset;
-(CGPoint)unflippedOffsetPositionFromCenter;
/*
 -(void) setZOrder: (int) z;
 -(void)setScaleX:(float) sx;
 -(void)setScaleY:(float) sy;
 -(void)setScale:(float) s;
 -(float)scaleX;
 -(float)scaleY;
 -(float)scale;*/
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface CCSpriteFrame (FrameAddOn)
+(id)frameWithFile: (NSString*)File;
-(id)initWithFile: (NSString*)File;
-(BOOL)isEqual: (id)Object;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface CCAction (ActionAddOn)
-(NSString*)longDescription;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface CCRepeat (ActionAddOn)
-(NSString*)longDescription;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface CCRepeatForever (ActionAddOn)
-(NSString*)longDescription;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface CCSequence (ActionAddOn)
+(id)actionsWithCArray: (CCFiniteTimeAction**) ActionsArray;
-(NSString*)longDescription;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface CCSpawn (ActionAddOn)
+(id)actionsWithCArray: (CCFiniteTimeAction**) ActionsArray;
-(NSString*)longDescription;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface CCAnimation (longDescription)
-(NSString*)longDescription;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface CCAnimate (longDescription)
-(NSString*)longDescription;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface CCActionManager (removeAllActionByTag)
-(void) removeAllActionsByTag:(int) aTag target:(id)target;
-(NSArray*) getAllActionsByTag:(int)aTag target:(id)target;
-(NSArray*) getAllActionsForTarget:(id)target;
@end

@interface CCNode (removeAllActionByTag)
-(void) stopAllActionsByTag:(int)aTag;
-(NSArray*) getAllActionsByTag:(int)aTag;
-(NSArray*) getAllActions;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
typedef struct
{
	double total;
	double wired;
	double active;
	double inactive;
	double free;
} TMemInfo;

@interface CCDirector (sceneByTag)
+(TMemInfo)memInfo;
+(TMemInfo)memInfoMB;
-(NSString*)debugInfo;
-(id) runSceneFromStackByTag: (NSUInteger) aTag pushCurrent: (bool)Push;
-(NSUInteger)sceneStackCount;
-(NSMutableArray*)GetSceneStack; 
-(void)preloadScene: (CCScene*)Scene;
-(NSMutableArray*)scenesStack;
-(void)clearSceneStack;
-(bool)removeSceneFromStackByTag:(NSUInteger)aTag;
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

@interface CCSpriteBatchNode (CCSpriteBatchNodeAddOn)
-(CGRect) TrimmedRect;
@end
