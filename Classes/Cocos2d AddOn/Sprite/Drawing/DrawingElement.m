//
//  CCMask.m
//  Masking
//
//  Created by Gilles Lesire on 22/04/11.
//  Copyright 2011 iCapps. All rights reserved.
//

#import "DrawingElement.h"
#import "DrawingBrush.h"
#import "OpenGLAddOn.h"
#import "ObjectiveCAddOn.h"
#import "functions.h"

@implementation DrawingElement

@synthesize	Type;
@synthesize	Brush				= Brush_;
-(void)setBrush:(DrawingBrush *)Brush
{
	[Brush_ release];
	Brush_	= [Brush retain];
}

+(id)newDrawingElement: (int)elementType;
{
	switch (elementType)
	{
		case DRAWING_ELEMENT_POINTS:	return [[[DrawingElementPoints	alloc] init] autorelease];			
		case DRAWING_ELEMENT_LINE:		return [[[DrawingElementLine	alloc] init] autorelease];
		case DRAWING_ELEMENT_UNDEIFNED:	return [[[DrawingElement		alloc] init] autorelease];
		default:						NSAssert(false, @"Unknown Element type");		break;
	}
	return nil;
}

-(id)init
{
	if ((self = [super init]))
	{
		Points		= [[NSMutableArray arrayWithCapacity: 0] retain];
		Type		= DRAWING_ELEMENT_UNDEIFNED;
		Brush_		= nil;
	}
	return self;
}

-(bool)addPoint: (CGPoint)Point
{
	[Points addObject: [NSValue valueWithCGPoint: Point]];
	return true;
}

-(unsigned int)addPoints: (NSArray*)PointsToAdd
{
	unsigned int	Result	= false;
	for (NSValue *Point in PointsToAdd)
		if ([self addPoint: [Point CGPointValue]])
			Result++;
	return Result;
}

-(int)pointsNum
{
	return [Points count];
}

-(CGPoint)lastPoint
{
	NSValue	*Temp	= [Points lastObject];
	return [Temp CGPointValue];
}

-(CGPoint)pointAtIndex: (int)i
{
	NSValue	*Temp	= nil;
	if (i >= 0)
		Temp	= [Points objectAtIndex: i];
	else if ([Points count] > 0)
		Temp	= [Points objectAtIndex: [Points count] + i];
	return [Temp CGPointValue];	
}

-(CGPoint)draw
{
	return	[self drawFromPointIndex: 0 lastDrawnPoint: ccp(-1, -1)];
}

-(CGPoint)drawFromPointIndex: (unsigned int)PointIndex lastDrawnPoint: (CGPoint) lastDrawnPoint
{	return ccp(-1, -1);	}
-(float) Length		{	return 0;	}
-(void)startDraw	{}
-(void)endDraw		{}

-(NSString*)elementTypeString
{
	if (Type == DRAWING_ELEMENT_UNDEIFNED)
			return @"UNDEFINED";
	else	return @"UNKNOWN";
}

-(NSString*)description
{
	NSString *Desc	= [NSString stringWithFormat: @"<%@ = %08X", [self class], (unsigned int)self];
	Desc	= [Desc stringByAppendingFormat: @" %@ Points (%u):\n", [self elementTypeString], [Points count]];

	for (NSValue *Point in Points)
		Desc	= [Desc stringByAppendingFormat: @" (%.2f, %.2f)\n", [Point CGPointValue].x, [Point CGPointValue].y];
	return [Desc stringByAppendingFormat: @">"];
}

-(void)dealloc
{
	[Brush_		release];
	[Points		release];
	[super dealloc];
}
@end

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation DrawingElementPoints
-(id)init
{
	if ((self = [super init]))
		Type	= DRAWING_ELEMENT_POINTS;
	return self;
}

-(NSString*)elementTypeString	{	return	@"Points";	}

-(float) Length		{	return 0;	}
-(void)startDraw	{}
-(void)endDraw		{}
-(CGPoint)drawFromPointIndex: (unsigned int)PointIndex lastDrawnPoint: (CGPoint) lastDrawnPoint
{
	if ([Points count] == 0)	return ccp(-1, -1);

	NSArray	*FrameArray	= [Brush_ PointFrames];
	if (FrameArray)
	{
		for (; PointIndex < [Points count]; PointIndex++)
		{
			CGPoint			Start		= [self pointAtIndex: PointIndex];
			int				FrameIndex	= (PointIndex + (int)Start.x + (int)Start.y) % [FrameArray count];
			CCSpriteFrame	*Frame		= [FrameArray objectAtIndex: FrameIndex];
			float			Angle		= 0;

			if (Brush_.RandomizeRotation)
				Angle	= 2*M_PI * ((((int)Start.x + (int)Start.y)) % 100) / 100;
			drawTextureRect(Start, ccp(Brush_.Size, Brush_.Size), Angle, Brush_.Color, Brush_.Blend, [Frame texture], [Frame rect]);
		}
	}
	else
	{
		glPointSize(Brush_.Size);
		glColor4ub(Brush_.Color.r, Brush_.Color.g, Brush_.Color.b, Brush_.Color.a);
		for (; PointIndex < [Points count]; PointIndex++)
			ccDrawPoint([self pointAtIndex: PointIndex]);
	}
	return [self pointAtIndex: [Points count] - 1];
}

