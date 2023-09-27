/*
 *  functions.c
 *  Prova
 *
 *  Created by mad4chip on 29/03/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "functions.h"
#import <sys/utsname.h>
#import "CocosAddOn.h"
#import "ObjectiveCAddOn.h"

CGSize		ScreenSize;
NSString	*DeviceTypeName;
int			DeviceVersion;
int			DeviceSubVersion;
NSString	*PreferredLanguage;
float 		SpeedFactor;

void InitVars()
{
#ifdef DEBUGALLOC
	[NSObject enableDebugAlloc];
#endif
	srand([NSDate timeIntervalSinceReferenceDate]);
	ScreenSize	= [[CCDirector sharedDirector] winSize];

	struct utsname systemInfo;
	uname(&systemInfo);
	DeviceTypeName		= [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
	NSArray *NameParts	= [DeviceTypeName componentsSeparatedByString: @","];
	DeviceTypeName		= [NameParts objectAtIndex: 0];
	if ([NameParts count] == 2)
			DeviceSubVersion	= [[NameParts objectAtIndex: 1] intValue];
	else	DeviceSubVersion	= 0;
	DeviceVersion	= 0;
	if (![DeviceTypeName isEqualToString: @"i386"])
	{
		DeviceVersion	= [[DeviceTypeName substringFromIndex: [DeviceTypeName length] - 1] intValue];
		DeviceTypeName	= [DeviceTypeName substringToIndex: [DeviceTypeName length] - 1];
	}
	else
	{
		DeviceVersion	= -1;
		DeviceSubVersion= -1;
		if (((ScreenSize.width == 1024) && (ScreenSize.height == 768)) ||
			((ScreenSize.width == 768) && (ScreenSize.height == 1024)))
					DeviceTypeName	= @"iPad";
		else if (((ScreenSize.width == 960) && (ScreenSize.height == 640)) ||
				 ((ScreenSize.width == 640) && (ScreenSize.height == 960)))
					DeviceTypeName	= @"iPod";
		else		DeviceTypeName	= @"iPod";		
	}
	[DeviceTypeName retain];
/*
	@"i386"      on the simulator

	@"iPod1,1"   on iPod Touch
	@"iPod2,1"   on iPod Touch Second Generation
	@"iPod3,1"   on iPod Touch Third Generation
	@"iPod4,1"   on iPod Touch Fourth Generation

	@"iPhone1,1" on iPhone
	@"iPhone1,2" on iPhone 3G
	@"iPhone2,1" on iPhone 3GS
	@"iPhone3,1" on iPhone 4
	@"iPhone4,1" on iPhone 4S
 
	@"iPad1,1"   on iPad
	@"iPad2,1"   on iPad 2
*/
/*	iPhone
	iPhone1,1 (product ID 4752, hex 0x1290, hw.model M68AP): iPhone "2G"
	iPhone1,2 (product ID 4754, hex 0x1292, hw.model N82AP): iPhone 3G
	iPhone2,1 (product ID 4756, hex 0x1294, hw.model N88AP): iPhone 3GS
	iPhone3,1 (product ID 4759, hex 0x1297, hw.model N90AP): iPhone 4
	iPhone3,2 (product ID 4763, hex 0x129B): iPhone 4 (CDMA) Prototype
	iPhone3,3 (product ID 4764, hex 0x129C, hw.model N92AP): iPhone 4 (CDMA)

	iPod Touch
	iPod1,1 (product ID 4753, hex 0x1291, hw.model N45AP): iPod Touch "1G"
	iPod2,1 (product ID 4755, hex 0x1293, hw.model N72AP): iPod Touch "2G"
	iPod2,2 (product ID 4758, hex 0x1296): iPod Touch "3G" Prototype
	iPod3,1 (product ID 4761, hex 0x1299, hw.model N18AP): iPod Touch "3G"
	iPod4,1 (product ID 4766, hex 0x129e, hw.model N81AP): iPod Touch "4G"

	iPad
	iProd0,1 (product ID 4757, hex 0x1295): iPad prototype
	iPad1,1 (product ID 4762, hex 0x129a, hw.model ?): iPad WiFi only
	iPad1,1 (product ID ?, hex ?, hw.model K48AP): iPad 3G+WiFi
	iPad2,1 (product ID ?, hex ?, hw.model K93AP): iPad 2 WiFi
	iPad2,2 (product ID ?, hex ?, hw.model K94AP): iPad 2 Wi-Fi + 3G (GSM)
	iPad2,3 (product ID ?, hex ?, hw.model K95AP): iPad 2 Wi-Fi + 3G (CDMA)
*/
/*
Device		ScreenSize	Aspect
iPad:		1024 × 768	1.33	pixels on a 9.7 inches screen.
iPhone 4:	960 x 640	1.5		pixels at 326 ppi; on 89 mm 3.5 screen.
iPhone 3.0,
iPhone 2.0,
iPhone 1.0,
iPod Touch	480 x 320	1.5		pixels at 163 ppi.89 mm 3.5 in screen.
*/
	SpeedFactor			= ScreenSize.width / REFERENCESCREENSIZE;
	PreferredLanguage	= [[NSLocale preferredLanguages] objectAtIndex:0];
	[PreferredLanguage retain];
	[CCTexture2D PVRImagesHavePremultipliedAlpha: true];
}

