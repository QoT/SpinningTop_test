//
//  CCMask.m
//  Masking
//
//  Created by Gilles Lesire on 22/04/11.
//  Copyright 2011 iCapps. All rights reserved.
//

#import "DrawableSprite.h"
#import "CocosAddOn.h"
#import "OpenGLAddOn.h"
#import "ObjectiveCAddOn.h"
#import "ANCSprite.h"

@implementation DrawableSprite

-(DrawingElement*)LastDrawnElement
{
	if (![History count])
	{
		NSAssert(DrawIndex == 0, @"History index error");
		return nil;
	}
	NSAssert(DrawIndex < [History count], @"History index error");
	return	[History objectAtIndex: DrawIndex];
}

-(DrawingElement*)LastElement	{	return	[History lastObject];	}

@synthesize	maskMode;
/*@synthesize	enable;
-(void)setEnable: (bool)en
{
	if ((self.LastElement.Type == DRAWING_ELEMENT_LINE) &&
		(Moved) && (!en))
			[self drawLineClose];
	enable	= en;
}*/

@synthesize CurrentBrush	= CurrentBrush_;
-(void)setCurrentBrush:(DrawingBrush *)Brush
{
	[CurrentBrush_ release];
	CurrentBrush_		= [Brush retain];
	CurrentBrush_.Sheet	= self;
}

@synthesize touchEnabled;
-(void)setTouchEnabled: (bool)value
{
	if (touchEnabled != value)
	{
		touchEnabled	= value;
		if (touchEnabled)
				[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self priority: 128 swallowsTouches: true];//da cambiare
		else	[[CCTouchDispatcher sharedDispatcher] removeDelegate: self];
	}
}

@synthesize BackGroundColor;
@synthesize BackGroundImage	= BackGroundImage_;
-(void) setBackGroundImage: (CCSprite*)Image
{
	[BackGroundImage_ release];
	BackGroundImage_				= [Image retain];
	BackGroundImage_.position		= CGPointZero;
	BackGroundImage_.anchorPoint	= CGPointZero;
}

-(id) initWithSize: (CGSize)Size
{
	if ((self = [super init]))
	{
		RenderTexture		= [[CCRenderTexture renderTextureWithWidth: Size.width height: Size.height] retain];
		[self setTexture: RenderTexture.sprite.texture];
		[self setTextureRect: CGRectMakeOriginSize(CGPointZero, Size)];
		self.flipY			= true;
		touchEnabled		= false;
		self.touchEnabled	= true;//registra il delegato per i tocchi
		LastPosition		= ccp(-1, -1);//fuori dallo schermo

		BackGroundColor		= ccc4(0, 0, 0, 0);
		self.BackGroundImage= nil;
		maskMode			= false;
//		enable				= true;

		CurrentBrush_		= [[DrawingBrush newDrawingBrush] retain];
		History				= [[NSMutableArray arrayWithCapacity: 0] retain];
		DrawIndex			= 0;
		PointsIndex			= 0;
		LastDrawnPoint		= ccp(-1, -1);//fuori dallo schermo
		OnUpdate			= nil;
	}
	return self;
}


+(id)newDrawableSpriteWithFile: (NSString*)FileName
{
	FileName	= [CCFileUtils fullPathFromRelativePath:FileName];
	return [self newDrawableSpriteWithDictionary: [NSDictionary dictionaryWithContentsOfFile: FileName]];
}

+(id)newDrawableSpriteWithDictionary: (NSDictionary*)Data
{
	NSString		*String;
	DrawableSprite	*Sprite;
	CCSprite		*BackGround	= nil;
	CGSize			Size		= CGSizeMake(0, 0);
	
	if ((String = [Data objectForKey: @"backgroundimage"]))
	{
		BackGround			= [ANCSprite spriteWithFile: String];
		Size				= BackGround.textureRect.size;
	}
	else if ((String = [Data objectForKey: @"size"]))			Size				= CGSizeFromString(String);
	
	NSAssert((Size.height > 0) && (Size.width > 0), @"Please specify a background image or a not nul size");
	Sprite	= [[(DrawableSprite*)[self alloc] initWithSize: Size] autorelease];
	if (BackGround)	Sprite.BackGroundImage	= BackGround;
	
	if ((String = [Data objectForKey: @"backgroundcolor"]))		Sprite.BackGroundColor	= ccColor4BFromString(String);
	if ((String = [Data objectForKey: @"maskmode"]))			Sprite.maskMode			= [String boolValue];

	if ((Data	= [Data objectForKey: @"brush"]))				Sprite.CurrentBrush		= [DrawingBrush newDrawingBrushWithDictionary: Data];
	[Sprite clearSprite];
	return Sprite;
}

+(id)newDrawableSpriteWithSize: (CGSize) Size andBackGroundColor: (ccColor4B)Color
{
	return [[[self alloc] initDrawableSpriteWithSize: Size andBackGroundColor: Color] autorelease];
}

