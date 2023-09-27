//
//  MimiTop.m
//  SpinningTop
//
//  Created by mad4chip on 26/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define MOVING_PARTICLE_INDEX	0
#define BEGIN_PARTICLE_INDEX	1
#define END_PARTICLE_INDEX		2
#define FALL_PARTICLE_INDEX		3

#define MovingParticle	ParticleSystemDescriptors[MOVING_PARTICLE_INDEX]
#define BeginParticle	ParticleSystemDescriptors[BEGIN_PARTICLE_INDEX]
#define EndParticle		ParticleSystemDescriptors[END_PARTICLE_INDEX]
#define FallParticle	ParticleSystemDescriptors[FALL_PARTICLE_INDEX]

#import "MimiTop.h"
#import "functions.h"
#import "ANCParticleSystemManager.h"
#import "ANCSprite.h"
#import "ColoredSquareSprite.h"

//z levels
#define	FOREGROUND_Z	-2//FOREGROUND_Z deve essere < di PAPERSHEET_Z
#define	PAPERSHEET_Z	-1
//MovePath
#define	ATTACHED_NODE_Z	1
#define	FALL_NODE_Z		2


@implementation MimiTop
@synthesize FallDistance;
@synthesize FallDistanceTol;
@synthesize TopPosition;
@synthesize FallPosition;
@synthesize IgnoreOnFall;
@synthesize NegatePath;
@synthesize StartRect;
-(void)setStartRect:(CGRect)newStartRect
{
	StartRect			= newStartRect;
/*
	CCNode	*Square		= [ColoredSquareSprite squareWithColor: ccc4(0, 255, 0, 128) size: StartRect.size];
	Square.position		= StartRect.origin;
	Square.anchorPoint	= CGPointZero;
	[self addChild: Square z: 100];
*/
}

@synthesize MoveRect;
-(void)setMoveRect: (CGRect)Rect
{
	MoveRect	= Rect;
	StartRect	= Rect;
/*
	CCNode	*Square		= [ColoredSquareSprite squareWithColor: ccc4(255, 0, 0, 128) size: MoveRect.size];
	Square.position		= MoveRect.origin;
	Square.anchorPoint	= CGPointZero;
	[self addChild: Square z: 100];
*/
}

@synthesize MovePath;
-(void)setMovePath: (CCNode *)Node
{
	NSAssert(Node.parent == nil, @"Move path must be a child of mine");
	[MovePath release];
	MovePath	= nil;
	[self unscheduleUpdate];
	if (Node)
	{
		MovePath	= [Node retain];
		MovePath.parent	= self;
		MoveRect	= [MovePath boundingBox];
		[self scheduleUpdate];
	}
}

@synthesize AttachedNode	= AttachedNode_;
-(void) setAttachedNode:(CCNode *)Node
{
	if ((AttachedNode_.parent == self) ||
		(([AttachedNode_ isKindOfClass: [ANCSprite class]]) && (AttachedNode_.parent.parent == self)))
			[self removeChild: AttachedNode_ cleanup: true];
	[AttachedNode_ release];
	if (!Node)			Node	= [CCNode node];
	if (!Node.parent)	[self addChild: Node z: ATTACHED_NODE_Z];
	AttachedNode_				= [Node retain];
	if (Touch)	AttachedNode_.visible		= true;
	else		AttachedNode_.visible		= false;
}

@synthesize FallNode	= FallNode_;
-(void) setFallNode:(CCNode *)Node
{
	if ((FallNode_.parent == self) ||
		(([FallNode_ isKindOfClass: [ANCSprite class]]) && (FallNode_.parent.parent == self)))
			[self removeChild: FallNode_ cleanup: true];
	[FallNode_ release];
	if (!Node)			Node	= [CCNode node];
	if (!Node.parent)	[self addChild: Node z: FALL_NODE_Z];
	FallNode_			= [Node retain];
	if (FallTouch)	FallNode_.visible	= true;
	else			FallNode_.visible	= false;
}