bool CircleIntersectPoint(CGPoint Punto, CGPoint Origin, float Radius)
{
	CGRect	CircleRect;
	CircleRect.origin		= ccp(Origin.x - Radius, Origin.y - Radius);
	CircleRect.size.width	= 2*Radius;
	CircleRect.size.height	= 2*Radius;
	if (!CGRectContainsPoint(CircleRect, Punto))
		return false;
	float tempX	= Origin.x - Punto.x;
	float tempY	= Origin.y - Punto.y;
	tempX	*= tempX;
	tempY	*= tempY;
	if (tempY + tempX > Radius * Radius)
		return false;
	return true;
}

ccColor3B ccColor3BFromString(NSString *String)
{
	int Length	= [String length] - 1;
	NSCAssert((([String characterAtIndex: 0] == '{') && ([String characterAtIndex: Length] == '}')), @"ccColor3BFromString format error");
	String	= [String substringWithRange: (NSRange){1, Length}];
	NSArray	*Components	= [String componentsSeparatedByString: @","];
	NSCAssert([Components count] == 3, @"ccColor3BFromString format error");
	ccColor3B	Color;
	Color.r	= [[Components objectAtIndex: 0] intValue];
	Color.g	= [[Components objectAtIndex: 1] intValue];
	Color.b	= [[Components objectAtIndex: 2] intValue];
	return Color;
}

//String = "{1,2,3}"	return ccc4(1,2,3,255)
//String = "{1,2,3,4}"	return ccp4(1,2,3,4)
ccColor4B ccColor4BFromString(NSString *String)
{
	int Length	= [String length] - 1;
	NSCAssert((([String characterAtIndex: 0] == '{') && ([String characterAtIndex: Length] == '}')), @"ccColor4BFromString format error");
	String	= [String substringWithRange: (NSRange){1, Length}];
	NSArray	*Components	= [String componentsSeparatedByString: @","];

	NSCAssert(([Components count] == 4) || ([Components count] == 3), @"ccColor4BFromString format error");
	ccColor4B	Color;
	Color.r	= [[Components objectAtIndex: 0] intValue];
	Color.g	= [[Components objectAtIndex: 1] intValue];
	Color.b	= [[Components objectAtIndex: 2] intValue];
	if ([Components count] == 4)
		Color.a	= [[Components objectAtIndex: 3] intValue];
	else
	{
		CCLOG(@"ccColor4BFromString missing alpha component");
		Color.a	= 255;
	}
	return Color;
}