-(id)initDrawableSpriteWithSize: (CGSize)Size andBackGroundColor: (ccColor4B)Color
{
	NSAssert((Size.width > 0) && (Size.height > 0), @"DrawableSprite must have width > 0 and height > 0");
	if ((self = [self initWithSize: Size]))
	{
		BackGroundColor	= Color;
		[self clearSprite];
	}
	return self;
}

+(id)newDrawableSpriteWithBackGroundImage: (CCSprite *)BackGround
{
	return [[[self alloc] initDrawableSpriteWithBackGroundImage: BackGround] autorelease];
}

-(id)initDrawableSpriteWithBackGroundImage: (CCSprite *)BackGround
{
	NSAssert(BackGround, @"BackGround must be not nil");
	if ((self = [self initWithSize: [BackGround textureRect].size]))
	{
		self.BackGroundImage	= BackGround;
		[self clearSprite];
	}
	return self;
}

-(void)registerOnUpdateDelegate: (id)target selector: (SEL) selector
{
	[OnUpdate release];
	if (target)
	{
		OnUpdate = [NSInvocation invocationWithMethodSignature: [target methodSignatureForSelector: selector]];
		[OnUpdate setTarget: target];
		[OnUpdate setSelector: selector];
		[OnUpdate retain];
	}
	else OnUpdate	= nil;
}

-(DrawingElement*)newElement: (int)elementType
{//chiude il segmento corrente
	DrawingElement	*Element	= self.LastElement;
	if ((Element) && (Element.Type == DRAWING_ELEMENT_UNDEIFNED))
		[History removeLastObject];

	Element			= [DrawingElement newDrawingElement: elementType];
	Element.Brush	= CurrentBrush_;
	[History addObject: Element];
	return Element;
}

//primitive di disegno
-(void) drawPointAtPosition: (CGPoint)Position
{
	DrawingElement	*LastElement	= [self newElement: DRAWING_ELEMENT_POINTS];
	[LastElement addPoint: Position];
	[self newElement: DRAWING_ELEMENT_UNDEIFNED];//inserisce un elemento non definito per segnalare che quello prima può essere completamente stampato
}

-(void) drawLineStartAtPoint: (CGPoint)Point
{
	DrawingElement	*Element	= [self newElement: DRAWING_ELEMENT_LINE];
	[Element addPoint: Point];
}

-(void) drawLineAddPoint: (CGPoint)Point
{
	NSAssert(self.LastElement.Type == DRAWING_ELEMENT_LINE, @"Wrong Element type");
	[self.LastElement addPoint: Point];
}

-(void) drawLineClose
{
	DrawingElement	*LastElement	= self.LastElement;
	NSAssert(LastElement.Type == DRAWING_ELEMENT_LINE, @"Wrong Element type");
	[self newElement: DRAWING_ELEMENT_UNDEIFNED];//inserisce un elemento non definito per segnalare che quello prima può essere completamente stampato
}

-(void) drawLineWithPoints: (NSArray*)Points
{
	NSAssert([Points count] >= 2, @"Line needs at least 2 points");

	bool	First	= true;
	for (NSValue *Value in Points)
	{
		if (First)	[self drawLineStartAtPoint: [Value CGPointValue]];
		else		[self drawLineAddPoint:		[Value CGPointValue]];
		First	= false;
	}
}

-(void)applyBrush
{
	DrawingElement	*LastDrawnElement	= self.LastDrawnElement;
	if (([History count]> DrawIndex) ||															//nuovi elementi nell'history
		((LastDrawnElement) && ([LastDrawnElement pointsNum] > PointsIndex)))	//nuovi punti nell'ultimo elemento stampato
	{
		[RenderTexture begin];
		if (maskMode)	glColorMask(0, 0, 0, 255);

		//stampo separatamente il primo elemento
		if (PointsIndex == 0)
			[LastDrawnElement startDraw];

		if ((PointsIndex == 0)									||							//prima stampa per questo elemento
			([LastDrawnElement pointsNum] > PointsIndex + 1)	||							//nuovi punti aggiunti
			((LastDrawnPoint.x >= 0) && (LastDrawnPoint.y >= 0) &&
			(!CGPointEqualToPoint(LastDrawnPoint, [LastDrawnElement pointAtIndex: -1]))))	//è stato cambiato l'ultimo punto
		{
			LastDrawnPoint	= [LastDrawnElement drawFromPointIndex: PointsIndex lastDrawnPoint: LastDrawnPoint];
			PointsIndex		= [LastDrawnElement pointsNum];
		}
		DrawIndex++;
		if (DrawIndex < [History count])//CurrentElement non è l'ultimo
		{
			[LastDrawnElement endDraw];
			LastDrawnPoint	= ccp(-1, -1);
		}

		if (DrawIndex < [History count])
		{
			for (; DrawIndex + 1 < [History count]; DrawIndex++)//+ 1 perchè stampo separatamente l'ultimo elemento
			{
				LastDrawnElement	= self.LastDrawnElement;
				[LastDrawnElement startDraw];
				[LastDrawnElement draw];
				[LastDrawnElement endDraw];
			}

			//stampo separatamente l'ultimo elemento
			LastDrawnElement	= self.LastDrawnElement;
			[LastDrawnElement startDraw];
			LastDrawnPoint	= [LastDrawnElement draw];
			PointsIndex		= [LastDrawnElement pointsNum];
			//[LastDrawnElement endDraw]; NON chiamo endDraw
		}
		DrawIndex		= [History count] - 1;
		if (maskMode)	glColorMask(255, 255, 255, 255);
		[RenderTexture end];
	}
}

