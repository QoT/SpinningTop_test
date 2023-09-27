
//  ANCMenuButton.h
//  Prova
//
//  Created by mad4chip on 29/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANCMenuButton.h"
#import	"SoundDescriptor.h"
#import "functions.h"

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ANCMenuButton
@synthesize backgroundImage = backgroundImage_;
@synthesize foregroundImage = foregroundImage_;
@synthesize activeArea		= activeArea_;
@synthesize target;
@synthesize Sound;
@synthesize DisabledSound;

@synthesize Tint = Tint_;
@synthesize TintOnSelect = TintOnSelect_;
@synthesize TintDisabled = TintDisabled_;
@synthesize ScaleOnSelect = ScaleOnSelect_;
@synthesize RotationOnSelect = RotationOnSelect_;


-(void)setSound:(SoundDescriptor*)NewSound
{
	[Sound release];
	Sound	= [NewSound retain];
}

-(void)setDisabledSound:(SoundDescriptor*)NewSound
{
	[DisabledSound release];
	DisabledSound	= [NewSound retain];
}

-(void)setTarget:(id)NewTarget
{
	[target release];
	target	= [NewTarget retain];
}

+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector
{
	return [[[self alloc] initFromNormalSprite: normalSprite selectedSprite: selectedSprite disabledSprite: disabledSprite target: target selector: selector] autorelease];
}

-(id) initFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target_ selector:(SEL)selector
{
	if( (self=[super initWithTarget:target_ selector:selector]) )
	{
		self.target				= target_;
		self.normalImage		= normalSprite;
		self.selectedImage		= selectedSprite;
		self.disabledImage		= disabledSprite;
		[self setActiveArea];
		activeArea_				= CGRectZero;
		self.ScaleOnSelect		= ccp(1,1);
		self.RotationOnSelect	= 0;
		self.TintOnSelect		= ccc3(255,255,255);
		self.TintDisabled		= ccc3(0,0,0);
		self.Tint				= ccc3(0,0,0); 
		self.Sound				= nil;
		self.DisabledSound		= nil; 
	}
	return self;
}

-(void) setBackgroundImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != backgroundImage_ )
	{
		[backgroundImage_ release];
		backgroundImage_	= [image retain];
		[self setActiveArea];
		backgroundImage_.scaleX	= backgroundImage_.scaleX * scaleX_;
		backgroundImage_.scaleY	= backgroundImage_.scaleX * scaleY_;
	}
}

-(void) setForegroundImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != foregroundImage_ )
	{
		[foregroundImage_ release];
		foregroundImage_	= [image retain];
		[self setActiveArea];
		foregroundImage_.scaleX	= foregroundImage_.scaleX * scaleX_;
		foregroundImage_.scaleY	= foregroundImage_.scaleX * scaleY_;
	}
}

-(void) setNormalImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != normalImage_ )
	{
		[normalImage_ release];
		image.visible	= YES;
		normalImage_	= [image retain];
		normalImage_.scaleX	= normalImage_.scaleX * scaleX_;
		normalImage_.scaleY	= normalImage_.scaleX * scaleY_;
	}
}

-(void) setSelectedImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != selectedImage_ )
	{
		[selectedImage_ release];
		image.visible	= NO;
		selectedImage_	= [image retain];
		selectedImage_.scaleX	= selectedImage_.scaleX * scaleX_;
		selectedImage_.scaleY	= selectedImage_.scaleX * scaleY_;
	}
}

-(void) setDisabledImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != disabledImage_ )
	{
		[disabledImage_ release];
		image.visible	= NO;
		disabledImage_	= [image retain];
		disabledImage_.scaleX	= disabledImage_.scaleX * scaleX_;
		disabledImage_.scaleY	= disabledImage_.scaleX * scaleY_;
	}
}

-(void)setPosition:(CGPoint) Position
{
	[super setPosition: Position];
	Position	= [self.parent convertToWorldSpace: Position];
	Position	= [normalImage_.parent convertToNodeSpaceAR: Position];
	[normalImage_		setPosition: Position]; 	[selectedImage_		setPosition: Position];
	[disabledImage_		setPosition: Position];
	[backgroundImage_	setPosition: Position];
	[foregroundImage_	setPosition: Position];
	[self setActiveArea];
}

