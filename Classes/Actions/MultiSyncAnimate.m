//
//  WalkAnimate.m
//  Prova
//
//  Created by mad4chip on 18/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MultiSyncAnimate.h"
#import "CocosAddOn.h"

@implementation MultiSyncAnimate
@synthesize animations;
@synthesize targets;
@synthesize fatherAction;
+(id) actionWithAnimations: (NSArray*) Animation andTargets: (NSArray*)Targets flags: (int)flags
{
	return [[[self alloc] initWithAnimations: Animation andTargets: Targets flags: flags] autorelease];
}

-(id) initWithAnimations: (NSArray*) Animations andTargets: (NSArray*)Targets flags: (int)flags_
{
	NSAssert(Animations,	@"Animation must be not nil");
	NSAssert(Targets,		@"Targets must be not nil");

	CCAnimation *Animation		= [Animations lastObject];
	ccTime		ActionDuration	= Animation.delay * [Animation.frames count];

	for (CCAnimation *Animation in Animations)
	{
		NSAssert([Animation isKindOfClass: [CCAnimation class]], @"MultiSyncAnimate support only CCAnimation object");
		NSAssert(Animation.delay * [Animation.frames count] == ActionDuration, @"SyncAnimate needs all animations to have the same duration");
	}
	if ((self = [super initWithDuration: ActionDuration]))
	{
		NSAssert([Animations count] == [Targets count], @"MultiSyncAnimate: please provide an equal number of animations and targets");
		animations				= [Animations mutableCopy];//hanno già retain
		targets					= [Targets mutableCopy];//hanno già retain
		originalFrames			= nil;
		flags					= flags_;
		fatherAction			= nil;
	}
	return self;
}

-(void)removeAnimationsForTargets: (NSArray*)TargetsToRemove
{
	for (int i = 0; i < [TargetsToRemove count]; i++)
	{
		int	Index	= [targets indexOfObject: [TargetsToRemove objectAtIndex: i]];
		if (Index != NSNotFound)
		{
			[targets	removeObjectAtIndex: Index];
			[animations	removeObjectAtIndex: Index];
		}
	}
	if ([animations count] == 0)
	{
		[[CCActionManager sharedManager] removeAction: fatherAction forTarget: target_];
		fatherAction	= nil;
		[[CCActionManager sharedManager] removeAction: self];
	}
}

-(void) startWithTarget:(id)aTarget
{
	NSInteger	oldTag;
	NSInteger	oldFatherTag;

	for (CCAnimation *Animation in animations)
		NSAssert([Animation isKindOfClass: [CCAnimation class]], @"MultiSyncAnimate support only CCAnimation object");
	[originalFrames release];
	originalFrames	= nil;
	if (flags & RESTORE_ORIGINAL_FRAME)
		originalFrames	= [[NSMutableArray arrayWithCapacity: [targets count]] retain];
	if (tag_ == kCCActionTagInvalid)
		stopSimilarAction		= false;	
	if (stopSimilarAction)
	{
		oldTag				= tag_;
		oldFatherTag		= fatherAction.tag;
		tag_				= kCCActionTagInvalid;
		fatherAction.tag	= kCCActionTagInvalid;
	}
	
	for (CCSprite *Sprite in targets)
	{//memorizza i frame originali
		if (stopSimilarAction)
			[Sprite stopAllActionsByTag: oldTag];
		if (!Sprite.visible)
			Sprite.visible	= true;
		if (flags & RESTORE_ORIGINAL_FRAME)
			[originalFrames addObject: [Sprite displayedFrame]];
	}
	if (stopSimilarAction)
	{//cerco le azioni simili per fermarle
		NSArray		*Actions	= [aTarget getAllActionsByTag: oldTag];
		for (MultiSyncAnimate *Action in Actions)
		{
			if (Action == fatherAction)	continue;
			if (([Action isKindOfClass: [CCRepeat class]]) ||
				([Action isKindOfClass: [CCRepeatForever class]]))
				Action	= (MultiSyncAnimate*)[(CCRepeat*)Action innerAction];
			if ([Action isKindOfClass: [MultiSyncAnimate class]])//se l'azione è una MultiSyncAnimate
			{
				if (Action == self)	continue;
				[Action removeAnimationsForTargets: targets];//gli chiede di fermare le animaioni sulle parti della nuova azione
			}
			else if ([targets indexOfObject: aTarget] != NSNotFound)
				[aTarget stopAction: Action];//altrimenti la ferma se aTarget è tra i target della nuova animazione
		}
		stopSimilarAction		= false;//evito che uccida indiscriminatamente tutte le azioni simili, le ho già fermate io
		tag_					= oldTag;
		fatherAction.tag		= oldFatherTag;
	}
	[super startWithTarget:aTarget];
}

-(void) stop
{
	for (int i = 0; i < [targets count]; i++)
	{
		CCSprite		*Target		= [targets objectAtIndex: i];
		ANCAnimation	*Animation	= [animations objectAtIndex: i];
		if (([Animation respondsToSelector: @selector(HideOnEnd)]) &&
			(Animation.HideOnEnd))
				Target.visible		= false;
		else if (flags & RESTORE_ORIGINAL_FRAME)
		{
			CCSpriteFrame	*Frame	= [originalFrames objectAtIndex: i];
			if (![Target isFrameDisplayed: Frame])
				[Target setDisplayFrame: Frame];
		}
	}		
	[originalFrames release];
	originalFrames	= nil;
	flags			= flags & (INT_MAX - RESTORE_ORIGINAL_FRAME);//CCSequence chiama stop due volte
	[super stop];
}

-(void) dealloc
{
	[animations release];
	[targets release];
	[originalFrames release];
	[super dealloc];
}

-(void) update: (ccTime) t
{
	for (int i = 0; i < [animations count]; i++)
	{
		CCAnimation	*CurrentAnimation			= [animations	objectAtIndex: i];
		CCSprite	*CurrentTarget				= [targets		objectAtIndex: i];
		NSArray		*Frames						= [CurrentAnimation frames];
		int			CurrentAnimationFramesNum	= [Frames count];
//		int			CurrentFrameIndex			= t * duration_ / CurrentAnimation.delay;
		int			CurrentFrameIndex			= t * CurrentAnimationFramesNum;
//CCLOG(@"Animation: %@ frame: %u", [CurrentAnimation name], CurrentFrameIndex);
		if( CurrentFrameIndex >= CurrentAnimationFramesNum )
			CurrentFrameIndex = CurrentAnimationFramesNum -1;
		CCSpriteFrame	*Frame	= [Frames objectAtIndex: CurrentFrameIndex];
		if (![CurrentTarget isFrameDisplayed: Frame] )
			[CurrentTarget setDisplayFrame: Frame];
	}
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"<%@ = %08X | tag = %d\n\tTargets = %@\n\tAnimations = %@>",
			[self class],
			(unsigned int)self,
			tag_,
			[targets description],
			[animations description]];
}
@end
