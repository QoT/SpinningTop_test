//
//  ANCSprite.h
//  Prova
//
//  Created by mad4chip on 22/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "ANCAnimation.h"
#define ANIMATION_TAG		629462923

#define	NO_SPRITE_AUDIO				1
#define	NO_PARTICLE					2
#define	AUDIO_FADE_IN				4
#define	AUDIO_FADE_OUT				8
#define	RESTORE_ORIGINAL_FRAME		16
#define	DONOT_STOP_SIMILAR_ACTIONS	32

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark ANCSprite
@interface ANCSprite : CCSprite
{
	NSString		*Filename;
	CCSpriteFrame	*CurrentFrame;
	CGRect			OriginalRect;
}
@property (readonly,  nonatomic, retain)	NSString	*Filename;
@property (readwrite,  nonatomic)			CGRect		cropArea;
@property (readwrite,  nonatomic)			bool		cropped;

-(void)removeAnimationByName:(NSString*)name;
+(id)spriteWithFile:(NSString *)File;
+(id)spriteWithFile:(NSString *)File flags: (int)flags;
+(id)spriteWithSprite: (CCSprite*)Sprite;
-(id)initWithFile:(NSString *)File flags: (int)flags;
-(id)initWithSprite: (CCSprite*)Sprite;
-(void)updateImage: (NSString *)File;
-(void)updateImage: (NSString *)File flags: (int)flags;

-(bool)hasState: (NSString*) StateName;
-(ANCAnimation*)getState: (NSString*) StateName;
-(CCFiniteTimeAction*)getStateAction:(NSString*) StateName times: (int) Times;
-(CCFiniteTimeAction*)getStateAction:(NSString*) StateName times: (int) Times flags: (int)flags;
-(CCFiniteTimeAction*)runState:(NSString*) StateName times: (int) Times;
-(CCFiniteTimeAction*)runState:(NSString*) StateName times: (int) Times flags: (int)flags;
-(void)StopAnimation;

-(bool)addingChildTo:(CCNode*)Father z:(int)z tag:(int) aTag;
-(bool)removingChildFrom: (CCNode*)Father cleanup: (bool)doCleanup;
-(void)autoCenter;
@end