-(void)setAnchorPoint:(CGPoint) Point
{
	[super setAnchorPoint: Point];
	[normalImage_		setAnchorPoint: Point];
	[selectedImage_		setAnchorPoint: Point];
	[disabledImage_		setAnchorPoint: Point];
	[backgroundImage_	setAnchorPoint: Point];
	[foregroundImage_	setAnchorPoint: Point];
	[self setActiveArea];
}

-(void)setActiveArea
{
	CGRect	Rectangle	= normalImage_.boundingBoxInPixels;
	if (selectedImage_)		Rectangle	= CGRectUnion(Rectangle, selectedImage_.boundingBoxInPixels);
	if (disabledImage_)		Rectangle	= CGRectUnion(Rectangle, disabledImage_.boundingBoxInPixels);
	if (backgroundImage_)	Rectangle	= CGRectUnion(Rectangle, backgroundImage_.boundingBoxInPixels);
	if (foregroundImage_)	Rectangle	= CGRectUnion(Rectangle, foregroundImage_.boundingBoxInPixels);
	[self setContentSize: CGSizeMult(Rectangle.size, 1.0f/CC_CONTENT_SCALE_FACTOR())];
}

-(CGRect)rect
{
	if ((activeArea_.size.width != 0) && (activeArea_.size.height != 0))
			return	activeArea_;
	else	return [super rect];
}

-(void) setVisible: (BOOL)NewVisible
{
	backgroundImage_.visible	= NewVisible;
	foregroundImage_.visible	= NewVisible;
	super.visible				= NewVisible;

	if (!NewVisible)
	{
		selectedImage_.visible	= false;
		normalImage_.visible	= false;
		disabledImage_.visible	= false;
	}
	else if (!isEnabled_)
	{
		selectedImage_.visible	= false;
		normalImage_.visible	= false;
		disabledImage_.visible	= true;
	}
	else if (isSelected_)
	{
		selectedImage_.visible	= true;
		normalImage_.visible	= false;
		disabledImage_.visible	= false;
	}
	else
	{
		selectedImage_.visible	= false;
		normalImage_.visible	= true;
		disabledImage_.visible	= false;
	}
}

-(void)activate
{
	[Sound playForTarget:target loop:0];
	[super activate];
}

-(void) selected
{//permette l'uso di animazione e ANCSprite
	//modifiche marina
	if (!isSelected_)
		[self applyOnSelectTransform];

	[super selected];
	if (!normalImage_.visible)		[normalImage_	pauseSchedulerAndActions];
	if (!selectedImage_.visible)	[selectedImage_ pauseSchedulerAndActions];
	if (!disabledImage_.visible)	[disabledImage_ pauseSchedulerAndActions];
}

-(void) unselected
{
	if (isSelected_)
		[self applyOnUnselectTransform];
	
	[super unselected];
	if (normalImage_.visible)		[normalImage_	resumeSchedulerAndActions];
	if (selectedImage_.visible)		[selectedImage_ resumeSchedulerAndActions];
	if (disabledImage_.visible)		[disabledImage_ resumeSchedulerAndActions];
}

-(void)enable
{
	self.isEnabled				= true;
}

-(void)disable
{
	self.isEnabled				= false;
	[self applyOnDisabledTransform];
}

- (void) setOpacity: (GLubyte)opacity
{
	[super setOpacity:opacity];
	[foregroundImage_ setOpacity:opacity];
	[backgroundImage_ setOpacity:opacity];	
}

-(void)applyOnDisabledTransform
{
	[normalImage_		setColor: TintDisabled_];
	[foregroundImage_	setColor: TintDisabled_];
	[backgroundImage_	setColor: TintDisabled_];
	[disabledImage_		setColor: TintDisabled_];
}
-(void)applyOnSelectTransform
{
	//cambio il colore
	Tint_				= [normalImage_ color];
	[normalImage_		setColor:ccc3( (([normalImage_ color].r * TintOnSelect_.r)/ 255),(([normalImage_ color].g * TintOnSelect_.g)/ 255),(([normalImage_ color].b * TintOnSelect_.b)/ 255))];
	[selectedImage_		setColor: TintOnSelect_];
	[foregroundImage_	setColor: TintOnSelect_];
	[backgroundImage_	setColor: TintOnSelect_];

	//cambio la scala
	[self setScaleX:	(scaleX_ * ScaleOnSelect_.x)];
	[self setScaleY:	(scaleY_ * ScaleOnSelect_.y)];
	
	//cambio la rotazione
	[self setRotation:	(rotation_ + RotationOnSelect_)];
}

