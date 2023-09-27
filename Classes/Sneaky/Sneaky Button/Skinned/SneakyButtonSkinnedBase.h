//
//  SneakyButtonSkinnedBase.h
//  SneakyInput
//
//  Created by Nick Pannuto on 2/19/10.
//  Copyright 2010 Sneakyness, llc.. All rights reserved.
//

#import "cocos2d.h"
#import "SneakyButton.h"

@interface SneakyButtonSkinnedBase : SneakyButton
{
	CCSprite	*defaultSprite;
	CCSprite	*activatedSprite;
	CCSprite	*disabledSprite;
	CCSprite	*pressedSprite;
	CCSprite	*CurrentImage;
}

@property (nonatomic, readwrite, retain) CCSprite *defaultSprite;
@property (nonatomic, readwrite, retain) CCSprite *activatedSprite;
@property (nonatomic, readwrite, retain) CCSprite *disabledSprite;
@property (nonatomic, readwrite, retain) CCSprite *pressedSprite;

+(id)buttonWithRect:(CGRect)rect Sprite: (CCSprite*)Sprite ActivatedSprite: (CCSprite*)ActivatedSprite PressedSprite: (CCSprite*)PressedSprite DisabledSprite: (CCSprite*)DisabledSprite;
+(id)buttonWithRect:(CGRect)rect Sprite: (CCSprite*)Sprite ActivatedSprite: (CCSprite*)ActivatedSprite PressedSprite: (CCSprite*)PressedSprite DisabledSprite: (CCSprite*)DisabledSprite target: (id)target selector:(SEL)selector;
-(id)initWithRect:(CGRect)rect Sprite: (CCSprite*)Sprite ActivatedSprite: (CCSprite*)ActivatedSprite PressedSprite: (CCSprite*)PressedSprite DisabledSprite: (CCSprite*)DisabledSprite target: (id)target selector:(SEL)selector;

@end