@synthesize EventsEnable	= EventsEnable_;
-(void)setEventsEnable:(bool)newEnable
{
	if (EventsEnable_ != newEnable)
	{
		EventsEnable_	= newEnable;
		if ((!newEnable) && (self.TopPresent))
			[self sendEvent: MIMITOP_TOUCH_END];//manda un evento fasullo per mantenere la coerenza touch_begin touch_end
	}
}

@synthesize Enable	= Enable_;
-(void)setEnable:(bool)newEnable
{
	if (Enable_ != newEnable)
	{
		if ((Enable_) && (Touch))
			[self touchEnd: MIMITOP_TOUCH_END];
		Enable_	= newEnable;
	}

	if (newEnable)
	{
		if (!Registered)	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate: self priority: 1];
	}
	else
	{
		if (Registered)	[[CCTouchDispatcher sharedDispatcher] removeDelegate: self];
		[MovingParticle	killSystem];
		[BeginParticle	killSystem];
		[EndParticle	killSystem];
		[FallParticle	killSystem];
	}
	Registered	= newEnable;
}

@synthesize DrawEnable	= DrawEnable_;
-(void)setDrawEnable:(bool)newEnable
{
	if (DrawEnable_ != newEnable)
	{
		if (newEnable)
		{
			if (Touch)
			{
				[PaperSheet_ ccTouchBegan: Touch withEvent: nil];
				[MovingParticle	getParticleSystemForNode: AttachedNode_];
				[BeginParticle	getParticleSystemForNode: AttachedNode_];
			}
		}
		else if (Touch)
		{
			[PaperSheet_ ccTouchEnded: Touch withEvent: nil];
			[FallParticle	killSystem];
			[MovingParticle	killSystem];
			[EndParticle	getParticleSystemForNode: AttachedNode_];
		}
		DrawEnable_	= newEnable;
	}
}

@synthesize PaperSheet	= PaperSheet_;
-(void)setPaperSheet:(DrawableSprite *)newSheet
{
	if (PaperSheet_)
	{
		[self removeChild: PaperSheet_ cleanup: true];
		PaperSheet_	= nil;
	}
	if (newSheet)
	{
		PaperSheet_					= newSheet;
		PaperSheet_.position		= CGPointZero;
		PaperSheet_.anchorPoint		= CGPointZero;
		PaperSheet_.touchEnabled	= false;//gestisco i tocchi in questa classe e poi li rigiro
		[self addChild: PaperSheet_ z: PAPERSHEET_Z];//PaperSheet stà sopra al foreground perchè in realtà il foreground è sempre stampato e lo sfondo che viene stampato in parte
	}
}

-(bool)Fallen
{
	if (!EventsEnable_)	return false;
	if (IgnoreOnFall)	return HasFall;
	else				return (FallTouch != nil);
}

-(bool)TopPresent
{
	if (!EventsEnable_)			return false;
	if (IgnoreOnFall & HasFall)	return false;
	else						return (Touch != nil);
}

+(id)newTop
{
	return [[[self alloc] init] autorelease];
}

+(id)newTopFromFile: (NSString*)FileName
{
	FileName	= [CCFileUtils fullPathFromRelativePath:FileName];
	return [self newTopFromDictionary: [NSDictionary dictionaryWithContentsOfFile: FileName]];
}