ccBlendFunc ccBlendFuncFromString(NSString *String)
{
	int Length	= [String length] - 1;
	NSCAssert((([String characterAtIndex: 0] == '{') && ([String characterAtIndex: Length] == '}')), @"ccBlendFuncFromString format error");
	String	= [String substringWithRange: (NSRange){1, Length}];
	NSArray	*Components	= [String componentsSeparatedByString: @","];
	
	NSCAssert([Components count] == 2, @"ccBlendFuncFromString format error");
	ccBlendFunc	Blend	= {CC_BLEND_SRC, CC_BLEND_DST};

	if		([Components[0] isEqualToString: @"GL_ZERO"])					Blend.src	= GL_ZERO;
	else if ([Components[0] isEqualToString: @"GL_ONE"])					Blend.src	= GL_ONE;
	else if ([Components[0] isEqualToString: @"GL_SRC_COLOR"])				Blend.src	= GL_SRC_COLOR;
	else if ([Components[0] isEqualToString: @"GL_ONE_MINUS_SRC_COLOR"])	Blend.src	= GL_ONE_MINUS_SRC_COLOR;
	else if ([Components[0] isEqualToString: @"GL_DST_COLOR"])				Blend.src	= GL_DST_COLOR;
	else if ([Components[0] isEqualToString: @"GL_ONE_MINUS_DST_COLOR"])	Blend.src	= GL_ONE_MINUS_DST_COLOR;
	else if ([Components[0] isEqualToString: @"GL_SRC_ALPHA"])				Blend.src	= GL_SRC_ALPHA;
	else if ([Components[0] isEqualToString: @"GL_ONE_MINUS_SRC_ALPHA"])	Blend.src	= GL_ONE_MINUS_SRC_ALPHA;
	else if ([Components[0] isEqualToString: @"GL_SRC_ALPHA_SATURATE"])		Blend.src	= GL_SRC_ALPHA_SATURATE;
	else if ([Components[0] isEqualToString: @"GL_DST_ALPHA"])				Blend.src	= GL_SRC_ALPHA;
	else if ([Components[0] isEqualToString: @"GL_ONE_MINUS_DST_ALPHA"])	Blend.src	= GL_ONE_MINUS_SRC_ALPHA;

	if		([Components[1] isEqualToString: @"GL_ZERO"])					Blend.dst	= GL_ZERO;
	else if ([Components[1] isEqualToString: @"GL_ONE"])					Blend.dst	= GL_ONE;
	else if ([Components[1] isEqualToString: @"GL_SRC_COLOR"])				Blend.dst	= GL_SRC_COLOR;
	else if ([Components[1] isEqualToString: @"GL_ONE_MINUS_SRC_COLOR"])	Blend.dst	= GL_ONE_MINUS_SRC_COLOR;
	else if ([Components[1] isEqualToString: @"GL_DST_COLOR"])				Blend.dst	= GL_DST_COLOR;
	else if ([Components[1] isEqualToString: @"GL_ONE_MINUS_DST_COLOR"])	Blend.dst	= GL_ONE_MINUS_DST_COLOR;
	else if ([Components[1] isEqualToString: @"GL_SRC_ALPHA"])				Blend.dst	= GL_SRC_ALPHA;
	else if ([Components[1] isEqualToString: @"GL_ONE_MINUS_SRC_ALPHA"])	Blend.dst	= GL_ONE_MINUS_SRC_ALPHA;
	else if ([Components[1] isEqualToString: @"GL_SRC_ALPHA_SATURATE"])		Blend.dst	= GL_SRC_ALPHA_SATURATE;
	else if ([Components[1] isEqualToString: @"GL_DST_ALPHA"])				Blend.dst	= GL_SRC_ALPHA;
	else if ([Components[1] isEqualToString: @"GL_ONE_MINUS_DST_ALPHA"])	Blend.dst	= GL_ONE_MINUS_SRC_ALPHA;

	return Blend;
}

//returns a number between -1 and 0 for automatic VertexZ calculation based on Y coordinate of the sprite
//Y = 0					=> vertexZ = 0	on top
//Y = ScreenSize.height => vertexZ = -1	on bottom
float vertexZForSprite(CCNode *Node, float Altitude)
{
	float	YPosition;
	if ([Node respondsToSelector: @selector(TrimmedRect)])
			YPosition	= [Node.parent convertToWorldSpace: [(CCSprite*)Node TrimmedRect].origin].y;
	else	YPosition	= [Node.parent convertToWorldSpace: [Node boundingBox].origin].y;
	YPosition			-= Altitude;

	if		(YPosition > ScreenSize.height)	YPosition = ScreenSize.height;
	else if (YPosition < 0)					YPosition = 0;
	YPosition	= -YPosition / ScreenSize.height;
	return YPosition;
}

