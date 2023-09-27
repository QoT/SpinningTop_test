//
//  Screw.m
//  SpinningTop
//
//  Created by mad4chip on 14/11/12.
//
//

#import "Screw.h"
#import "CocosAddOn.h"

@implementation ScrewClass
@synthesize Turns;
@synthesize DriveTime;
@synthesize Direction;
@synthesize Value;
-(void)setValue:(float)newValue
{//0 = Avvitata; 1 = Svitata
	if	(newValue < 0)
	{
		Value	= 0;
		ScrewOffImage.visible	= false;
		ScrewOnImage.visible	= true;
	}
	else
	{
		if (newValue > 1)			newValue				= 1;
		if (ScrewOnImage.visible)	ScrewOnImage.visible	= false;
		if (!ScrewOffImage.visible)	ScrewOffImage.visible	= true;
		Value		=	newValue;
		newValue	*= Turns;
		newValue	= fmod(newValue, 1);
		ScrewOffImage.rotation	= -360 * newValue * Turns;
		newValue				= Value * (1 - ScaleFactor) + ScaleFactor;
		ScrewOffImage.scale		= newValue;
		ShadowImage.scale		= newValue;
	}
}

@synthesize ShadowImage;
@synthesize ScrewOnImage;
@synthesize ScrewOffImage;
@synthesize MarkerImage;
@synthesize ScaleFactor;

-(void)showMarker	{	MarkerImage.visible	= true;		}
-(void)hideMarker	{	MarkerImage.visible	= false;	}
-(float)Radius		{	return [MarkerImage width] / 2;	}

+(id)newScrewWithOnImage: (NSString*)On OffImage: (NSString*)Off ShadowImage: (NSString*)Shadow Marker: (NSString*)Marker
{
	return [[[self alloc] initScrewWithOnImage: On OffImage: Off ShadowImage: Shadow Marker: Marker] autorelease];
}

-(id)initScrewWithOnImage: (NSString*)On OffImage: (NSString*)Off ShadowImage: (NSString*)Shadow Marker: (NSString*)Marker
{
	if ((self = [super init]))
	{
		ScrewOnImage	= [ANCSprite spriteWithFile: On];
		ScrewOffImage	= [ANCSprite spriteWithFile: Off];
		ShadowImage		= [ANCSprite spriteWithFile: Shadow];
		MarkerImage		= [ANCSprite spriteWithFile: Marker];

		ScrewOnImage.position	= CGPointZero;
		ScrewOffImage.position	= CGPointZero;
		ShadowImage.position	= CGPointZero;
		ScrewOnImage.visible	= false;
		MarkerImage.position	= CGPointZero;
		MarkerImage.visible		= false;

		[self addChild: ShadowImage		z: 0];
		[self addChild: ScrewOnImage	z: 1];
		[self addChild: ScrewOffImage	z: 2];
		[self addChild: MarkerImage		z: 3];

		DriveTime		= 5;
		Turns			= 10;
		self.ScaleFactor= [ScrewOnImage width] / [ScrewOffImage width];
		self.Value		= 1;
	}
	return self;
}

-(void)driveMeForTime: (float)Time
{
	Time	= Time/DriveTime;
	if (Direction == SCREW)	self.Value	-= Time;
	else					self.Value	+= Time;
}
@end
