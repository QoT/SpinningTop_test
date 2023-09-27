//
//  CCMask.m
//  Masking
//
//  Created by Gilles Lesire on 22/04/11.
//  Copyright 2011 iCapps. All rights reserved.
//

#import "DrawingBrush.h"
#import "DrawableSprite.h"
#import "CocosAddOn.h"
#import "OpenGLAddOn.h"
#import "ObjectiveCAddOn.h"
#import "ANCSprite.h"

//permettono di notificare in automatico all'oggetto DrawableSprite che il pennello è stato modificato per cui deve creare un nuovo elemento
#define setSomeThing(SomeThing, Value)				\
{													\
	if (!Sheet_)	SomeThing ## _	= Value;		\
	else											\
	{												\
		DrawingBrush	*Obj;						\
		Obj				= [[self copy] autorelease];\
		Obj.SomeThing	= Value;					\
		Sheet_.CurrentBrush		= Obj;				\
	}												\
}

#define setSomeThingRetain(SomeThing, Value)		\
{													\
	if (!Sheet_)									\
	{												\
		[SomeThing ## _ release ];					\
		SomeThing ## _	= [Value retain];			\
	}												\
	else											\
	{												\
		DrawingBrush	*Obj;						\
		Obj				= [[self copy] autorelease];\
		Obj.SomeThing	= Value;					\
		Sheet_.CurrentBrush		= Obj;				\
	}												\
}

@implementation DrawingBrush
@synthesize Sheet	= Sheet_;
-(void)setSheet:(DrawableSprite *)Sheet
{
	[Sheet_ release];
	Sheet_	= [Sheet retain];
}

@synthesize	Size				= Size_;
@synthesize	Color				= Color_;
@synthesize	Blend				= Blend_;
@synthesize	RandomizeRotation	= RandomizeRotation_;
@synthesize	RepetitionInterval	= RepetitionInterval_;

-(void)setSize:(float)newSize								{	setSomeThing(Size,	newSize);	}
-(void)setColor:(ccColor4B)newColor							{	setSomeThing(Color,	newColor);	}
-(void)setBlend:(ccBlendFunc)newBlend						{	setSomeThing(Blend,	newBlend);	}
-(void)setRandomizeRotation:(bool)newRandomizeRotation		{	setSomeThing(RandomizeRotation,		newRandomizeRotation);	}
-(void)setRepetitionInterval:(float)newRepetitionInterval	{	setSomeThing(RepetitionInterval,	newRepetitionInterval);	}

//crea un array di frame a partire da un array di nomi di frame
-(NSArray*)ConvertFrameArray: (NSArray*)newFrames
{
	if (![[newFrames lastObject] isKindOfClass: [CCSpriteFrame class]])
	{
		NSMutableArray		*Temp	= [NSMutableArray arrayWithCapacity: [newFrames count]];
		ANCSprite			*Sprite;

		if ([newFrames count] == 1)
		{
			Sprite	= [ANCSprite spriteWithFile: [newFrames lastObject]];
			if ((Sprite.animations) && ([Sprite.animations count] == 1))
			{
				CCAnimation	*Animation	= [[Sprite.animations allValues] lastObject];
				return [Animation frames];
			}
		}

		for (NSString *FrameName in newFrames)
		{
			Sprite	= [ANCSprite spriteWithFile: FrameName];
			[Temp addObject: [Sprite displayedFrame]];
		}
		return Temp;
	}
	return newFrames;
}

@synthesize	StartFrames	= StartFrames_;
@synthesize	Frames	= Frames_;
@synthesize	EndFrames	= EndFrames_;
@synthesize	PointFrames	= PointFrames_;


-(NSArray*)Frames		{	return Frames_;	}
-(NSArray*)StartFrames	{	if (StartFrames_)	return StartFrames_;	else	return Frames_;	}
-(NSArray*)EndFrames	{	if (EndFrames_)		return EndFrames_;		else	return Frames_;	}
-(NSArray*)PointFrames	{	if (PointFrames_)	return PointFrames_;	else	return Frames_;	}

-(void)setStartFrames:	(NSArray *)newFrames	{ newFrames	= [self ConvertFrameArray: newFrames];	setSomeThingRetain(StartFrames,	newFrames);	}
-(void)setFrames:		(NSArray *)newFrames	{ newFrames	= [self ConvertFrameArray: newFrames];	setSomeThingRetain(Frames,		newFrames);	}
-(void)setEndFrames:	(NSArray *)newFrames	{ newFrames	= [self ConvertFrameArray: newFrames];	setSomeThingRetain(EndFrames,	newFrames);	}
-(void)setPointFrames:	(NSArray *)newFrames	{ newFrames	= [self ConvertFrameArray: newFrames];	setSomeThingRetain(PointFrames,	newFrames);	}

-(void)setStartImage: (CCSprite*)Image	{	self.StartFrames	= [NSArray arrayWithObject: [Image displayedFrame]];	}
-(void)setEndImage: (CCSprite*)Image	{	self.EndFrames		= [NSArray arrayWithObject: [Image displayedFrame]];	}
-(void)setPointImage: (CCSprite*)Image	{	self.PointFrames	= [NSArray arrayWithObject: [Image displayedFrame]];	}
-(void)setImage: (CCSprite*)Image
{
	self.Color		= [Image colorAndOpacity];
	self.Blend		= [Image blendFunc];
	self.Frames		= [NSArray arrayWithObject: [Image displayedFrame]];
}

+(id)newDrawingBrush
{
	return [[[self alloc] init] autorelease];
}

+(id)newDrawingBrushWithDictionary: (NSDictionary*)Data
{
	NSString		*String;
	DrawingBrush	*Brush	= [self newDrawingBrush];

	if ((String = [Data objectForKey: @"size"]))				Brush.size					= [String floatValue];
	if ((String = [Data objectForKey: @"repetitioninterval"]))	Brush.RepetitionInterval	= [String floatValue];
	if ((String = [Data objectForKey: @"randomizerotation"]))	Brush.RandomizeRotation		= [String boolValue];
	if ((String = [Data objectForKey: @"color"]))				Brush.Color					= ccColor4BFromString(String);
	if ((String = [Data objectForKey: @"blend"]))				Brush.Blend					= ccBlendFuncFromString(String);

	if ((String = [Data objectForKey: @"startimages"]))
	{
		if ([String isKindOfClass: [NSString class]])			Brush.StartImage	= [ANCSprite spriteWithFile: String];
		else if ([String isKindOfClass: [NSArray class]])		Brush.StartFrames	= (NSArray*)String;
		else NSAssert(false, @"Unable to decode frames");
	}

	if ((String = [Data objectForKey: @"endimages"]))
	{
		if ([String isKindOfClass: [NSString class]])			Brush.endImage		= [ANCSprite spriteWithFile: String];
		else if ([String isKindOfClass: [NSArray class]])		Brush.EndFrames		= (NSArray*)String;
		else NSAssert(false, @"Unable to decode frames");
	}

	if ((String = [Data objectForKey: @"pointimages"]))
	{
		if ([String isKindOfClass: [NSString class]])			Brush.pointImage	= [ANCSprite spriteWithFile: String];
		else if ([String isKindOfClass: [NSArray class]])		Brush.PointFrames	= (NSArray*)String;
		else NSAssert(false, @"Unable to decode frames");
	}

	if ((String = [Data objectForKey: @"images"]))
	{
		if ([String isKindOfClass: [NSString class]])			Brush.Image			= [ANCSprite spriteWithFile: String];
		else if ([String isKindOfClass: [NSArray class]])		Brush.Frames		= (NSArray*)String;
		else NSAssert(false, @"Unable to decode frames");
	}
	return Brush;
}

-(id)init
{
	if ((self = [super init]))
	{
		Frames_				= nil;
		StartFrames_		= nil;
		EndFrames_			= nil;
		PointFrames_		= nil;
		RandomizeRotation_	= true;//considerato solo se si caricano dei frame
		RepetitionInterval_	= 0;
		
		Size_				= 1;
		Color_				= ccc4(255, 255, 255, 255);
		Blend_				= (ccBlendFunc){CC_BLEND_SRC, CC_BLEND_DST};

		Sheet_				= nil;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	DrawingBrush *New		= [[[self class] allocWithZone: zone] init];

	New.Frames				= [[Frames_			copy] autorelease];
	New.StartFrames			= [[StartFrames_	copy] autorelease];
	New.EndFrames			= [[EndFrames_		copy] autorelease];
	New.PointFrames			= [[PointFrames_	copy] autorelease];
	New.RepetitionInterval	= RepetitionInterval_;
	New.RandomizeRotation	= RandomizeRotation_;
	New.Size				= Size_;
	New.Color				= Color_;
	New.Blend				= Blend_;
//	New.Sheet				= Sheet_;//sheet non è copiato
	return New;
}

-(void)dealloc
{
	[Frames_		release];
	[StartFrames_	release];
	[EndFrames_		release];
	[PointFrames_	release];
	[Sheet_			release];
	[super dealloc];
}
@end
