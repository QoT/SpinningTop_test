//
//  CocosAddOn.m
//  Prova
//
//  Created by mad4chip on 25/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CocosAddOn.h"
#import "ANCMenuAdvanced.h"

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCArray (ANCAddOn)
-(void) swapObjectAtIndex: (NSUInteger)index1 andObjectAtIndex: (NSUInteger)index2
{
	if ((index1 >= data->num) ||
		(index2 >= data->num))
			return;
	id	temp	= data->arr[index1];
	data->arr[index1]	= data->arr[index2];
	data->arr[index2]	= temp;
}

-(void) sortUsingSelector: (SEL)comparator
{
	bool				Finished	= true;
	NSInteger			Return;
	NSMethodSignature	*Signature	= [CCMenuItem instanceMethodSignatureForSelector: comparator];	
	NSInvocation		*Invocation	= [NSInvocation invocationWithMethodSignature: Signature];

	NSAssert([Signature methodReturnLength] == sizeof(Return), @"Unexpected return type");
	[Invocation setSelector: comparator];
	for (int i = 0; i < data->num; i++)
	{
		for (int j = i + 1; j < data->num; j++)
		{
			[Invocation setArgument: &(data->arr[j]) atIndex:2];//Indices 0 and 1 indicate the hidden arguments self and _cmd
			[Invocation invokeWithTarget: data->arr[i]];
			[Invocation getReturnValue: &Return];
			if (Return == NSOrderedAscending)
			{//data->arr[i] > data->arr[j] li scambio
				[self swapObjectAtIndex: i andObjectAtIndex: j];
				Finished	= false;
			}
		}
		if (Finished)	break;
	}
}

-(NSString*)description
{
	NSString	*Description	= [NSString stringWithFormat:@"<%@ = %08X>\n", [self class], (unsigned int)self];
	id Element;
	CCARRAY_FOREACH(self, Element)
	Description	= [Description stringByAppendingFormat: @"%@\n", [Element description]];
	return Description;
}
@end


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCNode (CCNodeAddOn)
-(void)setColorAndOpacity: (ccColor4B)color
{
	NSAssert1([self respondsToSelector: @selector(setColor:)] && [self respondsToSelector: @selector(setOpacity:)], @"Cannot set color or opacity for %@!!", [self description]);
	[(CCNode <CCRGBAProtocol>*)self setColor: ccc3(color.r, color.g, color.b)];
	[(CCNode <CCRGBAProtocol>*)self setOpacity: color.a];
}

-(ccColor4B)colorAndOpacity
{
	NSAssert1([self respondsToSelector: @selector(color)] && [self respondsToSelector: @selector(opacity)], @"Cannot get color or opacity for %@!!", [self description]);
	ccColor3B	color	= [(CCNode <CCRGBAProtocol>*)self color];
	return ccc4(color.r, color.g, color.b, [(CCNode <CCRGBAProtocol>*)self opacity]);
}

-(void) setTransform: (CGTransform)Transform
{
	scaleX_		= Transform.scaleX;
	scaleY_		= Transform.scaleY;
	rotation_	= Transform.rotation;
	skewX_		= Transform.skewX;
	skewY_		= Transform.skewY;
	
	isTransformDirty_ = isInverseDirty_ = YES;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	isTransformGLDirty_ = YES;
#endif	
}

-(CGTransform) getTransform
{
	return (CGTransform){scaleX_, scaleY_, rotation_, skewX_, skewY_, false, false};
}

-(void)scaleToSize: (CGSize)NewSize keepAspect: (bool)Aspect
{
	NSAssert((NewSize.height != 0) && (NewSize.width != 0), @"scaleToSize: height and width must not be 0");
	float	ScaleX	= NewSize.width / [self width];
	float	ScaleY	= NewSize.height / [self height];
	if (Aspect)
		ScaleY		= ScaleX	= fmin(ScaleX, ScaleY);
	self.scaleX		= ScaleX;
	self.scaleY		= ScaleY;
}

