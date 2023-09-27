//
//  Menu.h
//  Prova
//
//  Created by mad4chip on 14/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "ANCScene.h"
#import "DrawMenu.h"
#import "DrawableSprite.h"
#import "SneakyButtonSkinnedBase.h"
#import "MimiTop.h"
#import "ANCSprite.h"

@interface DrawMenu : ANCScene <MimiTopUpdate>
{
	CCLayer			*MainLayer;
	SneakyButton	*EnableButton;
	MimiTop			*Top;
	ANCSprite		*Target;
	CCLabelTTF		*Label;
}
@end
