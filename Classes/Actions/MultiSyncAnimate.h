//
//  MultiSyncAnimate.h
//  Prova
//
//  Created by mad4chip on 18/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//	Se l'animazione slitta in avanti ridurre WalkLength, 
//	se slitta all'indietro aumentarlo

#import "cocos2d.h"
#import "ANCSprite.h"

@interface MultiSyncAnimate : CCActionInterval
{
	NSMutableArray		*animations;
	NSMutableArray		*targets;
	NSMutableArray		*originalFrames;
	int					flags;
	CCAction			*fatherAction;
}
@property (readonly,nonatomic,assign)	NSMutableArray	*animations;
@property (readonly,nonatomic,assign)	NSMutableArray	*targets;
@property (readwrite,nonatomic,assign)	CCAction		*fatherAction;

//+(id) actionWithAnimation: (ANCAnimation*) Animation andTarget: (CCNode*)Target restoreOriginalFrame: (bool)restore;
+(id) actionWithAnimations: (NSArray*) Animation andTargets: (NSArray*)Targets flags: (int)flags;
//-(id) initWithAnimation: (ANCAnimation*) Animation andTarget: (CCNode*)Target restoreOriginalFrame: (bool)restore;
-(id) initWithAnimations: (NSArray*) Animation andTargets: (NSArray*)Targets flags: (int)flags;
//-(void) addAnimation: (ANCAnimation*) Animation andTarget: (CCNode*)Target;
//-(void) addAnimations: (NSArray*) Animations andTargets: (NSArray*)Targets;
-(void)removeAnimationsForTargets: (NSArray*)TargetsToRemove;
@end
