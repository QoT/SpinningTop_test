//
//  MimiTop.h
//  SpinningTop
//
//  Created by mad4chip on 26/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "DrawableSprite.h"
#import "ANCParticleSystemDescriptor.h"

typedef enum
{
	MIMITOP_TOUCH_BEGIN,
	MIMITOP_TOUCH_MOVED,
	MIMITOP_TOUCH_END,
	MIMITOP_TOUCH_CANCELLED,

	MIMITOP_FALLTOUCH_BEGIN,
	MIMITOP_FALLTOUCH_MOVED,
	MIMITOP_FALLTOUCH_END,
	MIMITOP_FALLTOUCH_CANCELLED,
	
	MIMITOP_EXIT_MOVE_RECT
} MimiEvents;

@protocol MimiTopUpdate <NSObject>
-(void)topUpdateEvent: (MimiEvents)Event position: (CGPoint)position;
@end

@interface MimiTop : CCNode <CCStandardTouchDelegate>
{
	UITouch				*Touch;
	UITouch				*FallTouch;
	CCSprite			*ForegroundImage_;
	DrawableSprite		*PaperSheet_;
	ParticleSystemDescriptor	*ParticleSystemDescriptors[4];
	CCNode				*AttachedNode_;
	CCNode				*FallNode_;
	CCNode				*MovePath;
	CGRect				StartRect;
	CGRect				MoveRect;

	NSInvocation		*OnUpdate;

	CGPoint				TopPosition;
	CGPoint				FallPosition;
	float				FallDistance;
	float				FallDistanceTol;
	bool				CheckPath;
	bool				OutOfTrack;
	bool				Registered;
	bool				NegatePath;
	bool				Enable_;		//abilita la tracciatura
	bool				EventsEnable_;	//abilita l'invio degli eventi, EventsEnable_ = false la trottola viene riportata come non presente
	bool				DrawEnable_;	//abilitga la scrittura ed i particle, la posizione viene tracciata, i nodi seguono la trottola
	bool				IgnoreOnFall;	//ignorata una volta che è caduta
	bool				HasFall;		//è caduta almeno una volta da quando ha toccato
}

@property (nonatomic, readwrite, assign)	DrawableSprite	*PaperSheet;
@property (nonatomic, readwrite, assign)	CCNode			*AttachedNode;
@property (nonatomic, readwrite, assign)	CCNode			*FallNode;
@property (nonatomic, readwrite, assign)	CCSprite		*ForegroundImage;
@property (nonatomic, readonly)				CGPoint			TopPosition;
@property (nonatomic, readonly)				CGPoint			FallPosition;
@property (nonatomic, readwrite)			CGRect			StartRect;
@property (nonatomic, readwrite)			CGRect			MoveRect;
@property (nonatomic, readwrite,assign)		CCNode			*MovePath;
@property (nonatomic, readonly)				bool			TopPresent;
@property (nonatomic, readonly)				bool			Fallen;
@property (nonatomic, readwrite)			bool			NegatePath;
@property (nonatomic, readwrite)			bool			Enable;//registra/deregistra col touch dispatcher
@property (nonatomic, readonly)				bool			EventsEnable;
@property (nonatomic, readwrite)			bool			DrawEnable;
@property (nonatomic, readwrite)			bool			IgnoreOnFall;
@property (nonatomic, readwrite)			float			FallDistance;
@property (nonatomic, readwrite)			float			FallDistanceTol;


+(id)newTop;
+(id)newTopFromFile: (NSString*)FileName;
+(id)newTopFromDictionary: (NSDictionary*)DescriptionData;

-(void)useMovingParticleSystemDescriptor:		(ParticleSystemDescriptor*)Descriptor;
-(void)useTouchBeginParticleSystemDescriptor:	(ParticleSystemDescriptor*)Descriptor;
-(void)useTouchEndParticleSystemDescriptor:		(ParticleSystemDescriptor*)Descriptor;
-(void)useFallParticleSystemDescriptor:			(ParticleSystemDescriptor*)Descriptor;

-(void)registerOnUpdateDelegate: (id<MimiTopUpdate>)target;
-(void)sendEvent: (MimiEvents)Event;

-(void)forceTouchEnd;
@end