-(void)showNode
{
	self.visible	= true;
	//isRunning?
	if (hidden_)
	{
		hidden_		= false;//prima di chiamare onEnter
		[self onEnter];
		[self onEnterTransitionDidFinish];
	}
}

-(void)hideNode
{
	self.visible	= false;
	//isRunning?
	if(!hidden_)
	{
		[self onExit];
		hidden_		= true;//dopo aver chiamato onExit
	}
}

-(CGFloat) width 
{
	float	Return	= [self boundingBoxInPixels].size.width;
	if (CC_CONTENT_SCALE_FACTOR() == 1)
			return	Return;
	else	return	Return / CC_CONTENT_SCALE_FACTOR();
}

-(CGFloat) height
{
	float	Return	= [self boundingBoxInPixels].size.height / CC_CONTENT_SCALE_FACTOR();
	if (CC_CONTENT_SCALE_FACTOR() == 1)
			return	Return;
	else	return	Return / CC_CONTENT_SCALE_FACTOR();
}

-(CGPoint)convertParentToNodeSpace:(CGPoint)parentPoint
{
	CGPoint ret;
	if( CC_CONTENT_SCALE_FACTOR() == 1 )
		ret = CGPointApplyAffineTransform(parentPoint, [self parentToNodeTransform]);
	else {
		ret = ccpMult( parentPoint, CC_CONTENT_SCALE_FACTOR() );
		ret = CGPointApplyAffineTransform(ret, [self parentToNodeTransform]);
		ret = ccpMult( ret, 1/CC_CONTENT_SCALE_FACTOR() );
	}
	
	return ret;
}

-(CGPoint)convertNodeToParentSpace:(CGPoint)nodePoint
{
	CGPoint ret;
	if( CC_CONTENT_SCALE_FACTOR() == 1 )
		ret = CGPointApplyAffineTransform(nodePoint, [self nodeToParentTransform]);
	else {
		ret = ccpMult( nodePoint, CC_CONTENT_SCALE_FACTOR() );
		ret = CGPointApplyAffineTransform(ret, [self nodeToParentTransform]);
		ret = ccpMult( ret, 1/CC_CONTENT_SCALE_FACTOR() );
	}
	
	return ret;
}

-(CGPoint)convertParentToNodeSpaceAR:(CGPoint)worldPoint
{
	CGPoint nodePoint = [self convertParentToNodeSpace:worldPoint];
	CGPoint anchorInPoints;
	if( CC_CONTENT_SCALE_FACTOR() == 1 )
			anchorInPoints = anchorPointInPixels_;
	else	anchorInPoints = ccpMult( anchorPointInPixels_, 1/CC_CONTENT_SCALE_FACTOR() );
	return ccpSub(nodePoint, anchorInPoints);
}

-(CGPoint)convertNodeToParentSpaceAR:(CGPoint)nodePoint
{
	CGPoint anchorInPoints;
	if( CC_CONTENT_SCALE_FACTOR() == 1 )
			anchorInPoints = anchorPointInPixels_;
	else	anchorInPoints = ccpMult( anchorPointInPixels_, 1/CC_CONTENT_SCALE_FACTOR() );
	nodePoint = ccpAdd(nodePoint, anchorInPoints);
	return [self convertNodeToParentSpace:nodePoint];
}

-(CGRect)convertRectNodeToParentSpace: (CGRect) Rectangle
{
	CGPoint	BottomLeft	= [self convertNodeToParentSpace: ccp(CGRectGetMinX(Rectangle), CGRectGetMinY(Rectangle))];
	CGPoint	TopRight	= [self convertNodeToParentSpace: ccp(CGRectGetMaxX(Rectangle), CGRectGetMaxY(Rectangle))];
	return CGRectMake(BottomLeft.x, BottomLeft.y, TopRight.x - BottomLeft.x, TopRight.y - BottomLeft.y);	
}

