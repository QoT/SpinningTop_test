//
//  Menu.m
//  Prova
//
//  Created by mad4chip on 14/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "GameConfig.h"
#import "GameManager.h"
#import "CocosAddOn.h"
#import "ObjectiveCAddOn.h"

#import "SpriteMask.h"

@implementation MainMenu
-(id)init
{//chiamato da ANCScene durante l'inizializzazione prima di chiamare roleHandler
	if ((self = [super init]))
	{
		Video		= nil;
		VideoText	= nil;
		Busto		= nil;
		Testa		= nil;
		BraccioDX	= nil;
		BraccioSX	= nil;
		[CCVideoPlayer setDelegate: self];
/*
		ANCSprite	*Sprite	= [ANCSprite spriteWithFile: @"Default.png"];
//		ANCSprite	*Mask	= [ANCSprite spriteWithFile: @"anello_4.png@Boss_brucone.plist"];
//		ANCSprite	*Mask	= [ANCSprite spriteWithFile: @"B17.png"];
//		ANCSprite	*Mask	= [ANCSprite spriteWithFile: @"CalendarMask.png"];
		ANCSprite	*Mask	= [ANCSprite spriteWithFile: @"puzzle1.png"];
		Sprite.position		= ccp(0, 0);
		Sprite.anchorPoint	= ccp(0, 0);
		Mask.position		= ccp(0, 0);
		Mask.anchorPoint	= ccp(0.5, 0.5);
		[Mask runAction: [CCRotateBy actionWithDuration: 100 angle: 3600]];
		
		MaskedSprite *masked = [MaskedSprite maskedSpriteWithImage: Sprite andMask: Mask];
		masked.position		= ccp(240, 160);
		[self addChild: masked z: 1000];
		masked.autoUpdate	= true;
*/
	}
	return self;
}

-(id)initMenu
{
	return [super initWithFile: MAIN_MENU_PLIST SceneManager: [GameManager Manager]];
}

-(void)onEnter
{
	[super onEnter];
	[NewGameLayer hideNode];
	[CheckLayer hideNode];
	[self enableMenus];

	GameDataObject	*GameData	= [[GameManager Manager] GameData];
	if (GameData.Video == 1)
	{
		GameData.Video = 0;
		[[SoundManager sharedManager] pauseBackgroundMusic];//inspiegabilmente devo fermarla a mano
		[CCVideoPlayer playMovieWithFile: Video andText: VideoText];
	}
	[[[GameManager Manager] GameData] initGameCenter];
}

-(void)dealloc
{
	[Video release];
	[VideoText release];
	[super dealloc];
}

-(bool)RoleHandler: (CCNode*)Node andData: (NSDictionary*)Dictionary
{
	NSString	*Role	= [Dictionary objectForKey: @"role"];

	if  ([Role isEqualToString: @"video"])
	{
		Video		= [[Dictionary localizedObjectForKey: @"video"] retain];
		VideoText	= [[Dictionary localizedObjectForKey: @"videotext"] retain];
	}
	else if  ([Role isEqualToString:@"submenu"])
		CheckLayer	= (CCLayer*) Node;
	return true;
}


-(void)BtnClick: (CCMenuItem*)Button
{
	int	Scene	= Button.tag;
	if (Scene >= 0)
		[super BtnClick: Button];
	else if (Scene == -1)
	{
		[self		disableMenus];
		[CheckLayer showNode];
		[CheckLayer enableMenus];
	}
	else if (Scene == -3)
		[CCVideoPlayer playMovieWithFile: Video andText: VideoText];
	else if(Scene == -4)
	{//tasto avventura
		[self disableMenus];
		[NewGameLayer showNode];
	}
	else if(Scene == -5)
	{//tasto back sul layer nuova partita
		[self enableMenus];
		[NewGameLayer hideNode];
	}
	else if ((Scene == -6) || (Scene == -7))
	{
		GameManager *Manager =	[GameManager Manager];
		//nuova partita
		if (Scene == -6)
		{
			[NewGameLayer disableMenus];
			[CheckLayer showNode];
			//[[Manager GameData] initGameData];//azzera lo stato della partita
		}
	}
	else if (Scene == -9)
	{
		//premuto no
		[CheckLayer hideNode];
		[NewGameLayer enableMenus];
	}
					  
}

- (void) moviePlaybackFinished
{
	[self enableMenus];
	[[CCDirector sharedDirector] startAnimation];
	[[SoundManager sharedManager] resumeBackgroundMusic];
}

- (void) movieStartsPlaying
{
	[self disableMenus];
	[[CCDirector sharedDirector] stopAnimation];
	[[SoundManager sharedManager] pauseBackgroundMusic];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
// Updates orientation of CCVideoPlayer. Called from SharedSources/RootViewController.m
- (void) updateOrientationWithOrientation: (UIDeviceOrientation) newOrientation
{
	[CCVideoPlayer updateOrientationWithOrientation:newOrientation ];
}
#endif
@end
