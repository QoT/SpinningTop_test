//
//  Menu.h
//  Prova
//
//  Created by mad4chip on 14/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "ANCScene.h"
#import "ANCSprite.h"
#import "CCVideoPlayer.h"

@interface MainMenu : ANCScene <CCVideoPlayerDelegate>
{
	ANCSprite		*Busto;
	ANCSprite		*Testa;
	ANCSprite		*BraccioDX;
	ANCSprite		*BraccioSX;
	CCLayer			*NewGameLayer;
	CCLayer			*CheckLayer;

	NSString		*Video;
	NSString		*VideoText;
}
@end