-(CGRect)convertRectParentToNodeSpace: (CGRect) Rectangle
{
	CGPoint	BottomLeft	= [self convertParentToNodeSpace: ccp(CGRectGetMinX(Rectangle), CGRectGetMinY(Rectangle))];
	CGPoint	TopRight	= [self convertParentToNodeSpace: ccp(CGRectGetMaxX(Rectangle), CGRectGetMaxY(Rectangle))];
	return CGRectMake(BottomLeft.x, BottomLeft.y, TopRight.x - BottomLeft.x, TopRight.y - BottomLeft.y);	
}

-(CGRect)convertRectNodeToParentSpaceAR: (CGRect) Rectangle
{
	CGPoint	BottomLeft	= [self convertNodeToParentSpaceAR: ccp(CGRectGetMinX(Rectangle), CGRectGetMinY(Rectangle))];
	CGPoint	TopRight	= [self convertNodeToParentSpaceAR: ccp(CGRectGetMaxX(Rectangle), CGRectGetMaxY(Rectangle))];
	return CGRectMake(BottomLeft.x, BottomLeft.y, TopRight.x - BottomLeft.x, TopRight.y - BottomLeft.y);	
}

-(CGRect)convertRectParentToNodeSpaceAR: (CGRect) Rectangle
{
	CGPoint	BottomLeft	= [self convertParentToNodeSpaceAR: ccp(CGRectGetMinX(Rectangle), CGRectGetMinY(Rectangle))];
	CGPoint	TopRight	= [self convertParentToNodeSpaceAR: ccp(CGRectGetMaxX(Rectangle), CGRectGetMaxY(Rectangle))];
	return CGRectMake(BottomLeft.x, BottomLeft.y, TopRight.x - BottomLeft.x, TopRight.y - BottomLeft.y);	
}

-(CGRect)convertRectToWorldSpace: (CGRect) Rectangle
{
	CGPoint	BottomLeft	= [self convertToWorldSpace: ccp(CGRectGetMinX(Rectangle), CGRectGetMinY(Rectangle))];
	CGPoint	TopRight	= [self convertToWorldSpace: ccp(CGRectGetMaxX(Rectangle), CGRectGetMaxY(Rectangle))];
	return CGRectMake(BottomLeft.x, BottomLeft.y, TopRight.x - BottomLeft.x, TopRight.y - BottomLeft.y);
}

-(CGRect)convertRectToNodeSpace: (CGRect) Rectangle
{
	CGPoint	BottomLeft	= [self convertToNodeSpace: ccp(CGRectGetMinX(Rectangle), CGRectGetMinY(Rectangle))];
	CGPoint	TopRight	= [self convertToNodeSpace: ccp(CGRectGetMaxX(Rectangle), CGRectGetMaxY(Rectangle))];
	return CGRectMake(BottomLeft.x, BottomLeft.y, TopRight.x - BottomLeft.x, TopRight.y - BottomLeft.y);
}

-(CGRect)convertRectToWorldSpaceAR: (CGRect) Rectangle
{
	CGPoint	BottomLeft	= [self convertToWorldSpaceAR: ccp(CGRectGetMinX(Rectangle), CGRectGetMinY(Rectangle))];
	CGPoint	TopRight	= [self convertToWorldSpaceAR: ccp(CGRectGetMaxX(Rectangle), CGRectGetMaxY(Rectangle))];
	return CGRectMake(BottomLeft.x, BottomLeft.y, TopRight.x - BottomLeft.x, TopRight.y - BottomLeft.y);
}

