
//took from	http://www.raywenderlich.com/4421/how-to-mask-a-sprite-with-cocos2d-1-0
#import "cocos2d.h"

@interface MaskedSprite : CCSprite
{
	CCSprite		*Mask_;
	CCSpriteFrame	*ImageFrame;
	CCSprite		*Image_;
	CCSpriteFrame	*MaskFrame;
	CCRenderTexture *RenderTexture;
	bool			needUpdate;
	bool			releaseImageAndMask;
	bool			invertMask;
}

@property	(nonatomic, readwrite, assign)	CCSprite	*Mask;
@property	(nonatomic, readwrite, assign)	CCSprite	*Image;
@property	(nonatomic, readwrite)			bool		needUpdate;
@property	(nonatomic, readwrite)			bool		releaseImageAndMask;
@property	(nonatomic, readwrite)			bool		invertMask;

+(id)maskedSpriteWithImage:(CCSprite *)image andMask:(CCSprite *)mask;
+(id)maskedSpriteWithImage:(CCSprite *)image andMask:(CCSprite *)mask invertMask: (bool)invert;
-(id)initWithSpriteWithImage:(CCSprite *)image andMask:(CCSprite *)mask;
-(id)initWithSpriteWithImage:(CCSprite *)image andMask:(CCSprite *)mask invertMask: (bool)invert;
-(void)applyMask;
-(void)forceUpdate;
@end


