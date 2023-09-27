//
//  GameManager_CreateScene.m
//  Prova
//
//  Created by mad4chip on 18/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameManager_CreateScene.h"
#import	"MainMenu.h"
#import "Intro.h"
#import "DrawMenu.h"
#import "DriveTheSrew.h"
#import "CleanTheFloor.h"
#import "BreakTheEgg.h"
#import "CutTheGrass.h"
#import "CrossTheRoad.h"

@implementation GameManager (CreateScene)

-(ANCScene*)createScene: (NSUInteger)NewSceneID
{
	ANCScene*	Scene;
	switch (NewSceneID)
	{
		case INSTAGEMINIGAMES:
		case MAIN_MENU:			Scene	= [MainMenu			initMenu];	break;
		case INTRO_MENU:		Scene	= [Intro			initMenu];	break;

		case DRAW_MENU:
//                                Scene	= [DrawMenu			initMenu];	break;
            NSLog(@"Temporarly disabled Draw scene");
                                Scene    = nil;    break;

		case DRIVETHESCREW_MENU: Scene	= [DriveTheSrew		initMenu];	break;//funziona
		case CLEANTHEFLOOR_MENU: Scene	= [CleanTheFloor	initMenu];	break;
		case BREAKTHEEGG_MENU:	 Scene	= [BreakTheEgg		initMenu];	break;
		case CUTTHEGRASS_MENU:	 Scene	= [CutTheGrass		initMenu];	break;
		case CROSSTHEROAD_MENU:	 Scene	= [CrossTheRoad		initMenu];	break;

		default:				NSAssert(false, @"No new scene!!");		break;
	}
	return Scene;
}
@end
