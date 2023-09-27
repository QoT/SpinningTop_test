//
//  MenuSlider.m
//  Prova
//
//  Created by Visone on 10/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuSlider.h"
#import "ColoredSquareSprite.h"


@implementation MenuSlider
@synthesize minValue=minValue_, maxValue=maxValue_, value=value_;
@synthesize trackImage=trackImage_, knobImage=knobImage_;
@synthesize Sound;
@synthesize target;

-(void)setSound:(SoundDescriptor*)NewSound
{
	[Sound release];
	Sound	= [NewSound retain];
}

-(void)setTarget:(id)NewTarget
{
	[target release];
	target	= [NewTarget retain];
}

+(id) itemFromTrackImage: (CCSprite*)Track knobImage: (CCSprite*)Knob
{
	return [[[self alloc] initFromTrackImage:Track knobImage:Knob target:nil active:nil drag:nil sound:nil] autorelease];
}

+(id) itemFromTrackImage: (CCSprite*)Track knobImage: (CCSprite*)Knob target: (id)target active: (SEL)selector1 drag: (SEL)selector2
{
	return [[[self alloc] initFromTrackImage:Track knobImage:Knob target:target active: selector1 drag:selector2 sound:nil] autorelease];
}

+(id) itemFromTrackImage:(CCSprite *)Track knobImage:(CCSprite *)Knob target: (id)target active: (SEL)selector1 drag: (SEL)selector2 sound:(SoundDescriptor*)sound_
{
	return [[[self alloc] initFromTrackImage:Track knobImage:Knob target:target active: selector1 drag:selector2 sound:sound_] autorelease];
}

-(id) initFromTrackImage: (CCSprite*)Track knobImage: (CCSprite*)Knob target: (id)target_ active: (SEL)selector1 drag:(SEL)selector2 sound: (SoundDescriptor*)sound_
{
	if( (self=[super initWithTarget:target selector:selector1 ]) ) {
		self.trackImage		= Track;
		self.knobImage		= Knob;
		dragSelector		= selector2;
		self.target			= target_;
		self.Sound			= sound_;
		isVertical			= (Track.contentSize.height > Track.contentSize.width);
		CGSize	TrackSize	= Track.contentSize;
		CGSize	KnobSize	= Knob.contentSize;
		if (isVertical)	
		{
			if (TrackSize.width > KnobSize.width)
					self.contentSize	= CGSizeMake(TrackSize.width,TrackSize.height);
			else	self.contentSize	= CGSizeMake(KnobSize.width,TrackSize.height);
		}
		else
		{
			if(TrackSize.height > KnobSize.height)
					self.contentSize	= CGSizeMake(TrackSize.width,TrackSize.height);
			else	self.contentSize	= CGSizeMake(TrackSize.width,KnobSize.height);
		}
		self.minValue		= 0.;
		self.maxValue		= 100.0f;
		value_				= 50.0f;
		self.position		= position_;
		self.anchorPoint	= anchorPoint_;
	}
	return self;
}

- (void)setValue: (float)aValue
{
	float	Volume;
	
	if (isVertical)
		Volume	= (self.contentSize.height - knobImage_.contentSize.height) / (maxValue_ - minValue_);
	else	
		Volume	= (self.contentSize.width - knobImage_.contentSize.width) / (maxValue_ - minValue_);
	
	if (aValue < minValue_)
		value_	= minValue_;
	else if (aValue > maxValue_)
		value_	= maxValue_;
	else
		value_	= aValue;
	CCLOG(@"MenuSlider NewValue: %.2f", value_);
	if (isVertical)
		knobImage_.position	= ccpAdd(position_, CGPointMake(0, (value_ - minValue_) * Volume - self.anchorPoint.y * self.contentSize.height + knobImage_.anchorPoint.y * knobImage_.contentSize.height));
	else
		knobImage_.position	= ccpAdd(position_, CGPointMake((value_ - minValue_) * Volume - self.anchorPoint.x * self.contentSize.width + knobImage_.anchorPoint.x * knobImage_.contentSize.width, 0));
}

	
-(void) dragToPoint: (CGPoint)aPoint
{
	float	VolumeValue;
	float	absValue;
	
	if (isVertical) {
		VolumeValue	= (maxValue_ - minValue_) / (self.contentSize.height - knobImage_.contentSize.height);
		absValue	= aPoint.y - knobImage_.contentSize.height / 2;
	} else {
		VolumeValue	= (maxValue_ - minValue_) / (self.contentSize.width - knobImage_.contentSize.width);
		absValue	= aPoint.x - knobImage_.contentSize.width / 2;
	}
	
	self.value	= minValue_ + absValue * VolumeValue;
	[target performSelector:dragSelector withObject:self];
}

-(void)dragStart:(CGPoint)Position	{	[self dragToPoint: Position];	}
-(void)dragEnd:(CGPoint)Position	{	[self dragToPoint: Position];	}
-(bool)draggable					{	return true;	}

-(void)activate
{
	[Sound playForTarget:target loop:0];
	[super activate];
}

-(void)unselected
{
	[Sound playForTarget:target loop:0];
	[super activate];	
}

-(void)setPosition:(CGPoint)NewPositon
{
	trackImage_.position	= NewPositon;
	super.position			= NewPositon;
	self.value				= value_;	
}

-(void)setAnchorPoint:(CGPoint)NewAnchor
{
	trackImage_.anchorPoint		= NewAnchor;
	super.anchorPoint			= NewAnchor;
	knobImage_.anchorPoint		= NewAnchor;
}

-(void)cleanup
{
	[target release];//nel caso il target è un antenato del bottone evita un riferimento circolare che impedisce la deallocazione
	target	= nil;
	[super cleanup];
}

-(void)dealloc
{
	[Sound release];
	[target release];
	[trackImage_ release];
	[knobImage_ release];
	[super dealloc];
}

@end