-(CGRect)convertRectToNodeSpaceAR: (CGRect) Rectangle
{
	CGPoint	BottomLeft	= [self convertToNodeSpaceAR: ccp(CGRectGetMinX(Rectangle), CGRectGetMinY(Rectangle))];
	CGPoint	TopRight	= [self convertToNodeSpaceAR: ccp(CGRectGetMaxX(Rectangle), CGRectGetMaxY(Rectangle))];
	return CGRectMake(BottomLeft.x, BottomLeft.y, TopRight.x - BottomLeft.x, TopRight.y - BottomLeft.y);
}
@end


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCLayer (CCLayerAddOn)
-(void)disableMenus
{
	ANCMenuAdvanced *child;
	CCARRAY_FOREACH(children_, child)
	if ([child isKindOfClass:[ANCMenuAdvanced class]])
		child.isDisabled = true;
}

-(void)enableMenus
{
	ANCMenuAdvanced *child;
	CCARRAY_FOREACH(children_, child)
	if ([child isKindOfClass:[ANCMenuAdvanced class]])
		child.isDisabled = false;
}
@end


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCSprite (CCSpriteAddOn)
-(void)setColorAndOpacity: (ccColor4B)color
{
	[self setColor: ccc3(color.r, color.g, color.b)];
	[self setOpacity: color.a];
}

-(void)setScaleAndFlip: (CGPoint)Value
{
	[self setScaleAndFlipX: Value.x];
	[self setScaleAndFlipY: Value.y];
}

-(void)setScaleAndFlipX: (float)Value
{
	if (Value < 0)
	{
		self.flipX	= true;
		self.scaleX	= -Value;
	}
	else
	{
		self.flipX	= false;
		self.scaleX	= Value;
	}	
}

-(void)setScaleAndFlipY: (float)Value
{
	if (Value < 0)
	{
		self.flipY= true;
		self.scaleY	= -Value;
	}
	else
	{
		self.flipY	= false;
		self.scaleY	= Value;
	}	
}

//ritornano l'effettive misure dell'area non trasparente dell'immagine
-(CGFloat) width 
{
	return rect_.size.width;
}

-(CGFloat) untrimmedWidth
{
	float	Return	= [self boundingBoxInPixels].size.width;
	if (CC_CONTENT_SCALE_FACTOR() == 1)
			return  Return;
	else	return  Return / CC_CONTENT_SCALE_FACTOR();
}

-(CGFloat) height
{
    return rect_.size.height;
}

-(CGFloat) untrimmedHeight
{
	float	Return	= [self boundingBoxInPixels].size.height;
	if (CC_CONTENT_SCALE_FACTOR() == 1)
			return  Return;
	else	return  Return / CC_CONTENT_SCALE_FACTOR();	
}

-(void)setUnflippedOffsetPositionFromCenter: (CGPoint)Offset
{
	unflippedOffsetPositionFromCenter_	= Offset;
}

-(CGPoint)unflippedOffsetPositionFromCenter
{
	return unflippedOffsetPositionFromCenter_;
}

//ritorna un oggetto di tipo CCSprite indipendentemente dal tipo di oggetto che si copia
-(id) copyWithZone: (NSZone*) zone
{	
	CCSprite *Sprite	= [[CCSprite allocWithZone: zone] init];//[self class] per copiare con lo stesso tipo di oggetto
//	[Sprite setTexture: texture_];
	[Sprite setDisplayFrame: [self displayedFrame]];
	Sprite.flipX		= flipX_;
	Sprite.scaleX		= self.scaleX;
	Sprite.flipY		= flipY_;
	Sprite.scaleY		= self.scaleY;
	Sprite.position		= position_;
	Sprite.anchorPoint	= anchorPoint_;
	Sprite.rotation		= rotation_;	//NON SUPPORTATO
	return Sprite;
}
/*
-(CGRect)TrimmedRect
{//in parent coordinate, non supporta la rotazione
	CGRect	rectangle;
	rectangle.origin.x		= positionInPixels_.x + (offsetPositionInPixels_.x - anchorPointInPixels_.x) * scaleX_;
	rectangle.origin.y		= positionInPixels_.y + (offsetPositionInPixels_.y - anchorPointInPixels_.y) * scaleY_;
	rectangle.size.width	= rectInPixels_.size.width * scaleX_;
	rectangle.size.height	= rectInPixels_.size.height * scaleY_;
	if (CC_CONTENT_SCALE_FACTOR() == 1)
			return rectangle;
	else	return CC_RECT_PIXELS_TO_POINTS(rectangle);
}
*/

