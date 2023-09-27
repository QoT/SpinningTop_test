
//  ANCMenuButton.h
//  Prova
//
//  Created by mad4chip on 29/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANCMenuButton.h"
#import	"SoundDescriptor.h"
#import "functions.h"
#import "CocosAddOn.h"

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ANCMenuButton
@synthesize backgroundImage = backgroundImage_;
@synthesize foregroundImage = foregroundImage_;
@synthesize activeArea		= activeArea_;
@synthesize target;
@synthesize Sound;
@synthesize DisabledSound;

@synthesize TintOnSelect		= TintOnSelect_;
@synthesize TintDisabled		= TintDisabled_;
@synthesize TransformOnSelect	= TransformOnSelect_;


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
		self.TransformOnSelect	= CGTransformNone;
		self.TintOnSelect		= ccc4(255,255,255,255);
		self.TintDisabled		= ccc4(255,255,255,255);
		Tint_					= ccc4(255,255,255,255);
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
		self.visible			= visible_;
		backgroundImage_		= [image retain];
		backgroundImage_.scaleX	= backgroundImage_.scaleX * scaleX_;
		backgroundImage_.scaleY	= backgroundImage_.scaleX * scaleY_;
		[self setActiveArea];
	}
}

-(void) setForegroundImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != foregroundImage_ )
	{
		[foregroundImage_ release];
		self.visible			= visible_;
		foregroundImage_		= [image retain];
		foregroundImage_.scaleX	= foregroundImage_.scaleX * scaleX_;
		foregroundImage_.scaleY	= foregroundImage_.scaleX * scaleY_;
		[self setActiveArea];
	}
}

-(void) setNormalImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != normalImage_ )
	{
		[normalImage_ release];
		self.visible		= visible_;
		normalImage_		= [image retain];
		normalImage_.scaleX	= normalImage_.scaleX * scaleX_;
		normalImage_.scaleY	= normalImage_.scaleX * scaleY_;
		[self setActiveArea];
	}
}

-(void) setSelectedImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != selectedImage_ )
	{
		[selectedImage_ release];
		self.visible			= visible_;
		selectedImage_			= [image retain];
		selectedImage_.scaleX	= selectedImage_.scaleX * scaleX_;
		selectedImage_.scaleY	= selectedImage_.scaleX * scaleY_;
		[self setActiveArea];
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

-(void)setIsEnabled: (BOOL)Enabled
{
	[super setIsEnabled: Enabled];
	if (Enabled)	[self applyOnEnabledTransform];
	else			[self applyOnDisabledTransform];
}

- (void) setOpacity: (GLubyte)opacity
{
	[super setOpacity:opacity];
	[foregroundImage_ setOpacity:opacity];
	[backgroundImage_ setOpacity:opacity];	
}

-(void)applyOnDisabledTransform
{
	Tint_				= [normalImage_ colorAndOpacity];
	[normalImage_		setColorAndOpacity: TintDisabled_];
	[foregroundImage_	setColorAndOpacity: TintDisabled_];
	[backgroundImage_	setColorAndOpacity: TintDisabled_];
	[disabledImage_		setColorAndOpacity: TintDisabled_];
}

-(void)applyOnEnabledTransform
{
	[normalImage_		setColorAndOpacity: Tint_];
	[selectedImage_		setColorAndOpacity: ccc4(255, 255, 255, 255)];
	[foregroundImage_	setColorAndOpacity: ccc4(255, 255, 255, 255)];
	[backgroundImage_	setColorAndOpacity: ccc4(255, 255, 255, 255)];
}

-(void)applyOnSelectTransform
{
	//cambio il colore
	Tint_				= [normalImage_ colorAndOpacity];
	[normalImage_		setColorAndOpacity: ccColor4BMultiply(Tint_, TintOnSelect_)];
	[selectedImage_		setColorAndOpacity: TintOnSelect_];
	[foregroundImage_	setColorAndOpacity: TintOnSelect_];
	[backgroundImage_	setColorAndOpacity: TintOnSelect_];

	[self setTransform: TransformOnSelect_];
}

-(void)applyOnUnselectTransform
{
	//cambio il colore
	[normalImage_		setColorAndOpacity: Tint_];
	[selectedImage_		setColorAndOpacity: ccc4(255, 255, 255, 255)];
	[foregroundImage_	setColorAndOpacity: ccc4(255, 255, 255, 255)];
	[backgroundImage_	setColorAndOpacity: ccc4(255, 255, 255, 255)];

	[self setTransform: [self getTransform]];
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
	[normalImage_		setColor: color];
	[selectedImage_		setColor: color];
	[disabledImage_		setColor: color];
	[foregroundImage_	setColor: color];
	[backgroundImage_	setColor: color];	
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
	
	[super setScaleX: newScale];
	[super setScaleY: newScale];
}

-(void)setScaleY:(float)newScale
{
	normalImage_.scaleY		= (normalImage_.scaleY / scaleY_ ) * newScale;
	selectedImage_.scaleY	= (selectedImage_.scaleY / scaleY_) * newScale;
	disabledImage_.scaleY	= (disabledImage_.scaleY / scaleY_) * newScale;
	foregroundImage_.scaleY = (foregroundImage_.scaleY / scaleY_) * newScale;
	backgroundImage_.scaleY	= (backgroundImage_.scaleY / scaleY_) * newScale;
	[super setScaleY: newScale];
}

-(void)setScaleX:(float)newScale
{
	normalImage_.scaleX		= (normalImage_.scaleX / scaleX_ ) * newScale;
	selectedImage_.scaleX	= (selectedImage_.scaleX / scaleX_) * newScale;
	disabledImage_.scaleX	= (disabledImage_.scaleX / scaleX_) * newScale;
	foregroundImage_.scaleX = (foregroundImage_.scaleX / scaleX_) * newScale;
	backgroundImage_.scaleX	= (backgroundImage_.scaleX / scaleX_) * newScale;
	[super setScaleX: newScale];
}

-(void)setSkewX:(float)newSkew
{
	normalImage_.skewX		= (normalImage_.skewX		/ skewX_) * newSkew;
	selectedImage_.skewX	= (selectedImage_.skewX		/ skewX_) * newSkew;
	disabledImage_.skewX	= (disabledImage_.skewX		/ skewX_) * newSkew;
	foregroundImage_.skewX	= (foregroundImage_.skewX	/ skewX_) * newSkew;
	backgroundImage_.skewX	= (backgroundImage_.skewX	/ skewX_) * newSkew;
	[super setSkewX: newSkew];
}

-(void)setSkewY:(float)newSkew
{
	normalImage_.skewY		= (normalImage_.skewY		/ skewY_) * newSkew;
	selectedImage_.skewY	= (selectedImage_.skewY		/ skewY_) * newSkew;
	disabledImage_.skewY	= (disabledImage_.skewY		/ skewY_) * newSkew;
	foregroundImage_.skewY	= (foregroundImage_.skewY	/ skewY_) * newSkew;
	backgroundImage_.skewY	= (backgroundImage_.skewY	/ skewY_) * newSkew;
	[super setSkewY: newSkew];
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
