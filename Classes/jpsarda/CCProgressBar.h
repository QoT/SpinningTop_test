//
//  CCProgressBar.h
//  iMoonlightsHD
//
//  Created by macbook on 10/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNode.h"
#import "CCProtocols.h"


@class CCSpriteScale9;

@interface CCProgressBar : CCNode 
{
	CCSpriteScale9	*bg,*fg;
	ccColor4B		finalTint;
	ccColor4B		initialTint;
	CGSize			margin;
	float			progress;
	float			animAngle;
}

@property (readonly,atomic,assign) CCSpriteScale9	*bg;
@property (readonly,atomic,assign) CCSpriteScale9	*fg;
@property (readonly,atomic)		   float			progress;


+(id)progressBarWithBgSprite:(CCSpriteScale9*)b andFgSprite:(CCSpriteScale9*)f andSize:(CGSize)s andMargin:(CGSize)m;
-(id)initWithBgSprite:(CCSpriteScale9*)b andFgSprite:(CCSpriteScale9*)f andSize:(CGSize)s andMargin:(CGSize)m;
-(void)setProgress:(float)p;
-(void)startAnimation;
-(void)stopAnimation;
-(void)setOpacity:(GLubyte)opacity;
-(void)updateColorProgress;
-(void)setFinalTint:(ccColor4B)newFinalTint;
@end