@end


//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation DrawingElementLine
-(id)init
{
	if ((self = [super init]))
		Type	= DRAWING_ELEMENT_LINE;
	return self;
}

-(NSString*)elementTypeString	{	return	@"Line";	}
/*-(bool)addPoint:(CGPoint)Point
{
	if ([Points count] >= 2)
	{//Point1, Point2, Point vedo se posso eliminare Point2
		CGPoint	Point1	= [self pointAtIndex: [Points count] - 2];
		CGPoint	Point2	= [self pointAtIndex: [Points count] - 1];
		
		if (atan2(Point.x - Point1.x, Point.y - Point1.y) == atan2(Point.x - Point2.x, Point.y - Point2.y))
		{
			//					NSLog(@"Point optimization");
			[Points removeLastObject];//il nuovo punto è in linea con i precedenti
		}
	}
	return [super addPoint: Point];
}
//*/
-(float) Length
{
	if ([Points count] <= 1)	return 0;

	float	Temp	= 0;
	CGPoint	Start;
	CGPoint	End		= [self pointAtIndex: 0];
	
	for (int i = 1; i < [Points count]; i++)
	{
		Start	= End;
		End		= [self pointAtIndex: i];
		Temp	+= CGPointDistance(Start, End);
	}
	return Temp;
}

-(void)startDraw
{
	NSArray			*FrameArray	= [Brush_ StartFrames];
	if ([Points count] == 0)	return;

	if (FrameArray)
	{
		CGPoint			Start		= [self pointAtIndex: 0];
		CGPoint			End			= [self pointAtIndex: 1];
		int				FrameIndex	= ((int)Start.x + (int)Start.y) % [FrameArray count];
		CCSpriteFrame	*Frame		= [FrameArray objectAtIndex: FrameIndex];
		CGRect			TextureRect	= [Frame rect];
		float			Angle		= atan2f(End.y - Start.y, End.x - Start.x);

		if (Brush_.RepetitionInterval == 0)
		{
			TextureRect.origin	= ccp(TextureRect.origin.x, TextureRect.origin.y + TextureRect.size.height / 2);
			TextureRect.size	= CGSizeMake(TextureRect.size.width, TextureRect.size.height / 2);	//usa solo la metà di sopra della texture
			drawTextureCircleSector(Start, Brush_.Size * TextureRect.size.height / 2, Angle + M_PI/2, Angle + M_PI*3/2, Brush_.Color, Brush_.Blend, [Frame texture], TextureRect);
		}
		else
		{
			if (Brush_.RandomizeRotation)
				Angle	+= (((int)Start.x + (int)Start.y)) % 100 / 100;
			drawTextureRect(Start, ccp(Brush_.Size, Brush_.Size), Angle, Brush_.Color, Brush_.Blend, [Frame texture], TextureRect);
		}
	}
}

-(void)endDraw
{
	NSArray			*FrameArray	= [Brush_ EndFrames];
	if ([Points count] == 0)	return;
	
	if (FrameArray)
	{
		CGPoint			End			= [self pointAtIndex: [Points count] - 1];
		CGPoint			Start		= [self pointAtIndex: [Points count] - 2];
		int				FrameIndex	= ([Points count] + (int)Start.x + (int)Start.y) % [FrameArray count];
		CCSpriteFrame	*Frame		= [FrameArray objectAtIndex: FrameIndex];
		CGRect			TextureRect	= [Frame rect];
		float			Angle		= atan2f(End.y - Start.y, End.x - Start.x);

		if (Brush_.RepetitionInterval == 0)
		{
			TextureRect.origin	= ccp(TextureRect.origin.x, TextureRect.origin.y + TextureRect.size.height / 2);
			TextureRect.size	= CGSizeMake(TextureRect.size.width, TextureRect.size.height / 2);	//usa solo la metà di sopra della texture
			drawTextureCircleSector(End, Brush_.Size * TextureRect.size.height / 2, Angle - M_PI/2, Angle + M_PI/2, Brush_.Color, Brush_.Blend, [Frame texture], TextureRect);
		}
		else
		{
			if (Brush_.RandomizeRotation)
				Angle	+= 2*M_PI * ((((int)Start.x + (int)Start.y)) % 100) / 100;
			drawTextureRect(End, ccp(Brush_.Size, Brush_.Size), Angle, Brush_.Color, Brush_.Blend, [Frame texture], TextureRect);
		}
	}
}

