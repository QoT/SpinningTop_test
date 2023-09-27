//
//  CCProgressBar.m
//  iMoonlightsHD
//
//  Created by macbook on 10/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCProgressBar.h"
#import "CocosAddOn.h"
#import "functions.h"
#import "ccConfig.h"
#import "CGPointExtension.h"
#import "CCSpriteScale9.h"

@interface CCProgressBar (Private)
-(void)update;
@end


@implementation CCProgressBar

@synthesize fg,bg,progress;

-(id)initWithBgSprite:(CCSpriteScale9*)b andFgSprite:(CCSpriteScale9*)f andSize:(CGSize)s andMargin:(CGSize)m
{
	if (( self = [super init] ))
	{
		bg					= b;
		fg					= f;
		self.anchorPoint	= ccp(0.5f,0.5f);
		animAngle			= 0;
		margin				= m;
		
		finalTint			= ccc4(255,255,255,255);
		initialTint			= ccc4(255,255,255,255);
		progress			= 0.0f;
		[self setContentSize:s];//chiama update
		[self addChild:b];
		[self addChild:f];
	}
	return self;
}

+(id)progressBarWithBgSprite:(CCSpriteScale9*)b andFgSprite:(CCSpriteScale9*)f andSize:(CGSize)s andMargin:(CGSize)m 
{
	return [[[self alloc] initWithBgSprite:b andFgSprite:f andSize:s andMargin:m] autorelease];
}


-(void)update
{
	[bg adaptiveScale9:contentSize_];
	CGSize s		= contentSize_;
    s.height		= (s.height - 2 * margin.height);
	s.width			= s.height + (s.width - 2 * margin.width - s.height) * progress;
	
	//if (s.width<s.height) s.width=s.height;
	[fg adaptiveScale9:s];
	[self updateColorProgress];
	bg.position		= ccp(bg.contentSize.width * bg.scaleX * 0.5f, bg.contentSize.height * bg.scaleY * 0.5f);
	
	float minX		= margin.width+fg.contentSize.width*fg.scaleX*0.5f;
	float maxX		= bg.contentSize.width*bg.scaleX-minX;
	fg.position		= ccp((minX+maxX) *0.5f-cos(animAngle)*0.5f*(maxX-minX),margin.height+fg.contentSize.height*fg.scaleY*0.5f);
	//fg.position=ccp(margin.width+fg.contentSize.width*fg.scaleX*0.5f,margin.height+fg.contentSize.height*fg.scaleY*0.5f);
}

-(void)setProgress:(float)p 
{
	progress	= p;
	
	if (progress < 0.0f) 
		progress	= 0.0f;
	else if (progress > 1.0f) 
		progress	= 1.0f;
	
	[self update];
}

-(void)setContentSize:(CGSize)s {
	[super setContentSize:s];
	[self update];
}

-(void)startAnimation 
{
	[self schedule:@selector(tick:)];
}

-(void)stopAnimation 
{
	[self unschedule:@selector(tick:)];
	animAngle	= 0;
}

-(void)tick:(ccTime)dt 
{
	animAngle	+= dt*5;
	[self update];
}

-(void)updateColorProgress
{
	ccColor4B color = ccColor4BSub(initialTint, finalTint);
	color = ccColor4BMultiplyForNumber(color, 1 - progress);
	color = ccColor4BSub(initialTint, color);
	fg.colorAndOpacity = color;
}

-(void)setFinalTint:(ccColor4B)newFinalTint
{
	finalTint		= newFinalTint;
	self.progress	= progress;
}

-(void)setFinalColor:(ccColor3B)newFinalColor
{
	finalTint = ccc4(newFinalColor.r, newFinalColor.g, newFinalColor.b, 255);
}

-(void)setOpacity:(GLubyte)opacity 
{
    fg.opacity=opacity;
    bg.opacity=opacity;
}

- (void) dealloc 
{
	[super dealloc];
}
@end
