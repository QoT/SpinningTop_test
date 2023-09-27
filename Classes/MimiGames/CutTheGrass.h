//
//  OptionMenu.h
//  Prova
//
//  Created by Visone on 10/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import "cocos2d.h"
#import "ANCScene.h"
#import "ANCSprite.h"
#import "SneakyButtonSkinnedBase.h"
#import "MimiLandManager.h"
#import "GrassObject.h"

@interface CutTheGrass : MimiLandManager
{
	GrassObject		**Grid;
	NSMutableArray	*Images;
	CCLayerColor	*GameLayer;
	int				Cut;
	int				GridSizeX;
	int				GridSizeY;
	CGPoint			GridSizeInPixels;
	CGPoint			GridOffset;
}
-(void)createGrid;
@end