+(id)newTopFromDictionary: (NSDictionary*)DescriptionData
{
	MimiTop	*Top	= [self newTop];
	NSString			*BackGroungImage	= nil;
	NSMutableDictionary	*Data;
	if ((Data = [DescriptionData objectForKey: @"movingparticle"]))		[Top useMovingParticleSystemDescriptor:		[ParticleSystemDescriptor particleSystemDescriptorFromDictionary: Data]];
	if ((Data = [DescriptionData objectForKey: @"touchbeginparticle"]))	[Top useTouchBeginParticleSystemDescriptor:	[ParticleSystemDescriptor particleSystemDescriptorFromDictionary: Data]];
	if ((Data = [DescriptionData objectForKey: @"touchendparticle"]))	[Top useTouchEndParticleSystemDescriptor:	[ParticleSystemDescriptor particleSystemDescriptorFromDictionary: Data]];
	if ((Data = [DescriptionData objectForKey: @"fallparticle"]))		[Top useFallParticleSystemDescriptor:		[ParticleSystemDescriptor particleSystemDescriptorFromDictionary: Data]];
	NSString		*String;
	if ((String = [DescriptionData objectForKey: @"attachedsprite"]))	Top.AttachedNode	= [ANCSprite spriteWithFile: String];
	if ((String = [DescriptionData objectForKey: @"fallsprite"]))		Top.FallNode		= [ANCSprite spriteWithFile: String];
	if ((String = [DescriptionData objectForKey: @"foregroundimage"]))	Top.ForegroundImage	= [ANCSprite spriteWithFile: String];
	if ((String = [DescriptionData objectForKey: @"backgroundimage"]))	BackGroungImage		= String;

	if ((String = [DescriptionData objectForKey: @"moverect"]))			Top.MoveRect		= CGRectFromString(String);//setta anche StartRect
	if ((String = [DescriptionData objectForKey: @"startrect"]))		Top.StartRect		= CGRectFromString(String);
	if ((String = [DescriptionData objectForKey: @"movepath"]))
	{
		Top.MovePath		= [ANCSprite spriteWithFile: String];
		if ((String = [DescriptionData objectForKey: @"negatepath"]))	Top.NegatePath		= [String boolValue];
	}
	if ((String = [DescriptionData objectForKey: @"falldistance"]))		Top.FallDistance	= [String floatValue];
	if ((String = [DescriptionData objectForKey: @"falldistancetol"]))	Top.FallDistanceTol	= [String floatValue];
	if ((String = [DescriptionData objectForKey: @"drawenable"]))		Top.DrawEnable		= [String boolValue];
	if ((String = [DescriptionData objectForKey: @"ignoreonfall"]))		Top.IgnoreOnFall	= [String boolValue];
	if ((String = [DescriptionData objectForKey: @"enable"]))			Top.Enable			= [String boolValue];

	if ((Data = [DescriptionData objectForKey: @"papersheet"]))
	{
		if (BackGroungImage)//permette di specificare backgroundimage e foregroundimage nello stesso punto
		{
			Data	= [[Data mutableCopy] autorelease];
			[Data setObject: BackGroungImage forKey: @"backgroundimage"];
		}
		else if (([Data objectForKey: @"size"] == nil) &&
				 ([Data objectForKey: @"backgroundimage"] == nil))
		{
			Data	= [[Data mutableCopy] autorelease];
			[Data setObject: [NSString stringWithFormat: @"{%f,%f}", Top.MoveRect.size.width, Top.MoveRect.size.height] forKey: @"size"];
		}
		Top.PaperSheet				= [DrawableSprite newDrawableSpriteWithDictionary: Data];
		Top.PaperSheet.position		= Top.MoveRect.origin;
		Top.PaperSheet.anchorPoint	= CGPointZero;
	}
	return Top;
}

-(id)init
{
	if ((self = [super init]))
	{
		ForegroundImage_		= nil;
		PaperSheet_			= nil;
		MovingParticle		= nil;
		BeginParticle		= nil;
		EndParticle			= nil;
		FallParticle		= nil;
		AttachedNode_		= nil;
		self.AttachedNode	= nil;//crea il CCNode vuoto
		FallNode_			= nil;
		self.FallNode		= nil;//crea il CCNode vuoto
		OnUpdate			= nil;
		TopPosition			= CGPointZero;
		Touch				= nil;
		FallTouch			= nil;
		HasFall				= false;
		FallDistance		= 0;
		FallDistanceTol		= 0.1f;
		IgnoreOnFall		= true;
		EventsEnable_		= true;
		DrawEnable_			= false;
		self.DrawEnable		= true;//genera l'evento di enable
		Registered			= false;
		Enable_				= true;
		NegatePath			= false;
		MovePath			= nil;
		self.MoveRect		= CGRectMakeOriginSize(CGPointZero, ScreenSize);//imposta StartRect
		ParticleSystemDescriptors[0]	= nil;
		ParticleSystemDescriptors[1]	= nil;
		ParticleSystemDescriptors[2]	= nil;
		ParticleSystemDescriptors[3]	= nil;
	}
	return self;
}

