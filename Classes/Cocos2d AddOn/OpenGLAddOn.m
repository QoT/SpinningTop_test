//
//  CocosAddOn.m
//  Prova
//
//  Created by mad4chip on 25/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenGLAddOn.h"
#import "functions.h"

#define CIRCLE_SECTOR_NUM	36

void drawTextureCircleSector(CGPoint Center, float Radius, float startAngle, float endAngle, ccColor4B Color, ccBlendFunc Blend, CCTexture2D *Texture, CGRect TextureRect)
{
	float			AngleIncrement	= 2.0f * M_PI / CIRCLE_SECTOR_NUM;
	float			Angle;
	int				i;
	float			*Vertex			= (float*)malloc(sizeof(float) * (CIRCLE_SECTOR_NUM + 2) * 2);//CIRCLE_SECTOR_NUM triangoli con 1 vertice ognuno (uno è il centro, il terzo è quello del trinagolo precedente) più il primo punto più il centro e 2 coordinate l'uno
	NSCAssert(Vertex, @"Malloc error");
	float			*TextCoord		= nil;

	if (Texture)
	{
		TextCoord					= (float*)malloc(sizeof(float) * (CIRCLE_SECTOR_NUM + 2) * 2);//CIRCLE_SECTOR_NUM triangoli con 1 vertice ognuno (uno è il centro, il terzo è quello del trinagolo precedente) più il primo punto più il centro e 2 coordinate l'uno
		NSCAssert(TextCoord, @"Malloc error");
	}

	//vertex setup
	//centro
	Vertex[0]		= Center.x;
	Vertex[1]		= Center.y;
	
	Angle			= startAngle;
	i				= 1;
	int	Points_Num	= 1;
	
	while (i < CIRCLE_SECTOR_NUM + 1)
	{//CIRCLE_SECTOR_NUM - 1 punti, il primo e l'ultimo coincidono
		if (Angle >= endAngle)
		{
			Angle	= endAngle;
			break;
		}
		Vertex[2 * i + 0]	= Vertex[0] + Radius * cosf(Angle);
		Vertex[2 * i + 1]	= Vertex[1] + Radius * sinf(Angle);
		i++;
		Points_Num++;
		Angle				+= AngleIncrement;
	}
	//l'ultimo punto coincide col primo vertice
	Vertex[2 * i + 0]		= Vertex[0] + Radius * cosf(Angle);
	Vertex[2 * i + 1]		= Vertex[1] + Radius * sinf(Angle);
	Points_Num++;

	if (Texture)
	{
		//texture coordinate setup
		TextureRect.origin	= ccp(TextureRect.origin.x / [Texture pixelsWide], TextureRect.origin.y / [Texture pixelsHigh]);
		TextureRect.size	= CGSizeMake(TextureRect.size.width / [Texture pixelsWide], TextureRect.size.height / [Texture pixelsHigh]);

		//centro
		TextCoord[0]		= TextureRect.origin.x + TextureRect.size.width / 2;	//centro in basso
		TextCoord[1]		= TextureRect.origin.y;
		i					= 1;

		while (i < Points_Num)//CIRCLE_SECTOR_NUM + 2)
		{
			if (i & 1)
			{//angolo TL
				TextCoord[2 * i + 0]	= TextureRect.origin.x;
				TextCoord[2 * i + 1]	= TextureRect.origin.y + TextureRect.size.height;
			}
			else
			{//angolo TR
				TextCoord[2 * i + 0]	= TextureRect.origin.x + TextureRect.size.width;
				TextCoord[2 * i + 1]	= TextureRect.origin.y + TextureRect.size.height;
			}
			i++;
		}
	}

	//openGL calls
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: GL_COLOR_ARRAY

	BOOL newBlend = (Blend.src != CC_BLEND_SRC) || (Blend.dst != CC_BLEND_DST);
	glDisableClientState(GL_COLOR_ARRAY);
	if (!Texture)
	{
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	
	//blend
	if( newBlend )	glBlendFunc( Blend.src, Blend.dst );
	//texture bind
	if (Texture)	glBindTexture(GL_TEXTURE_2D, [Texture name]);
	//vertex
	glVertexPointer(2, GL_FLOAT, 0, Vertex);
	//color
	glColor4ub(Color.r, Color.g, Color.b, Color.a);
	//texture coords
	if (Texture)	glTexCoordPointer(2, GL_FLOAT, 0, TextCoord);
	//draw
	glDrawArrays(GL_TRIANGLE_FAN, 0, Points_Num);
	if( newBlend )	glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
	// restore default GL state
	glEnableClientState(GL_COLOR_ARRAY);
	if (!Texture)
	{
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		free(TextCoord);
	}
	free(Vertex);
}

void drawTextureLine(CGPoint Start, CGPoint End, float Width, ccColor4B Color, ccBlendFunc Blend, CCTexture2D *Texture, CGRect TextureRect)
{
	if (CGPointEqualToPoint(Start, End))	return;

	float	Angle	= atan2f(End.y - Start.y, End.x - Start.x);
	float	Vertex[4 * 2];
	float	TextCoord[4 * 2];
	CGPoint	OffSet	= ccp(Width * cosf(Angle) / 2, Width * sinf(Angle) / 2);

	//vertex setup
	Vertex[0 * 2 + 0]	= Start.x - OffSet.y;//primo triangolo 0,1,2
	Vertex[0 * 2 + 1]	= Start.y + OffSet.x;
	Vertex[1 * 2 + 0]	= Start.x + OffSet.y;
	Vertex[1 * 2 + 1]	= Start.y - OffSet.x;
	Vertex[2 * 2 + 0]	= End.x   -	OffSet.y;
	Vertex[2 * 2 + 1]	= End.y   +	OffSet.x;
	Vertex[3 * 2 + 0]	= End.x   +	OffSet.y;
	Vertex[3 * 2 + 1]	= End.y   -	OffSet.x;//secondo triangolo 1,2,3

	if (Texture)
	{
		//texture coordinate setup
		TextureRect.origin	= ccp(TextureRect.origin.x / [Texture pixelsWide], TextureRect.origin.y / [Texture pixelsHigh]);
		TextureRect.size	= CGSizeMake(TextureRect.size.width / [Texture pixelsWide], TextureRect.size.height / [Texture pixelsHigh]);

		TextCoord[0 * 2 + 0]	= TextureRect.origin.x;
		TextCoord[0 * 2 + 1]	= TextureRect.origin.y + TextureRect.size.height;		
		TextCoord[1 * 2 + 0]	= TextureRect.origin.x;
		TextCoord[1 * 2 + 1]	= TextureRect.origin.y;
		TextCoord[2 * 2 + 0]	= TextureRect.origin.x + TextureRect.size.width;
		TextCoord[2 * 2 + 1]	= TextureRect.origin.y + TextureRect.size.height;
		TextCoord[3 * 2 + 0]	= TextureRect.origin.x + TextureRect.size.width;
		TextCoord[3 * 2 + 1]	= TextureRect.origin.y;
	}
	
	//openGL calls
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: GL_COLOR_ARRAY
	
	BOOL newBlend = (Blend.src != CC_BLEND_SRC) || (Blend.dst != CC_BLEND_DST);
	glDisableClientState(GL_COLOR_ARRAY);
	if (!Texture)
	{
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}

	//blend
	if( newBlend )	glBlendFunc( Blend.src, Blend.dst );
	//texture bind
	if (Texture)	glBindTexture(GL_TEXTURE_2D, [Texture name]);
	//vertex
	glVertexPointer(2, GL_FLOAT, 0, &Vertex);
	//color
	glColor4ub(Color.r, Color.g, Color.b, Color.a);
	//texture coords
	if (Texture)	glTexCoordPointer(2, GL_FLOAT, 0, &TextCoord);
	//draw
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	if( newBlend )	glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
	// restore default GL state
	glEnableClientState(GL_COLOR_ARRAY);
	if (!Texture)
	{
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	}
}

void drawTextureRect(CGPoint Center, CGPoint Scale, float Angle, ccColor4B Color, ccBlendFunc Blend, CCTexture2D *Texture, CGRect TextureRect)
{
	float	Vertex[4 * 2];
	float	TextCoord[4 * 2];
	CGRect	VertexRect	= CGRectMakeCenterSize(CGPointZero, CGSizeMake(TextureRect.size.width * Scale.x, TextureRect.size.height * Scale.y));

	CGPoint	BLPoint	= CGRectGetBottomLeftAngle(VertexRect);
	CGPoint	BRPoint	= CGRectGetBottomRightAngle(VertexRect);
	CGPoint	TLPoint	= CGRectGetTopLeftAngle(VertexRect);
	CGPoint	TRPoint	= CGRectGetTopRightAngle(VertexRect);

	BLPoint			= ccpAdd(CGPointRotate(BLPoint, Angle), Center);
	BRPoint			= ccpAdd(CGPointRotate(BRPoint, Angle), Center);
	TLPoint			= ccpAdd(CGPointRotate(TLPoint, Angle), Center);
	TRPoint			= ccpAdd(CGPointRotate(TRPoint, Angle), Center);

	//vertex setup
	Vertex[0 * 2 + 0]	= TLPoint.x;//primo triangolo 0,1,2
	Vertex[0 * 2 + 1]	= TLPoint.y;
	Vertex[1 * 2 + 0]	= BLPoint.x;
	Vertex[1 * 2 + 1]	= BLPoint.y;
	Vertex[2 * 2 + 0]	= TRPoint.x;
	Vertex[2 * 2 + 1]	= TRPoint.y;
	Vertex[3 * 2 + 0]	= BRPoint.x;
	Vertex[3 * 2 + 1]	= BRPoint.y;//secondo triangolo 1,2,3

	if (Texture)
	{
		//texture coordinate setup
		TextureRect.origin	= ccp(TextureRect.origin.x / [Texture pixelsWide], TextureRect.origin.y / [Texture pixelsHigh]);
		TextureRect.size	= CGSizeMake(TextureRect.size.width / [Texture pixelsWide], TextureRect.size.height / [Texture pixelsHigh]);
		
		TextCoord[0 * 2 + 0]	= TextureRect.origin.x;
		TextCoord[0 * 2 + 1]	= TextureRect.origin.y + TextureRect.size.height;		
		TextCoord[1 * 2 + 0]	= TextureRect.origin.x;
		TextCoord[1 * 2 + 1]	= TextureRect.origin.y;
		TextCoord[2 * 2 + 0]	= TextureRect.origin.x + TextureRect.size.width;
		TextCoord[2 * 2 + 1]	= TextureRect.origin.y + TextureRect.size.height;
		TextCoord[3 * 2 + 0]	= TextureRect.origin.x + TextureRect.size.width;
		TextCoord[3 * 2 + 1]	= TextureRect.origin.y;
	}
	
	//openGL calls
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: GL_COLOR_ARRAY
	
	BOOL newBlend = (Blend.src != CC_BLEND_SRC) || (Blend.dst != CC_BLEND_DST);
	glDisableClientState(GL_COLOR_ARRAY);
	if (!Texture)
	{
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}

	//blend
	if( newBlend )	glBlendFunc( Blend.src, Blend.dst );
	//texture bind
	if (Texture)	glBindTexture(GL_TEXTURE_2D, [Texture name]);
	//vertex
	glVertexPointer(2, GL_FLOAT, 0, &Vertex);
	//color
	glColor4ub(Color.r, Color.g, Color.b, Color.a);
	//texture coords
	if (Texture)	glTexCoordPointer(2, GL_FLOAT, 0, &TextCoord);
	//draw
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	if( newBlend )	glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);

	// restore default GL state
	glEnableClientState(GL_COLOR_ARRAY);
	if (!Texture)
	{
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	}
}
