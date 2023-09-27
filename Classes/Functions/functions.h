/*
 *  functions.h
 *  Prova
 *
 *  Created by mad4chip on 29/03/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
#import "cocos2d.h"
#import "GameConfig.h"

#define UIColorFromRGB(rgbValue)	[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(rgbaValue)	[UIColor colorWithRed:((float)((rgbaValue & 0xFF000000) >> 24))/255.0 green:((float)((rgbaValue & 0xFF0000) >> 16))/255.0 blue:((float)((rgbaValue & 0xFF00) >> 8))/255.0 alpha:((float)((rgbaValue & 0xFF)))/255.0]
#define fsign(x) ((x == 0)?(0):((x > 0)?(1):(-1)))

extern CGSize	ScreenSize;			//dimensioni dello schermo
extern NSString	*DeviceTypeName;	//iPhone iPad iPod
extern int		DeviceVersion;
extern int		DeviceSubVersion;
extern NSString	*PreferredLanguage;
extern float	SpeedFactor;
void InitVars();

#define CGPointIsNull(Point)	((Point.x == 0) && (Point.y == 0))
#define CGSizeIsNull(Size)		((Size.width == 0) || (Size.height == 0))

CG_INLINE CGPoint CGRectCenter(CGRect Rectangle)				{	return ccpAdd(Rectangle.origin, ccp(Rectangle.size.width / 2, Rectangle.size.height / 2));	}
CG_INLINE CGPoint CGRectGetTopLeftAngle(CGRect Rectangle)		{	return CGPointMake(CGRectGetMinX(Rectangle), CGRectGetMaxY(Rectangle));	}
CG_INLINE CGPoint CGRectGetTopRightAngle(CGRect Rectangle)		{	return CGPointMake(CGRectGetMaxX(Rectangle), CGRectGetMaxY(Rectangle));	}
CG_INLINE CGPoint CGRectGetBottomLeftAngle(CGRect Rectangle)	{	return CGPointMake(CGRectGetMinX(Rectangle), CGRectGetMinY(Rectangle));	}
CG_INLINE CGPoint CGRectGetBottomRightAngle(CGRect Rectangle)	{	return CGPointMake(CGRectGetMaxX(Rectangle), CGRectGetMinY(Rectangle));	}

#define CGPointDistance(Point1, Point2)			sqrt(((Point1.x-Point2.x)*(Point1.x-Point2.x))+((Point1.y-Point2.y)*(Point1.y-Point2.y)))
#define CGPointDistanceSquare(Point1, Point2)	(((Point1.x-Point2.x)*(Point1.x-Point2.x))+((Point1.y-Point2.y)*(Point1.y-Point2.y)))

#define NumberInRange(Number, RangeMin, RangeMax)	((Number >= RangeMin) && (Number <= RangeMax))

bool CircleIntersectPoint(CGPoint Punto, CGPoint Origin, float Radius);

#define	CGRectMakeOriginSize(Origin, Size)	CGRectMake(Origin.x, Origin.y, Size.width, Size.height)
#define	CGRectMakeCenterSize(Center, Size)	CGRectMake(Center.x - Size.width / 2, Center.y - Size.height / 2, Size.width, Size.height)

ccColor3B ccColor3BFromString(NSString *String);
ccColor4B ccColor4BFromString(NSString *String);

ccBlendFunc ccBlendFuncFromString(NSString *String);

#define randInRange(min, max)	(rand() % (int)(max - min) + min)
#define drand()					drand48()
#define drandInRange(min, max)	(drand() * (max - min) + min)

CG_INLINE CGPoint RandomPointInRect(CGRect Rectangle)			{	return ccp(rand() % (int)Rectangle.size.width + Rectangle.origin.x, rand() % (int)Rectangle.size.height + Rectangle.origin.y); }
CG_INLINE CGPoint RandomPointOutsideScreen(CGSize ObjSize)
{
	switch (rand() % 4)
	{//
		case 0:	return	ccp(-ObjSize.width,						rand() % (int)ScreenSize.height);
		case 1:	return	ccp(ScreenSize.width + ObjSize.width,	rand() % (int)ScreenSize.height);
		case 2:	return	ccp(rand() % (int)ScreenSize.width,		-ObjSize.height);
		case 3:	return	ccp(rand() % (int)ScreenSize.width,		ScreenSize.height + ObjSize.height);
	}
	return CGPointZero;
}

#define	SetVertexZForNode(Dict, Node)										\
if (useVertexZ)																\
{																			\
Value						= [Dict localizedObjectForKey: @"vertexz"];		\
if (Value)	Node.vertexZ	= [Value floatValue];							\
else		Node.vertexZ	= vertexZForSprite(Node, 0);					\
}

#define ORDERZ_TOP	1023
float vertexZForSprite(CCNode *Node, float Altitude);

#define CGSizeMult(size, scalar)	CGSizeMake(size.width * scalar, size.height * scalar)
#define CGSizeAdd(size1, size2)		CGSizeMake(size1.width + size2.width, size1.height + size2.height)

CGPoint CGPointFromPointOrFloatString(NSString *String);
CG_INLINE	CGSize	CGSizeFromSizeOrFloatString(NSString *String)	{ CGPoint temp = CGPointFromPointOrFloatString(String);	return CGSizeMake(temp.x, temp.y); }

typedef struct
{
	float	scaleX;
	float	scaleY;
	float	rotation;
	float	skewX;
	float	skewY;
	bool	flipX;
	bool	flipY;
} CGTransform;

#define CGTransformNone	((CGTransform){1, 1, 0, 0, 0})
CGTransform CGTransformFromString (NSString*String);
CGTransform CGTransformMultiply (CGTransform Transform1, CGTransform Transform2);
CGTransform CGTransformDivide (CGTransform Transform1, CGTransform Transform2);
ccColor4B	ccColor4BMultiply(ccColor4B color1, ccColor4B color2);
ccColor3B	ccColor3BMultiply(ccColor3B color1, ccColor3B color2);
CGPoint CGPointRotate(CGPoint point, float Rot);
CGRect CGRectRotate(CGRect rectangle, float Rot);
ccColor4B	ccColor4BSub(ccColor4B color1, ccColor4B color2);
ccColor3B	ccColor3BSub(ccColor3B color1, ccColor3B color2);
ccColor4B	ccColor4BMultiplyForNumber(ccColor4B color, float number);
ccColor3B	ccColor3BMultiplyForNumber(ccColor3B color, float number);
ccColor3B	ccColor3BAdd(ccColor3B color1, ccColor3B color2);
ccColor4B	ccColor4BAdd(ccColor4B color1, ccColor4B color2);

#define CC_POINT_PIXELS_TO_POINTS(point) ccp(point.x / CC_CONTENT_SCALE_FACTOR(), point.y / CC_CONTENT_SCALE_FACTOR())
#define CC_POINT_POINTS_TO_PIXELS(point) ccp(point.x * CC_CONTENT_SCALE_FACTOR(), point.y * CC_CONTENT_SCALE_FACTOR())