-(void)onEnter
{
	self.Enable	= Enable_;//registra il delegato se necessario
	[super onEnter];
}

-(void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate: self];
	[super onExit];
}

@synthesize ForegroundImage	= ForegroundImage_;
-(void)setForegroundImage: (CCSprite*)Image
{
	if (ForegroundImage_)
	{
		[self removeChild: ForegroundImage_ cleanup: true];
		ForegroundImage_	= nil;
	}

	if (Image)
	{
		ForegroundImage_			= Image;
		ForegroundImage_.position		= CGPointZero;
		ForegroundImage_.anchorPoint	= CGPointZero;
		[self addChild: ForegroundImage_ z: FOREGROUND_Z];
	}
}

//internal use only
-(void)useParticleSystemDescriptor: (ParticleSystemDescriptor*)Descriptor index: (int)index
{
	[ParticleSystemDescriptors[index] release];
	ParticleSystemDescriptors[index]					= nil;
	if (Descriptor)	ParticleSystemDescriptors[index]	= [Descriptor retain];
}

-(void)useMovingParticleSystemDescriptor:		(ParticleSystemDescriptor*)Descriptor	{	[self useParticleSystemDescriptor: Descriptor index: MOVING_PARTICLE_INDEX];	}
-(void)useTouchBeginParticleSystemDescriptor:	(ParticleSystemDescriptor*)Descriptor	{	[self useParticleSystemDescriptor: Descriptor index: BEGIN_PARTICLE_INDEX];		}
-(void)useTouchEndParticleSystemDescriptor:		(ParticleSystemDescriptor*)Descriptor	{	[self useParticleSystemDescriptor: Descriptor index: END_PARTICLE_INDEX];		}
-(void)useFallParticleSystemDescriptor:			(ParticleSystemDescriptor*)Descriptor	{	[self useParticleSystemDescriptor: Descriptor index: FALL_PARTICLE_INDEX];		}

-(void)registerOnUpdateDelegate: (id<MimiTopUpdate>)target
{
	[OnUpdate release];
	if (target)
	{
		OnUpdate = [NSInvocation invocationWithMethodSignature: [(NSObject*)target methodSignatureForSelector: @selector(topUpdateEvent:position:)]];
		[OnUpdate setTarget: target];
		[OnUpdate setSelector: @selector(topUpdateEvent:position:)];
		[OnUpdate setArgument: &TopPosition atIndex: 3];
		[OnUpdate retain];
	}
	else OnUpdate	= nil;
}

-(void)sendEvent: (MimiEvents)Event
{
	if (!EventsEnable_)	return;
	[OnUpdate setArgument: &Event atIndex: 2];
	[OnUpdate invoke];
}

//---------------------
/*
typedef enum {
	UITouchPhaseBegan,
	UITouchPhaseMoved,
	UITouchPhaseStationary,
	UITouchPhaseEnded,
	UITouchPhaseCancelled,
} UITouchPhase;
*/

//internal use only
-(void)touchBegin
{
	AttachedNode_.position	= TopPosition;
	AttachedNode_.visible	= true;
	FallNode_.visible		= false;

	if (!CGRectContainsPoint(MoveRect, TopPosition))
		OutOfTrack	= true;

	[self sendEvent: MIMITOP_TOUCH_BEGIN];

	if (DrawEnable_)
	{
		[PaperSheet_ ccTouchBegan: Touch withEvent: nil];
		[MovingParticle	getParticleSystemForNode: AttachedNode_];
		[BeginParticle	getParticleSystemForNode: AttachedNode_];
	}
}

//internal use only
-(void)fall
{
	HasFall				= true;
	FallNode_.position	= FallPosition;
	FallNode_.visible	= true;
	
	[self sendEvent: MIMITOP_FALLTOUCH_BEGIN];
	
	if (DrawEnable_)	[FallParticle	getParticleSystemForNode: FallNode_];
}

