//
//  CocosAddOn.h
//  Prova
//
//  Created by mad4chip on 25/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "cocos2d.h"

#define drawCircle(			Center, Radius, Color, Blend)						drawTextureCircleSector(Center, Radius, 0,			M_PI * 2, Color, Blend, nil,		(CGRect){(CGPoint){0, 0}, (CGSize){0, 0}})
#define drawCircleSector(	Center, Radius, startAngle, endAngle, Color, Blend)	drawTextureCircleSector(Center, Radius, startAngle, endAngle, Color, Blend, nil,		(CGRect){(CGPoint){0, 0}, (CGSize){0, 0}})
#define drawTextureCircle(	Center, Radius, Color, Blend, Texture, TextureRect)	drawTextureCircleSector(Center, Radius, 0,			M_PI * 2, Color, Blend, Texture,	TextureRect)
void drawTextureCircleSector(CGPoint Center, float Radius, float startAngle, float endAngle, ccColor4B Color, ccBlendFunc Blend, CCTexture2D *Texture, CGRect TextureRect);

#define	drawLine(Start, End, Width, Color, Blend)	void drawTextureLine(Start, End, Width Color, Blend, nil, (CGRect){(CGPoint){0, 0}, (CGSize){0, 0}})
void drawTextureLine(CGPoint Start, CGPoint End, float Width, ccColor4B Color, ccBlendFunc Blend, CCTexture2D *Texture, CGRect TextureRect);

void drawTextureRect(CGPoint Center, CGPoint Scale, float Angle, ccColor4B Color, ccBlendFunc Blend, CCTexture2D *Texture, CGRect TextureRect);