-(CGRect)TrimmedRect
{//in parent coordinate, non supporta la rotazione

/*	CGRectApplyAffineTransform /**/

	CGRect	rectangle;
	rectangle.origin.x		= (offsetPositionInPixels_.x - anchorPointInPixels_.x);
	rectangle.origin.y		= (offsetPositionInPixels_.y - anchorPointInPixels_.y);
	rectangle.size.width	= rectInPixels_.size.width;
	rectangle.size.height	= rectInPixels_.size.height;

	if (rotation_ != 0)
		rectangle			= CGRectRotate(rectangle, -CC_DEGREES_TO_RADIANS(rotation_));

	rectangle.origin.x		= positionInPixels_.x + rectangle.origin.x * scaleX_;
	rectangle.origin.y		= positionInPixels_.y + rectangle.origin.y * scaleY_;
	rectangle.size.width	= rectangle.size.width * scaleX_;
	rectangle.size.height	= rectangle.size.height * scaleY_;
	
	if (CC_CONTENT_SCALE_FACTOR() == 1)
			return rectangle;
	else	return CC_RECT_PIXELS_TO_POINTS(rectangle);
}

-(CGRect)untrimmedRect
{//in parent coordinate, non supporta la rotazione
	CGRect	rectangle;
	rectangle.origin.x		= -anchorPointInPixels_.x;
	rectangle.origin.y		= -anchorPointInPixels_.y;
	rectangle.size			= contentSizeInPixels_;
	if (rotation_ != 0)
		rectangle			= CGRectRotate(rectangle, -CC_DEGREES_TO_RADIANS(rotation_));
	
	rectangle.origin.x		= positionInPixels_.x + rectangle.origin.x * scaleX_;
	rectangle.origin.y		= positionInPixels_.y + rectangle.origin.y * scaleY_;
	rectangle.size.width	= rectangle.size.width * scaleX_;
	rectangle.size.height	= rectangle.size.height * scaleY_;
	
	if (CC_CONTENT_SCALE_FACTOR() == 1)
			return rectangle;
	else	return CC_RECT_PIXELS_TO_POINTS(rectangle);
}

-(CGPoint)imageCenter//in node coordinate, non supporta la rotazione
{
	return ccp((offsetPositionInPixels_.x / CC_CONTENT_SCALE_FACTOR() + rect_.size.width / 2) * scaleX_,
			   (offsetPositionInPixels_.y / CC_CONTENT_SCALE_FACTOR() + rect_.size.height / 2) * scaleY_);
}

-(CGPoint)imageCenterAR//in node coordinate relativo all'anchorPoint , non supporta la rotazione
{
	return ccp(((offsetPositionInPixels_.x - anchorPointInPixels_.x) / CC_CONTENT_SCALE_FACTOR() + rect_.size.width / 2) * scaleX_,
			   ((offsetPositionInPixels_.y - anchorPointInPixels_.y) / CC_CONTENT_SCALE_FACTOR() + rect_.size.height / 2) * scaleY_);
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Rect = (%.2f,%.2f,%.2f,%.2f) | Position = (%.2f,%.2f) | AnchorPoint = (%.2f,%.2f) | Offset = (%.2f,%.2f) | Scale = (%.2f,%.2f) | Rotation = %.2f | Flip = (%@,%@) | tag = %i | atlasIndex = %i>",
			[self class],
			(unsigned int)self,
			rect_.origin.x, rect_.origin.y, rect_.size.width, rect_.size.height,
			position_.x, position_.y,
			anchorPoint_.x, anchorPoint_.y,
			offsetPositionInPixels_.x / CC_CONTENT_SCALE_FACTOR(), offsetPositionInPixels_.y / CC_CONTENT_SCALE_FACTOR(),
			scaleX_, scaleY_,
			rotation_,
			(flipX_?@"YES":@"NO"),(flipY_?@"YES":@"NO"),
			tag_,
			atlasIndex_
			];
}
@end


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCSpriteFrame (FrameAddOn)
+(id)frameWithFile: (NSString*)File;
{
	return [[[self alloc] initWithFile: File] autorelease];
}