//internal use only
-(void)touchMoved
{
	AttachedNode_.position	= TopPosition;

	if (!CGRectContainsPoint(MoveRect, TopPosition))
		OutOfTrack	= true;

	[self sendEvent: MIMITOP_TOUCH_MOVED];
	if (DrawEnable_) [PaperSheet_ ccTouchMoved: Touch withEvent: nil];
}

//internal use only
-(void)fallTouchMoved
{
	FallNode_.position	= FallPosition;
	[self sendEvent: MIMITOP_FALLTOUCH_MOVED];
}

//internal use only
-(void)touchEnd: (MimiEvents)Event
{
	FallTouch				= nil;
	HasFall					= false;
	AttachedNode_.visible	= false;
	FallNode_.visible		= false;

	[self sendEvent: (Touch.phase == UITouchPhaseEnded) ? MIMITOP_TOUCH_END : MIMITOP_TOUCH_CANCELLED];

	if (DrawEnable_)
	{
		[PaperSheet_ ccTouchEnded: Touch withEvent: nil];
		[FallParticle	killSystem];
		[MovingParticle	killSystem];
		[EndParticle	getParticleSystemForNode: AttachedNode_];
	}
	Touch					= nil;
}

-(void)forceTouchEnd
{
	[self touchEnd: MIMITOP_TOUCH_END];//simula un touch end
}

//internal use only
-(void)fallTouchEnd: (MimiEvents)Event
{
	Touch			= nil;
	FallTouch		= nil;
	FallNode_.visible		= false;
	[self sendEvent: (Touch.phase == UITouchPhaseEnded) ? MIMITOP_TOUCH_END : MIMITOP_TOUCH_CANCELLED];
	if (DrawEnable_)	[FallParticle killSystem];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	bool	TouchBegin	= false;
	bool	Fall		= false;

	if (!Touch)
	{
		for (UITouch* SingleTouch in touches)
		{
			if (SingleTouch.phase != UITouchPhaseBegan)
				continue;

			CGPoint	TempPosition	= [SingleTouch locationInView: [SingleTouch view]];
			TempPosition			= [[CCDirector sharedDirector] convertToGL: TempPosition];
			if (!CGRectContainsPoint(StartRect, TempPosition))
				continue;
			Touch		= SingleTouch;
			TopPosition	= TempPosition;
			TouchBegin	= true;
			CheckPath	= true;
			break;
		}
	}
	else if ((FallDistance > 0) && (!FallTouch))
	{
		for (UITouch* SingleTouch in touches)
		{
			if (SingleTouch.phase == UITouchPhaseBegan)
			{
				FallPosition	= [SingleTouch locationInView: [SingleTouch view]];
				FallPosition	= [[CCDirector sharedDirector] convertToGL: FallPosition];
				if ((CGPointDistance(TopPosition, FallPosition) < FallDistance * (1 + FallDistanceTol)) &&
					(CGPointDistance(TopPosition, FallPosition) > FallDistance * (1 - FallDistanceTol)))
				{
					FallTouch	= SingleTouch;
					Fall		= true;
				}
			}
		}
	}
//genero alla fine gli eventi
	if (TouchBegin)	[self touchBegin];
	if (Fall)		[self fall];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!Touch)	return;
	bool	TouchMoved		= false;
	bool	FallTouchMoved	= false;

	if (Touch.phase == UITouchPhaseMoved)
	{
		TopPosition		= [Touch locationInView: [Touch view]];
		TopPosition		= [[CCDirector sharedDirector] convertToGL: TopPosition];

		TouchMoved	= true;
	}

	if ((FallTouch) && (FallTouch.phase == UITouchPhaseMoved))
	{
		FallPosition	= [FallTouch locationInView: [FallTouch view]];
		FallPosition	= [[CCDirector sharedDirector] convertToGL: FallPosition];

		FallTouchMoved	= true;
	}

	if ((Touch) && (FallTouch))
	{
		CGPoint	PreviousTouch		= [[CCDirector sharedDirector] convertToGL: [Touch		previousLocationInView: [Touch view]]];
		CGPoint	PreviousFallTouch	= [[CCDirector sharedDirector] convertToGL: [FallTouch	previousLocationInView: [FallTouch view]]];
		
		if ((CGPointDistanceSquare(PreviousTouch,	  TopPosition)  > FallDistance*FallDistance/2) &&
			(CGPointDistanceSquare(PreviousFallTouch, FallPosition) > FallDistance*FallDistance/2))
		{//inversione dei tocchi
			UITouch	*temp	= Touch;
			Touch		= FallTouch;
			FallTouch	= temp;

			PreviousTouch	= TopPosition;
			TopPosition		= FallPosition;
			FallPosition	= PreviousTouch;

			bool btemp		= FallTouchMoved;
			FallTouchMoved	= TouchMoved;
			TouchMoved		= btemp;
		}
	}

	if (TouchMoved)
	{
		[self touchMoved];
		CheckPath	= true;
	}
	if (FallTouchMoved)	[self fallTouchMoved];
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!Touch)	return;
	bool	TouchEnd		= false;
	bool	FallTouchEnd	= false;

	if ((Touch.phase == UITouchPhaseEnded) ||
		(Touch.phase == UITouchPhaseCancelled))
	{
		TopPosition		= [Touch locationInView: [Touch view]];
		TopPosition		= [[CCDirector sharedDirector] convertToGL: TopPosition];
		TouchEnd		= true;
	}
	else if ((FallTouch) &&
		((FallTouch.phase == UITouchPhaseEnded) ||
		 (FallTouch.phase == UITouchPhaseCancelled)))
	{
		FallPosition	= [FallTouch locationInView: [FallTouch view]];
		FallPosition	= [[CCDirector sharedDirector] convertToGL: FallPosition];
		FallTouchEnd	= true;
	}

	if (FallTouchEnd)	[self fallTouchEnd: (FallTouch.phase == UITouchPhaseEnded)	? MIMITOP_FALLTOUCH_END : MIMITOP_FALLTOUCH_CANCELLED];
	if (TouchEnd)		[self touchEnd:		(Touch.phase == UITouchPhaseEnded)		? MIMITOP_TOUCH_END		: MIMITOP_TOUCH_CANCELLED];
}

