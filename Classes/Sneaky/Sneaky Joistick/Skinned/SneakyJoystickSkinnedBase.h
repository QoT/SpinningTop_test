//
//  SneakyJoystickSkinnedBase.h
//  SneakyJoystick
//
//  Created by CJ Hanson on 2/18/10.
//  Copyright 2010 Hanson Interactive. All rights reserved.
//

#import "cocos2d.h"
#import "SneakyJoystick.h"

@interface SneakyJoystickSkinnedBase : SneakyJoystick
{
	CCSprite *backgroundSprite;
	CCSprite *thumbSprite;
	CCSprite *touchedBackgroundSprite;
	CCSprite *touchedThumbSprite;
}

@property (nonatomic, readwrite, retain) CCSprite *backgroundSprite;
@property (nonatomic, readwrite, retain) CCSprite *touchedBackgroundSprite;
@property (nonatomic, readwrite, retain) CCSprite *thumbSprite;
@property (nonatomic, readwrite, retain) CCSprite *touchedThumbSprite;

+(id)joystickWithRadius: (float)Radius BGSprite: (CCSprite*)BGSprite ThumbSprite: (CCSprite*)ThumbSprite TouchedBGSprite: (CCSprite*)TouchedBGSprite TouchedThumbSprite: (CCSprite*)TouchedThumbSprite;
-(id)initWithRadius: (float)Radius BGSprite: (CCSprite*)BGSprite ThumbSprite: (CCSprite*)ThumbSprite TouchedBGSprite: (CCSprite*)TouchedBGSprite TouchedThumbSprite: (CCSprite*)TouchedThumbSprite;
-(void) updatePositions;

@end