//String = "2"		return ccp(2,2)
//String = "{1,2}"	return ccp(1,2)
CGPoint CGPointFromPointOrFloatString(NSString *String)
{
	if ([String rangeOfString: @","].location != NSNotFound)
		return	CGPointFromString(String);

	float	temp	= [String floatValue];
	return ccp(temp, temp);
}

//String = "2"						return {2, 2,  0,   0,   0}
//String = "30°"					return {1, 1, 30,   0,   0}
//String = "{1, 2}"					return {1, 2,  0,   0,   0}
//String = "{1, 2, 30}"				return {1, 2, 30,   0,   0}
//String = "{1, 2, 30, 0.1, 0.2}"	return {1, 2, 30, 0.1, 0.2}
CGTransform CGTransformFromString (NSString*String)
{
	CGTransform	Temp	= CGTransformNone;
		
	int Length	= [String length] - 1;
	if (([String characterAtIndex: 0] == '{') && ([String characterAtIndex: Length] == '}'))
	{
		String	= [String substringWithRange: (NSRange){1, Length}];
		NSArray	*Components	= [String componentsSeparatedByString: @","];
		switch ([Components count])
		{
			case 5:
					Temp.skewY		= [[Components objectAtIndex: 4] floatValue]; 
					Temp.skewX		= [[Components objectAtIndex: 3] floatValue];
			case 3:
					Temp.rotation	= [[Components objectAtIndex: 2] floatValue];
			case 2:
					Temp.scaleY		= [[Components objectAtIndex: 1] floatValue];
					Temp.scaleX		= [[Components objectAtIndex: 0] floatValue];
			break;
			default:	NSCAssert(false, @"CGTransformFromString format error");	break;
		}
		NSCAssert(([Components count] == 4) || ([Components count] == 3), @"ccColor4BFromString format error");
		ccColor4B	Color;
		Color.r	= [[Components objectAtIndex: 0] intValue];
		Color.g	= [[Components objectAtIndex: 1] intValue];
		Color.b	= [[Components objectAtIndex: 2] intValue];
		if ([Components count] == 4)
			Color.a	= [[Components objectAtIndex: 3] intValue];
		else
		{
			CCLOG(@"ccColor4BFromString missing alpha component");
			Color.a	= 255;
		}
	}
	else
	{
		float	TempF	= [String floatValue];
		if ([String rangeOfString: @"°"].location != NSNotFound)
			Temp.rotation	= TempF;
		else
		{
			NSCAssert(TempF == 0, @"CGTransformFromString format error");
			Temp.scaleX	= TempF;
			Temp.scaleY	= TempF;
		}
	}
	NSCAssert((Temp.scaleX == 0) && (Temp.scaleY == 0), @"CGTransformFromString scale cannot be 0");
	return Temp;
}

CGTransform CGTransformMultiply (CGTransform Transform1, CGTransform Transform2)
{
	Transform1.scaleX	*= Transform2.scaleX;
	Transform1.scaleY	*= Transform2.scaleY;
	Transform1.rotation	+= Transform2.rotation;
	Transform1.skewX	+= Transform2.skewX;
	Transform1.skewY	+= Transform2.skewY;
	return Transform1;
}

CGTransform CGTransformDivide (CGTransform Transform1, CGTransform Transform2)
{
	Transform1.scaleX	/= Transform2.scaleX;
	Transform1.scaleY	/= Transform2.scaleY;
	Transform1.rotation	-= Transform2.rotation;
	Transform1.skewX	-= Transform2.skewX;
	Transform1.skewY	-= Transform2.skewY;
	return Transform1;
}

ccColor4B	ccColor4BMultiply(ccColor4B color1, ccColor4B color2)
{
	return ccc4((color1.r * color2.r)/ 255,
				(color1.g * color2.g)/ 255,
				(color1.b * color2.b)/ 255,
				(color1.a * color2.a)/ 255);
}

ccColor3B	ccColor3BMultiply(ccColor3B color1, ccColor3B color2)
{
	return ccc3((color1.r * color2.r)/ 255,
				(color1.g * color2.g)/ 255,
				(color1.b * color2.b)/ 255);
}

CGPoint CGPointRotate(CGPoint point, float Rot)
{
	float	sin	= sinf(Rot);
	float	cos	= cosf(Rot);

	return ccp(point.x*cos - point.y*sin, point.x*sin + point.y*cos);
}