-(CGPoint)drawFromPointIndex: (unsigned int)PointIndex lastDrawnPoint: (CGPoint) lastDrawnPoint
{
	NSArray			*FrameArray	= [Brush_ Frames];
	if (PointIndex >= [Points count])	return ccp(-1, -1);

	if (FrameArray)
	{
		float			Angle;
		float			PreviousAngle;
		CGPoint			Start;
		CGPoint			End;
		CCSpriteFrame	*Frame;
		CGRect			TextureRect;
		int				FrameIndex;

		if (Brush_.RepetitionInterval == 0)
		{//linea con texture
			if (PointIndex == 0)	PointIndex++;
			End	= [self pointAtIndex: PointIndex - 1];
			for (; PointIndex < [Points count]; PointIndex++)
			{
				Start			= End;
				End				= [self pointAtIndex: PointIndex];
				if (CGPointEqualToPoint(Start, End))	continue;

				PreviousAngle	= Angle;

				FrameIndex		= (PointIndex + (int)Start.x + (int)Start.y) % [FrameArray count];
				Frame			= [FrameArray objectAtIndex: FrameIndex];
				TextureRect		= [Frame rect];
				Angle			= atan2f(End.y - Start.y, End.x - Start.x);

				/*/*levare??*/
				if (PointIndex > 1)
				{
					if (Angle > PreviousAngle)		drawTextureCircleSector(Start, Brush_.Size * TextureRect.size.height / 2, PreviousAngle + M_PI/2, Angle + M_PI/2, ccc4(0, 255, 0, 255), Brush_.Blend, [Frame texture], TextureRect);
					else if (Angle < PreviousAngle)	drawTextureCircleSector(Start, Brush_.Size * TextureRect.size.height / 2, Angle + M_PI/2, PreviousAngle + M_PI/2, ccc4(0, 0, 255, 255), Brush_.Blend, [Frame texture], TextureRect);
				}
				drawTextureLine(Start, End, Brush_.Size * TextureRect.size.height, Brush_.Color, Brush_.Blend, [Frame texture], TextureRect);
			}
		}
		else
		{//linea con punti ripetuti
			if (PointIndex == 0)
			{//disegno dal primo punto
				End				= [self pointAtIndex: PointIndex];//diventerà start
				PointIndex++;
			}
			else if ((lastDrawnPoint.x >= 0) && (lastDrawnPoint.y >= 0) &&
					 (!CGPointEqualToPoint(lastDrawnPoint, [self pointAtIndex: PointIndex])))
			{//si è allungato un segmento già stampato parzialmente
				End	= lastDrawnPoint;
				PointIndex--;//stamo l'ultimo frammento del segmento allungato
			}
			else
			{//nuovo segmento
				End	= [self pointAtIndex: PointIndex];//diventerà start
			}
			lastDrawnPoint	= ccp(-1, -1);

			for (; PointIndex < [Points count]; PointIndex++)
			{
				float			RandAngle	= 0;
				float			Distance;
				int				i;

				Start		= End;
				End			= [self pointAtIndex: PointIndex];
				Distance	= CGPointDistance(Start, End);
				i			= floorf(Distance / Brush_.RepetitionInterval);
				Angle		= atan2f(End.y - Start.y, End.x - Start.x);

				for (; i > 1; i--)
				{
					FrameIndex		= (PointIndex + (int)Start.x + (int)Start.y) % [FrameArray count];
					Frame			= [FrameArray objectAtIndex: FrameIndex];
					TextureRect		= [Frame rect];
					if (Brush_.RandomizeRotation)
						RandAngle	= 2*M_PI * ((((int)Start.x + (int)Start.y)) % 100) / 100;

					Start			= ccpAdd(Start, ccp(Brush_.RepetitionInterval * cosf(Angle), Brush_.RepetitionInterval * sinf(Angle)));
					drawTextureRect(Start, ccp(Brush_.Size, Brush_.Size), Angle + RandAngle, Brush_.Color, Brush_.Blend, [Frame texture], TextureRect);
					lastDrawnPoint	= Start;
				}

				//l'ultimo punto lo stampo sempre ad End
				FrameIndex		= (PointIndex + (int)End.x + (int)End.y) % [FrameArray count];
				Frame			= [FrameArray objectAtIndex: FrameIndex];
				TextureRect		= [Frame rect];
				if (Brush_.RandomizeRotation)
					RandAngle	= 2*M_PI * ((((int)End.x + (int)End.y)) % 100) / 100;
				drawTextureRect(End, ccp(Brush_.Size, Brush_.Size), Angle + RandAngle, Brush_.Color, Brush_.Blend, [Frame texture], TextureRect);
				lastDrawnPoint	= End;
			}
			return lastDrawnPoint;
		}
	}
	else
	{//linea openGL
		CGPoint	Point1;
		CGPoint	Point2;
		if (PointIndex == 0)
		{
			Point1		= [self pointAtIndex: 0];
			PointIndex	= 1;
		}
		else	Point1	= [self pointAtIndex: PointIndex - 1];
		glLineWidth(Brush_.Size);
		glColor4ub(Brush_.Color.r, Brush_.Color.g, Brush_.Color.b, Brush_.Color.a);
		for (; PointIndex < [Points count]; PointIndex++)
		{
			Point2	= [self pointAtIndex: PointIndex];
			ccDrawLine(Point1, Point2);
			Point1	= Point2;
		}
	}
	return [self pointAtIndex: [Points count] - 1];
}
@end
