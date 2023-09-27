//
//  OptionMenu.m
//  Prova
//
//  Created by Visone on 10/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CutTheGrass.h"
#import "GameManager.h"
#import "functions.h"
#import "ObjectiveCAddOn.h"
#import "CocosAddOn.h"
#import "GrassObject.h"

//-----------------------

@implementation CutTheGrass

-(id)initMenu
{
	if ((self = [super initWithFile: CUTTHEGRASS_PLIST SceneManager: [GameManager Manager]]))
	{
		GridSizeInPixels= CGPointFromString([ConfigurationContent objectForKey: @"gridsize"]);
		GridSizeX		= GridSizeInPixels.x;
		GridSizeY		= GridSizeInPixels.y;
		GridSizeInPixels= CGPointFromString([ConfigurationContent objectForKey: @"gridsizeinpixels"]);
		GridOffset		= CGPointFromString([ConfigurationContent objectForKey: @"gridoffset"]);
		Images			= [[ConfigurationContent objectForKey: @"gridimages"] retain];
		[self createGrid];
		[self initGame];
	}
	return self;
}

-(bool)RoleHandler: (CCNode*)Node andData: (NSDictionary*)Dictionary
{
	NSString	*Role	= [Dictionary localizedObjectForKey: @"role"];
	if	([Role isEqualToString: @"game layer"])	GameLayer	= (CCLayerColor*)Node;
	return [super RoleHandler: Node andData: Dictionary];
}

-(void)createGrid
{
	Grid	= malloc(sizeof(GrassObject*) * GridSizeX * GridSizeY);
	NSAssert(Grid, @"Griglia non inizializzata");
	//agg imagf
	int index = 0;
	CGPoint offset;
	for (int x = 0; x < GridSizeX; x++)
	{
		for (int y = 0; y < GridSizeY; y++)
		{
			//scelgo elemento, offsetx, offsety casuale
			index				= rand() % [Images count];
			offset				= RandomPointInRect(CGRectMake(0,0,20,20));
			GrassObject *sprite = [GrassObject grassWithType: [Images objectAtIndex:index]];
			sprite.position		= ccpAdd(offset, ccpAdd(GridOffset, ccp(x * GridSizeInPixels.x, y * GridSizeInPixels.y)));
			sprite.anchorPoint	= ccp (0.5, 0);
			sprite.isLive		= true;

			[GameLayer addChild: sprite z: GridSizeY - y];
			Grid[x + y * GridSizeX] = sprite;
		}
	}	
}

-(void)resetGame
{
	Cut	= 0;
	[self unscheduleUpdate];
	[Mimi.AttachedNode stopAllActions];
	[super resetGame];
}

-(void)initGame
{
	if (Grid)
	{//ritarda l'init a quando sarà creata la griglia
		for(int k = 0; k < GridSizeX * GridSizeY; k++)
			Grid[k].isLive = true;
		[super initGame];
	}
}

-(void)startGame
{
	[self scheduleUpdate];
	[Mimi.AttachedNode runAction: [CCRepeatForever actionWithAction: [CCRotateBy actionWithDuration: 1 angle: 360]]];
	[super startGame];
}

-(void)update: (float)dT
{
	int		X			= roundf((Mimi.TopPosition.x - GridOffset.x) / GridSizeInPixels.x);
	int		Y			= roundf((Mimi.TopPosition.y - GridOffset.y) / GridSizeInPixels.y - 0.5);
	CGPoint	Neighbors[]	= {	ccp(0,0),
							ccp(1,0),
							ccp(1,1),
							ccp(0,1),
							ccp(-1,1),
							ccp(-1,0),
							ccp(-1,-1),
							ccp(0,-1),
							ccp(1,-1),	};
	GrassObject	*grass;
	for (int i = 0; i < sizeof(Neighbors)/sizeof(CGPoint); i++)
	{
		int LocalX	= X + (int)Neighbors[i].x;
		int LocalY	= Y + (int)Neighbors[i].y;
		
		if ((LocalX < 0) || (LocalX >= GridSizeX) ||
			(LocalY < 0) || (LocalY >= GridSizeY))
				continue;
		grass	= Grid[LocalX + LocalY * GridSizeX];
		if ((grass.isLive) && (CGRectContainsPoint([grass TrimmedRect], Mimi.TopPosition)))
		{
			grass.isLive = false;
			Cut++;
			if (Cut >= GridSizeX * GridSizeY)	[self finishGame];
		}
	}
}

-(TGameResult)getGameResult
{
	TGameResult	Result;
	float perc = Cut / (GridSizeX * GridSizeY);
	if		(perc >= 0.8)	Result.star = 3;	//pulito 3 stelle
	else if (perc >= 0.6)	Result.star = 2;	//mediamente pulito 2 stelle
	else if (perc >= 0.4)	Result.star = 1;	//poco pulito 1 stella
	else if (perc >= 0.2)	Result.star = 0;	//Sporco 0 stella
	else					Result.star	= -1;	//perso
	Result.points	= perc * 1000;
	return	Result;
}

-(void)dealloc
{
	free(Grid);
	[Images release];
	[super dealloc];
}
@end
