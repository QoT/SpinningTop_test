//
//  MenuSlider.h
//  Prova
//
//  Created by Visone on 10/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "ANCMenuAdvanced.h"
#import "SoundDescriptor.h" 


@interface MenuSlider : CCMenuItem  <DragableMenuItemProtocol>
{
	float			minValue_;
	float			maxValue_;
	float			value_;
	BOOL			isVertical;
	CCSprite		*trackImage_, *knobImage_;
	SEL				dragSelector;
	id				target;
	SoundDescriptor	*Sound;
}

/** returns the minimum */
@property (nonatomic,readwrite) float minValue;
/** returns the maximum */
@property (nonatomic,readwrite) float maxValue;
/** returns the value */
@property (nonatomic,readwrite) float value;
/** the image for the sliding track */
@property (nonatomic,readwrite,retain) CCSprite *trackImage;
/** the image for the knob */
@property (nonatomic,readwrite,retain) CCSprite *knobImage;
@property (nonatomic,readwrite,assign) id target;
@property (nonatomic,readwrite,assign) SoundDescriptor *Sound;

+(id) itemFromTrackImage: (CCSprite*)Track knobImage: (CCSprite*)Knob;
+(id) itemFromTrackImage: (CCSprite*)Track knobImage: (CCSprite*)Knob target: (id)target active: (SEL)selector1 drag:(SEL)selector2;
+(id) itemFromTrackImage:(CCSprite *)Track knobImage:(CCSprite *)Knob target: (id)target active: (SEL)selector1 drag: (SEL)selector2 sound:(SoundDescriptor*)sound_;
-(id) initFromTrackImage: (CCSprite*)Track knobImage: (CCSprite*)Knob target: (id)target active: (SEL)selector1 drag:(SEL)selector2 sound: (SoundDescriptor*)sound_;
@end