-(void)visit
{
	[self applyBrush];
	[super visit];
}

-(void)clearSprite
{
	[History	removeAllObjects];//cancella l'history
	DrawIndex	= 0;
	PointsIndex	= 0;

	[RenderTexture beginWithClear: (float)BackGroundColor.r / 255 g: (float)BackGroundColor.g / 255 b: (float)BackGroundColor.b /255 a: (float)BackGroundColor.a / 255];
	if (BackGroundImage_)
	{
		if (maskMode)	glColorMask(255, 255, 255, 0);
		[BackGroundImage_ visit];
		if (maskMode)	glColorMask(255, 255, 255, 255);
	}
	[RenderTexture end];
	LastDrawnPoint	= ccp(-1, -1);
	[OnUpdate	invoke];
}

-(void)clearUndo
{
	[self		applyBrush];//applica tutte le modifiche
	[History	removeAllObjects];//cancella l'history
	DrawIndex		= 0;
	PointsIndex		= 0;
}

-(void)undoLastDraw
{
	DrawingElement	*LastElement	= [History lastObject];
	if ((LastElement) && ([LastElement pointsNum] == 0))
		[History removeLastObject];//elemento vuoto lo elimino
	[History removeLastObject];

	NSMutableArray	*Temp	= History;
	History					= nil;//impedisce di svuotare l'history
	[self clearSprite];
	History					= Temp;
	[self newElement: DRAWING_ELEMENT_UNDEIFNED];
	[OnUpdate	invoke];
}

//gestione tocchi
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
//	if (!enable)	return false;

	CGPoint touchLocation	= [touch locationInView: [touch view]];
	touchLocation			= [[CCDirector sharedDirector] convertToGL: touchLocation];
	Moved					= false;
	LastPosition			= touchLocation;
	return true;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
{
//	if (!enable)	return;

	CGPoint touchLocation	= [touch locationInView: [touch view]];
	touchLocation			= [[CCDirector sharedDirector] convertToGL: touchLocation];

	if (!CGPointEqualToPoint(LastPosition, touchLocation))
	{
		if (!Moved)	[self drawLineStartAtPoint: LastPosition];//nuova linea
		[self drawLineAddPoint:		touchLocation];
		LastPosition	= touchLocation;
		Moved			= true;
		[OnUpdate invoke];
	}
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
{
//	if (!enable)	return;
	if (Moved)
	{
		[self ccTouchMoved: touch withEvent: event];
		[self drawLineClose];
		Moved	= false;
	}
	else		[self drawPointAtPosition: LastPosition];
	LastPosition	= ccp(-1, -1);//fuori dallo schermo
	[OnUpdate invoke];
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self ccTouchEnded: touch withEvent: event];
}

-(float)getTotalLength
{
	float	Length	= 0;
	for (DrawingElement *Element in History)
		Length	+= Element.Length;
	return Length;
}

-(float)getLastElementLength
{
	if ([History count])
			return self.LastElement.Length;
	else	return 0;
}

-(float)getCoverageFactorMask: (ccColor4B)MaskColor RefColor: (ccColor4B)RefColor Step: (int)Step
{
	int				Width			= contentSizeInPixels_.width;
	int				Height			= contentSizeInPixels_.height;
	int				Mask			= (((unsigned int)MaskColor.a * 256 + MaskColor.b) * 256 + MaskColor.g) * 256 + MaskColor.r;
	int				Reference		= (((unsigned int)RefColor.a  * 256 + RefColor.b)  * 256 + RefColor.g)  * 256 + RefColor.r;
	long int		Sum				= 0;
	float			Result;
	unsigned int	*RawSpriteData;
	unsigned int	*Pointer;

	RawSpriteData	= malloc(Height * Width * 4);
	NSAssert(RawSpriteData, @"Malloc Error");
	[RenderTexture begin];
	glReadPixels(0, 0, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, RawSpriteData);
	for (Pointer = &RawSpriteData[Width*Height - 1]; Pointer >= RawSpriteData; Pointer--)
		if (((*Pointer) & Mask) == Reference)	//0xAABBGGRR
			Sum	+= Step;

	[RenderTexture end];
	free(RawSpriteData);

	Result	= (float)Sum / (Height * Width);
	if (Result > 1)	Result	= 1;
	return	Result;
}

-(void)dealloc
{
	[CurrentBrush_		release];
	[RenderTexture		release];
	[BackGroundImage_	release];
	[History			release];
	[super dealloc];
}

@end