-(void)applyOnUnselectTransform
{
	//cambio il colore
	[normalImage_		setColor: Tint_];
	[selectedImage_		setColor: ccc3(255, 255, 255)];
	[foregroundImage_	setColor: ccc3(255, 255, 255)];
	[backgroundImage_	setColor: ccc3(255, 255, 255)];
	//[self setColor: Tint_];
	
	//cambio la scala
	[self setScaleX:	(scaleX_ / ScaleOnSelect_.x)];
	[self setScaleY:	(scaleY_ / ScaleOnSelect_.y)];
	
	//cambio la rotazione
	[self setRotation:	(rotation_ - RotationOnSelect_)];
}

-(void) setRotation:(float)rotation
{
	[foregroundImage_	setRotation: rotation];
	[backgroundImage_	setRotation: rotation];
	[normalImage_		setRotation: rotation];
	[disabledImage_		setRotation: rotation];
	[selectedImage_		setRotation: rotation];
	[super setRotation: rotation];
}

-(void) setColor:(ccColor3B)color
{
	[normalImage_	 setColor:color];
	[selectedImage_	 setColor:color];
	[disabledImage_	 setColor:color];
	[foregroundImage_ setColor:color];
	[backgroundImage_ setColor:color];	
}

-(void)setScale:(float)newScale
{
	normalImage_.scaleX		= (normalImage_.scaleX / scaleX_ ) * newScale;
	normalImage_.scaleY		= (normalImage_.scaleY / scaleY_ ) * newScale;
	
	selectedImage_.scaleX	= (selectedImage_.scaleX / scaleX_) * newScale;
	selectedImage_.scaleY	= (selectedImage_.scaleY / scaleY_) * newScale;
	
	disabledImage_.scaleX	= (disabledImage_.scaleX / scaleX_) * newScale;
	disabledImage_.scaleY	= (disabledImage_.scaleY / scaleY_) * newScale;
	
	foregroundImage_.scaleX = (foregroundImage_.scaleX / scaleX_) * newScale;
	foregroundImage_.scaleY = (foregroundImage_.scaleY / scaleY_) * newScale;
	
	backgroundImage_.scaleX	= (backgroundImage_.scaleX / scaleX_) * newScale;
	backgroundImage_.scaleY	= (backgroundImage_.scaleY / scaleY_) * newScale;
	
	scaleX_					= newScale;
	scaleY_					= newScale;
}

-(void)setScaleY:(float)newScale
{
	normalImage_.scaleY		= (normalImage_.scaleY / scaleY_ ) * newScale;
	selectedImage_.scaleY	= (selectedImage_.scaleY / scaleY_) * newScale;
	disabledImage_.scaleY	= (disabledImage_.scaleY / scaleY_) * newScale;
	foregroundImage_.scaleY = (foregroundImage_.scaleY / scaleY_) * newScale;
	backgroundImage_.scaleY	= (backgroundImage_.scaleY / scaleY_) * newScale;
	scaleY_					= newScale;
}

-(void)setScaleX:(float)newScale
{
	normalImage_.scaleX		= (normalImage_.scaleX / scaleX_ ) * newScale;
	selectedImage_.scaleX	= (selectedImage_.scaleX / scaleX_) * newScale;
	disabledImage_.scaleX	= (disabledImage_.scaleX / scaleX_) * newScale;
	foregroundImage_.scaleX = (foregroundImage_.scaleX / scaleX_) * newScale;
	backgroundImage_.scaleX	= (backgroundImage_.scaleX / scaleX_) * newScale;
	scaleX_					= newScale;
}

-(void)cleanup
{
	[target release];//nel caso il target è un antenato del bottone evita un riferimento circolare che impedisce la deallocazione
	target	= nil;
	[super cleanup];
}

- (void) dealloc
{
	[normalImage_ release];
	[selectedImage_ release];
	[disabledImage_ release];	
	[backgroundImage_ release];
	[foregroundImage_ release];
	[target release];
	[Sound release];
	[DisabledSound release];
	[super dealloc];
}

-(void)disabledClick
{
	[DisabledSound playForTarget:target loop:0];
}

@end
