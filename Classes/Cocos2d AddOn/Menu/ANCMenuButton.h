//
//  ANCMenuItemSpriteIndependent.h
//  Prova
//
//  Created by mad4chip on 29/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "SoundDescriptor.h"
#import "ANCMenuAdvanced.h"
#import "functions.h"

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//non aggiunge le immagini a se stesso quindi può essere usato col batchnode
@interface ANCMenuButton : CCMenuItemSprite <ClickDisabledMenuItemProtocol>
{
	
	CCNode <CCRGBAProtocol>		*backgroundImage_;
	CCNode <CCRGBAProtocol>		*foregroundImage_;
	CGRect						activeArea_;
	id							target;
	SoundDescriptor				*Sound;
	SoundDescriptor				*DisabledSound;
	CGPoint						TouchBegan;

	CGTransform					TransformOnSelect_;
	CGTransform					NormalTransform;
	ccColor4B					Tint_;
	ccColor4B					TintOnSelect_;	
	ccColor4B					TintDisabled_;
}
@property (nonatomic,readwrite,assign) CCNode			<CCRGBAProtocol> *backgroundImage;
@property (nonatomic,readwrite,assign) CCNode			<CCRGBAProtocol> *foregroundImage;
@property (nonatomic,readwrite)		   CGRect			activeArea;
@property (nonatomic,readwrite,assign) id				target;
@property (nonatomic,readwrite,assign) SoundDescriptor	*Sound;
@property (nonatomic,readwrite,assign) SoundDescriptor	*DisabledSound;
@property (nonatomic,readwrite)		   CGTransform		TransformOnSelect;
@property (nonatomic,readwrite)		   ccColor4B		TintOnSelect;
@property (nonatomic,readwrite)		   ccColor4B		TintDisabled;

+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite  target:(id)target selector:(SEL)selector;
-(id) initFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite  target:(id)target selector:(SEL)selector;
-(void)setActiveArea;
-(void)disabledClick;
-(void)applyOnSelectTransform;
-(void)applyOnUnselectTransform;
-(void)applyOnDisabledTransform;
-(void)applyOnEnabledTransform;
-(void)dragStart:   (CGPoint)Position;
-(void)dragToPoint: (CGPoint)Position;
-(void)dragEnd:     (CGPoint)Position;
-(void)enable;
-(void)disable;
@end