CGRect CGRectRotate(CGRect rectangle, float Rot)
{
	CGPoint	BLPoint	= ccp(CGRectGetMinX(rectangle), CGRectGetMinY(rectangle));
	CGPoint	BRPoint	= ccp(CGRectGetMaxX(rectangle), CGRectGetMinY(rectangle));
	CGPoint	TLPoint	= ccp(CGRectGetMinX(rectangle), CGRectGetMaxY(rectangle));
	CGPoint	TRPoint	= ccp(CGRectGetMaxX(rectangle), CGRectGetMaxY(rectangle));

	BLPoint	= CGPointRotate(BLPoint, Rot);
	BRPoint	= CGPointRotate(BRPoint, Rot);
	TLPoint	= CGPointRotate(TLPoint, Rot);
	TRPoint	= CGPointRotate(TRPoint, Rot);

	float	MaxX	= MAX(MAX(BLPoint.x, TRPoint.x), MAX(TLPoint.x, BRPoint.x));
	float	MaxY	= MAX(MAX(BLPoint.y, TRPoint.y), MAX(TLPoint.y, BRPoint.y));
	float	MinX	= MIN(MIN(BLPoint.x, TRPoint.x), MIN(TLPoint.x, BRPoint.x));
	float	MinY	= MIN(MIN(BLPoint.y, TRPoint.y), MIN(TLPoint.y, BRPoint.y));

	rectangle		= CGRectMake(MinX, MinY, MaxX - MinX, MaxY - MinY);
	return rectangle;
}


ccColor4B	ccColor4BSub(ccColor4B color1, ccColor4B color2)
{
	if ((int)color1.r > (int)color2.r)
		color1.r	-= color2.r;
	else	color1.r	= 0;
	
	if ((int)color1.g > (int)color2.g)
		color1.g	-= color2.g;
	else	color1.g	= 0;
	
	if ((int)color1.b > (int)color2.b)
		color1.b	-= color2.b;
	else	color1.b	= 0;
	
	if ((int)color1.a > (int)color2.a)
		color1.a	-= color2.a;
	else	color1.a	= 0;
	
	return color1;
}

ccColor3B	ccColor3BSub(ccColor3B color1, ccColor3B color2)
{
	if (color1.r > color2.r)
		color1.r	-= color2.r;
	else	color1.r	= 0;
	
	if (color1.g > color2.g)
		color1.g	-= color2.g;
	else	color1.g	= 0;
	
	if (color1.b > color2.b)
		color1.b	-= color2.b;
	else	color1.b	= 0;
	
	return color1;
}
ccColor4B	ccColor4BAdd(ccColor4B color1, ccColor4B color2)
{
	int	temp;
	temp	= (int)color1.r + (int)color2.r;
	if (temp > 255)
		color1.r	= 255;
	else
		color1.r = temp;
	
	temp	= (int)color1.g + (int)color2.g;
	if (temp > 255)
		color1.g	= 255;
	else
		color1.g = temp;
	
	temp	= (int)color1.b + (int)color2.b;
	if (temp > 255)
		color1.b	= 255;
	else
		color1.b = temp;
	
	temp	= (int)color1.a + (int)color2.a;
	if (temp > 255)
		color1.a	= 255;
	else
		color1.a = temp;
	
	
	return color1;
}

ccColor3B	ccColor3BAdd(ccColor3B color1, ccColor3B color2)
{
	int	temp;
	temp	= (int)color1.r + (int)color2.r;
	if (temp > 255)
		color1.r	= 255;
	else
		color1.r = temp;
	
	temp	= (int)color1.g + (int)color2.g;
	if (temp > 255)
		color1.g	= 255;
	else
		color1.g = temp;
	
	temp	= (int)color1.b + (int)color2.b;
	if (temp > 255)
		color1.b	= 255;
	else
		color1.b = temp;
	return color1;
}

ccColor4B	ccColor4BMultiplyForNumber(ccColor4B color, float number)
{
	return ccc4(((float)color.r * number),
				((float)color.g * number),
				((float)color.b * number),
				((float)color.a * number));
}

ccColor3B	ccColor3BMultiplyForNumber(ccColor3B color, float number)
{
	return ccc3(((float)color.r * number),
				((float)color.g * number),
				((float)color.b * number));
}