-(void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self ccTouchesEnded: touches withEvent: event];
}

-(void)update: (float)dt
{
	if (OutOfTrack)
	{
		[self sendEvent: MIMITOP_EXIT_MOVE_RECT];
		OutOfTrack	= false;
	}
}

-(void)draw
{
	[super draw];
	if ((MovePath) && (CheckPath) && (!OutOfTrack))
	{
		Byte	Before[4];
		Byte	After[4];
		CGPoint	RealPosition	= [self convertToWorldSpace: TopPosition];
		glReadPixels(RealPosition.x, RealPosition.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, &Before);
		[MovePath visit];
		glReadPixels(RealPosition.x, RealPosition.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, &After);
		if (!NegatePath)
		{
			if ((Before[0] == After[0]) &&
				(Before[1] == After[1]) &&
				(Before[2] == After[2]) &&
				(Before[3] == After[3]))
					OutOfTrack	= true;
		}
		else
		{
			if ((Before[0] != After[0]) ||
				(Before[1] != After[1]) ||
				(Before[2] != After[2]) ||
				(Before[3] != After[3]))
					OutOfTrack	= true;
		}
	}
	else [MovePath visit];
	CheckPath	= false;//azzero qui il flag perchè è la stata l'ultima cosa effettuata
}

-(void)dealloc
{
//	[PaperSheet_		release]; non riceve retain
//	[Touch				release]; non riceve retain
//	[FallTouch			release]; non riceve retain
//	[PaperSheet			release]; non riceve retain
//	[Particle			release]; non riceve retain	
//	[ForegroundImage	release]; non riceve retain
	[ParticleSystemDescriptors[0]	release];
	[ParticleSystemDescriptors[1]	release];
	[ParticleSystemDescriptors[2]	release];
	[ParticleSystemDescriptors[3]	release];
	[AttachedNode_		release];
	[FallNode_			release];
	[MovePath			release];
	[OnUpdate			release];
	[super dealloc];
}
@end