-(id)initWithFile: (NSString*)File
{
	CCTexture2D	*Texture	= [[CCTextureCache sharedTextureCache] addImage: File];
	return [self initWithTexture: Texture rect: CGRectMakeOriginSize(CGPointZero, Texture.contentSize)];
}

-(BOOL)isEqual: (id)Object
{
	if (![Object isKindOfClass: [CCSpriteFrame class]])
		return false;
	CCSpriteFrame	*frame	= (CCSpriteFrame*)Object;
	return	(frame.texture.name == self.texture.name)	&&
			(CGRectEqualToRect(frame.rect, self.rect))	&&
			(CGPointEqualToPoint(frame.offsetInPixels, self.offsetInPixels));
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCAction (ActionAddOn)
-(NSString*)longDescription
{
	return [self description];
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCRepeat (ActionAddOn)
-(NSString*)longDescription
{
	return [NSString stringWithFormat:@"<%@ = %08X times = %u> InnerAction = %@", [self class], (unsigned int)self, times_, [innerAction_ longDescription]];
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCRepeatForever (ActionAddOn)
-(NSString*)longDescription
{
	return [NSString stringWithFormat:@"<%@ = %08X> InnerAction = %@", [self class], (unsigned int)self, [innerAction_ longDescription]];
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCSequence (ActionAddOn)
+(id)actionsWithCArray: (CCFiniteTimeAction**) ActionsArray
{
	unsigned int	i = 0;
	while (ActionsArray[i] && ActionsArray[i + 1])
	{
		ActionsArray[0]	= [self actionOne: ActionsArray[0] two: ActionsArray[i + 1]];
		i++;
	}
	return ActionsArray[0];
}

-(NSString*)description
{
/*	return [NSString stringWithFormat:@"<%@ = %08X | Last = %d\n\tTarget = %@\n\tActionOne = %@\n\tActionTwo = %@\n>",
			[self class],
			(unsigned int)self,
			last,
			[target_ description],
			[actions[0] description],
			[actions[1] description]];
*/	return [NSString stringWithFormat:@"<%@ = %08X >", [self class], (unsigned int)self];
}

-(NSString*)longDescription
{
	return [NSString stringWithFormat:@"<%@ = %08X | Tag = %i>\n One = %@\n Two = %@\n",
			[self class],
			(unsigned int)self,
			tag_,
			[actions_[0] longDescription],
			[actions_[1] longDescription]
		];
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCSpawn (ActionAddOn)
+(id)actionsWithCArray: (CCFiniteTimeAction**) ActionsArray
{
	unsigned int	i = 0;
	while (ActionsArray[i] && ActionsArray[i + 1])
	{
		ActionsArray[0]	= [self actionOne: ActionsArray[0] two: ActionsArray[i + 1]];
		i++;
	}
	return ActionsArray[0];
}

-(NSString*)longDescription
{
	return [NSString stringWithFormat:@"<%@ = %08X | Tag = %i>\n One = %@\n Two = %@\n",
			[self class],
			(unsigned int)self,
			tag_,
			[one_ longDescription],
			[two_ longDescription]
			];	
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCAnimation (longDescription)
-(NSString*)longDescription
{
	return [NSString stringWithFormat:@"<%@ = %08X | AnimationName = %@>", [self class], (unsigned int)self, name_];
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCAnimate (longDescription)
-(NSString*)longDescription
{
	return [NSString stringWithFormat:@"<%@ = %08X | Tag = %i>\n\tAnimation = %@>", [self class], (unsigned int)self, tag_, [animation_ longDescription]];
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface CCActionManager (Private)
-(void) removeActionAtIndex:(NSUInteger)index hashElement:(tHashElement*)element;
@end

@implementation CCActionManager (removeAllActionByTag)
-(void) removeAllActionsByTag:(int) aTag target:(id)target
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	NSAssert( target != nil, @"Target should be ! nil");
	
	tHashElement *element = NULL;
	HASH_FIND_INT(targets, &target, element);
	
	if( element ) {
		NSUInteger limit = element->actions->num;
		for( NSUInteger i = 0; i < limit; i++) {
			CCAction *a = element->actions->arr[i];
			
			if( a.tag == aTag && [a originalTarget]==target)
			{
				[self removeActionAtIndex:i hashElement:element];
				limit--;
			}
		}
		//		CCLOG(@"cocos2d: removeActionByTag: Action not found!");
	}
	//	else {
	//		CCLOG(@"cocos2d: removeActionByTag: Target not found!");
	//	}
}

-(NSArray*) getAllActionsByTag:(int)aTag target:(id)target
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	
	NSMutableArray	*Return	= [NSMutableArray arrayWithCapacity: 0];
	tHashElement *element = NULL;
	HASH_FIND_INT(targets, &target, element);
	
	if( element ) {
		if( element->actions != nil ) {
			NSUInteger limit = element->actions->num;
			for( NSUInteger i = 0; i < limit; i++) {
				CCAction *a = element->actions->arr[i];
				
				if( a.tag == aTag )
					[Return addObject: a];
			}
		}
	}
	if ([Return count] == 0)
		return nil;
	else return Return;
}

-(NSArray*) getAllActionsForTarget:(id)target
{	
	NSMutableArray	*Return	= [NSMutableArray arrayWithCapacity: 0];
	tHashElement *element = NULL;
	HASH_FIND_INT(targets, &target, element);
	
	if( element ) {
		if( element->actions != nil ) {
			NSUInteger limit = element->actions->num;
			for( NSUInteger i = 0; i < limit; i++)
				[Return addObject: element->actions->arr[i]];
		}
	}
	if ([Return count] == 0)
		return nil;
	else return Return;
}
@end

@implementation CCNode (removeAllActionByTag)
-(void) stopAllActionsByTag:(int)aTag
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	[[CCActionManager sharedManager] removeAllActionsByTag:aTag target:self];
}

-(NSArray*) getAllActionsByTag:(int)aTag
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	return [[CCActionManager sharedManager] getAllActionsByTag:aTag target:self];
}

-(NSArray*) getAllActions
{
	return [[CCActionManager sharedManager] getAllActionsForTarget:self];
}
@end

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#include <sys/sysctl.h>  
#import <mach/mach.h>
#import <mach/mach_host.h>

@implementation CCDirector (sceneByTag)

+(TMemInfo)memInfo
{
    mach_port_t           host_port = mach_host_self();
    mach_msg_type_number_t   host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t               pagesize;
    vm_statistics_data_t     vmstat;
	
    host_page_size(host_port, &pagesize);
	
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vmstat, &host_size) != KERN_SUCCESS) NSLog(@"Failed to fetch vm statistics");

	TMemInfo	memInfo;
	memInfo.total	= (vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count)	* pagesize;;
	memInfo.wired	= vmstat.wire_count		* pagesize;//usate dal kernel
	memInfo.active	= vmstat.active_count	* pagesize;//recentemente usate
	memInfo.inactive= vmstat.inactive_count	* pagesize;//non recentemente usate, potrebbero subire swap
	memInfo.free	= vmstat.free_count		* pagesize;//libere
	return memInfo;
}

+(TMemInfo)memInfoMB
{
	TMemInfo	memInfo	= [CCDirector memInfo];
	memInfo.total	/= 1024*1024;
	memInfo.wired	/= 1024*1024;
	memInfo.active	/= 1024*1024;
	memInfo.inactive/= 1024*1024;
	memInfo.free	/= 1024*1024;	
	return memInfo;
}

+(void)printMemInfo
{
	TMemInfo	memInfo	= [CCDirector memInfoMB];
	NSLog(@"Memory usage:\nTotal:\t%.2f\nFree:\t%.2f\nUsed:\t%.2f\n Wired:\t%.2f\n Active:\t%.2f\n Inactive:\t%.2f",
		  memInfo.total,
		  memInfo.free,
		  memInfo.wired + memInfo.active + memInfo.inactive,		  
		  memInfo.wired,
		  memInfo.active,
		  memInfo.inactive);
}

-(NSString*)debugInfo
{
	TMemInfo	memInfo	= [CCDirector memInfoMB];
	return	[NSString stringWithFormat:@"%.1f %u %u %u",
			 frameRate_,
			 (int)memInfo.total,
			 (int)memInfo.free,
			 (int)(memInfo.wired + memInfo.active + memInfo.inactive)];
}

-(int)sceneStackCount	{	return [scenesStack_ count];	}
-(NSMutableArray*)GetSceneStack  {	return scenesStack_;}
-(id) runSceneFromStackByTag: (int) aTag pushCurrent: (bool)Push
{
	CCScene	*NextScene	= nil;
	int		Index;
	NSAssert(aTag != kCCActionTagInvalid, @"Invalid tag");
	for (Index	= 0; Index < [scenesStack_ count]; Index++)
	{
		NextScene	= [scenesStack_ objectAtIndex: Index];
		if (NextScene.tag == aTag)
			break;
	}
	if (Index >= [scenesStack_ count])	return nil;//non trovata
	if (NextScene == [self runningScene])
		return	NextScene;//la scena richiesta è già in esecuzione

	if (Push)	[self pushScene: NextScene];//aggiunge un elemento alla fine di scenesStack_
	else		[self replaceScene: NextScene];//non aggiunge o toglie elementi da scenesStack_
	[scenesStack_ removeObjectAtIndex: Index];//la scena che devo eliminare si trova ad Index
	return NextScene;
}

-(void)preloadScene: (CCScene*)Scene
{
	[scenesStack_ insertObject: Scene atIndex: 0];
}

-(NSMutableArray*)scenesStack
{
	return scenesStack_;
}

-(void)clearSceneStack
{
	NSAssert(!nextScene_, @"clearSceneStack must be called before setting next scene");

	while (true)
	{
		int	count	= [scenesStack_ count];
		if (count <= 1)	break;

		nextScene_	= [scenesStack_ objectAtIndex: count - 2];
		[nextScene_ cleanup];
		[scenesStack_ removeObjectAtIndex: count - 2];
	}
	nextScene_	= nil;
}
-(bool)removeSceneFromStackByTag:(int)aTag
{
	CCScene	*Scene	= nil;
	int		Index;
	NSAssert(aTag != kCCActionTagInvalid, @"Invalid tag");
	for (Index	= 0; Index < [scenesStack_ count]; Index++)
	{
		Scene	= [scenesStack_ objectAtIndex: Index];
		if (Scene.tag == aTag)
			break;
	}
	if(Scene)
	{
		NSAssert(Scene != runningScene_, @" Can not remove current scene");
		[Scene cleanup];
		[scenesStack_ removeObjectAtIndex:Index];
		return true;
	}	
	else 
		return false;
}
@end


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCSpriteBatchNode (CCSpriteBatchNodeAddOn)

-(CGRect) TrimmedRect
{
	CCSprite *child;
	CGRect Rect = CGRectMake(0, 0, 0, 0);
	
	CCARRAY_FOREACH(children_, child)
	{
		Rect = CGRectUnion(Rect, [child TrimmedRect]);
	}
	return Rect;
}

@end

