//  ImagePuzzle.m
//  Prova
//
//  Created by mad4chip on 14/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


//#import "GameDataObject.h"
//#import <GameKit/GameKit.h>

#import "MimiLandManager.h"
#import "CocosAddOn.h"
#import "functions.h"
#import "ObjectiveCAddOn.h"
#import "CCSpriteScale9.h"
#import "GameDataObject.h"
#import "GameManager.h"

@implementation MimiLandManager

-(id)init
{
	if ((self = [super init]))
	{
		Action_Up	= nil;
		Action_Down	= nil;
		ActionBtn	= nil;
		CountDown	= nil;
	}
	return self;
}

-(id)initWithFile: (NSString *)FileName SceneManager: (id<SceneManagerProtocol>)Manager RoleHandler: (id<RoleHandlerProtocol>)Handler
{
	if ((self = [super initWithFile: FileName SceneManager: Manager RoleHandler: Handler]))
	{
		maxExitTime		= [[[IncludedFiles objectForKey: @"MimiLandManager.plist"] objectForKey: @"exit_time"] floatValue];
		totalTime		= [[ConfigurationContent objectForKey: @"matchtime"] floatValue];
		NSMutableDictionary *CountDownConfig = [ConfigurationContent objectForKey: @"countdown"];
		if (totalTime > 0)
		{
		//timer
			CCSpriteScale9 *outside  = [CCSpriteScale9 spriteWithFile:[CountDownConfig objectForKey:@"image_name"] andLeftCapWidth:20 andTopCapHeight:20];
			CCSpriteScale9 *inside	 = [CCSpriteScale9 spriteWithFile:[CountDownConfig objectForKey:@"image_name"] andLeftCapWidth:20 andTopCapHeight:20];

			CountDown			= [CCProgressBar progressBarWithBgSprite:outside andFgSprite:inside andSize:CGSizeMake(350, 20) andMargin:CGSizeMake(3,3)];
			[CountDown setFinalTint: ccc4(255, 0, 0, 255)];

			CountDown.position		= CGPointFromString([CountDownConfig objectForKey:@"position_value"]);
			CountDown.anchorPoint	= CGPointFromString([CountDownConfig objectForKey:@"anchor_value"]);
			[self addChild:CountDown z:[[CountDownConfig objectForKey:@"z_value"]intValue]];
		}

		NSDictionary	*Configuration	= [ConfigurationContent objectForKey: @"mimi"];
		Mimi		= [MimiTop newTopFromDictionary: Configuration];
		[Mimi registerOnUpdateDelegate: self];
		[MainLayer addChild: Mimi z: [[Configuration objectForKey: @"z"] intValue]];

		if (Action_Up)
		{
			ActionBtn	= [SneakyButtonSkinnedBase	 buttonWithRect: [Action_Up boundingBox]
															 Sprite: Action_Up
													ActivatedSprite: Action_Down
													  PressedSprite: Action_Down
													 DisabledSprite: nil
															 target: self
														   selector: @selector(ActionPressed)];
			ActionBtn.isHoldable	= true;
			[self addChild: ActionBtn z: 1];//sopra ogni cosa
		}
		OffScreenTimer	= false;//impedisce la sovrascrittura di startRect

		NSString	*Value	= [ConfigurationContent objectForKey: @"markerposition"];
		if (Value)
		{
			MarkerLayer.visible		= true;
			MarkerLayer.position	= CGPointFromString(Value);
		}
		else
		{
			MarkerLayer	= nil;
			MarkerOn	= nil;
			Marker		= nil;
		}
		[self initGame];
	}
	return self;
}

-(bool)RoleHandler: (CCNode*)Node andData: (NSDictionary*)Dictionary
{
	NSString	*Role	= [Dictionary localizedObjectForKey: @"role"];
	if		([Role isEqualToString: @"mainlayer"])		MainLayer	= (CCLayer*)Node;
	else if	([Role isEqualToString: @"marker_layer"])	MarkerLayer	= (CCLayer*)Node;
	else if	([Role isEqualToString: @"action_up"])		Action_Up	= (ANCSprite*)Node;
	else if ([Role isEqualToString: @"action_down"])	Action_Down	= (ANCSprite*)Node;
	else if ([Role isEqualToString: @"win layer"])		WinLayer	= (CCLayerColor*)Node;
	else if ([Role isEqualToString: @"retry layer"])	RetryLayer	= (CCLayerColor*)Node;
	else if ([Role isEqualToString: @"level"])			Level		= (CCLabelBMFont*)Node;
	else if ([Role isEqualToString: @"total"])			Total		= (CCLabelBMFont*)Node;
	else if ([Role isEqualToString: @"star bonus"])		StarBonus	= (CCLabelBMFont*)Node;
	else if ([Role isEqualToString: @"time bonus"])		TimeBonus	= (CCLabelBMFont*)Node;
	else if ([Role isEqualToString: @"menu"])			Menu		= (ANCMenuButton*)Node;
	else if ([Role isEqualToString: @"next"])			Next		= (ANCMenuButton*)Node;
	else if ([Role isEqualToString: @"retry"])			Retry		= (ANCMenuButton*)Node;
	else if ([Role isEqualToString: @"marker"])			Marker		= (ANCSprite*)Node;
	else if ([Role isEqualToString: @"markeron"])		MarkerOn	= (ANCSprite*)Node;
	else if ([Role isEqualToString: @"star 1"])			Star1		= (ANCSprite*)Node;
	else if ([Role isEqualToString: @"star 2"])			Star2		= (ANCSprite*)Node;
	else if ([Role isEqualToString: @"star 3"])			Star3		= (ANCSprite*)Node;
	return true;
}

-(void)BtnClick: (CCMenuItem*)Button
{
	if (Button.tag >= 0)	[super BtnClick: Button];
	else if (Button.tag == -15)	//premuto pulsante next
	{//deve puntare ad un gestore del mondo
		[self initGame];
	}
	else if (Button.tag == -16)	//premuto  retry
	{
		[self initGame];
	}
}

-(void)hidePutHere
{
	MarkerLayer.visible		= false;
	[Marker		stopAllActions];
	[MarkerOn	stopAllActions];
}

-(void)showPutHere
{
	CCAction	*Action		= [CCRepeatForever actionWithAction: [CCRotateBy actionWithDuration: 10 angle: 180]];
	MarkerLayer.visible		= true;
	[Marker		runAction: [Action copy]];
	[MarkerOn	runAction: Action];
	
	Action					= [CCRepeatForever actionWithAction: [CCSequence  actions:	[CCFadeIn		actionWithDuration: 0.5],
																						[CCFadeOut		actionWithDuration: 0.5],
																						nil]];
	[MarkerOn	runAction: Action];
}

-(void)topUpdateEvent:(MimiEvents)Event position:(CGPoint)position
{
	switch (Event)
	{
		case MIMITOP_TOUCH_BEGIN:
			if(!OffScreenTimer)
				[self startGame];
			[self unschedule: @selector(forceLose)];
			if(OffScreenTimer)
				Mimi.StartRect	= OriginalStartRect;
		break;

		case MIMITOP_TOUCH_END:			//se perde contatto per più maxExitTime perdi
		case MIMITOP_TOUCH_CANCELLED:	//se esce dallo schermo per più di maxExitTime perdi
			OffScreenTimer		= true;
			OriginalStartRect	= Mimi.StartRect;
			Mimi.StartRect		= CGRectMakeOriginSize(CGPointZero,  ScreenSize);
			[self schedule: @selector(forceLose) interval: maxExitTime];
		break;

		case MIMITOP_FALLTOUCH_BEGIN:
		case MIMITOP_EXIT_MOVE_RECT:
			[self forceLose];
		break;

		default:
/*		case MIMITOP_TOUCH_MOVED:
		case MIMITOP_FALLTOUCH_MOVED:
		case MIMITOP_FALLTOUCH_END:
		case MIMITOP_FALLTOUCH_CANCELLED:
*/		break;
	}
}

-(void)onExit
{
	[super onExit];
	[self forceLose];
}

//resetta timer e variabili
-(void)resetGame
{
	if(OffScreenTimer)
		Mimi.StartRect	= OriginalStartRect;
	[self unschedule: @selector(updateTimer:)];
	[self unschedule: @selector(forceLose)];
	[CountDown setProgress: 100];
	CountDown.visible	= false;
	OffScreenTimer		= false;
	ElapsedTime			= 0;
	Mimi.Enable			= false;
	LastResult			= [self getPreviousResult];
	NewResult			= false;
}

//inizializza un nuovo schema
-(void)initGame
{
	[self resetGame];
	[self showPutHere];
	[self enableMenus];
	[RetryLayer hideNode];
	[RetryLayer disableMenus];
	[WinLayer	hideNode];
	[WinLayer	disableMenus];
	Mimi.Enable		= true;
}

//fà partire il gioco
-(void)startGame
{
	CountDown.visible	= true;
	if (totalTime) [self schedule: @selector(updateTimer:)];
	[self hidePutHere];
}

//update timer
-(void)updateTimer:(ccTime)dt
{
	ElapsedTime += dt;
	float	Perc			= (totalTime - ElapsedTime)/totalTime;
	[CountDown setProgress: Perc];
	if (CountDown.progress <= 0)
		[self finishGame];
}

-(void)ActionButtonPressed
{
	NSAssert(false, @"Override me");
}

//finito il gioco decide se vinto o perso
-(void)closeGame: (bool)forceLose
{
	TGameResult	CurrentResult	= [self getGameResult];
	if ((forceLose) || (CurrentResult.star < 0))//perso
		[self loseGame];
	else
	{
		if (CurrentResult.points > LastResult.points)
		{
			NewResult	= true;
			LastResult	= CurrentResult;
			[self saveLastResult];
		}
		[self winGame];
	}
}
-(void)forceLose	{	[self closeGame: true];		}	//forza perso
-(void)finishGame	{	[self closeGame: false];	}	//decide se vinto o perso

-(void)winGame
{
	[self resetGame];
	[self disableMenus];
	[self updateLabels];
	
	[WinLayer showNode];
	[WinLayer enableMenus];
}

-(void)loseGame
{
	[self resetGame];
	[self disableMenus];
	
	[RetryLayer showNode];
	[RetryLayer enableMenus];
}

//calcola il punteggio e le stelle dello schema
-(TGameResult)getGameResult
{
	NSAssert(false, @"Override me");
	return (TGameResult){0, 0};
}

//carica il precedente risultato
-(TGameResult)getPreviousResult
{
	GameDataObject	*GameData	= [[GameManager Manager] GameData];
	return (TGameResult){-1, 0};
}

-(void)saveLastResult
{
	GameDataObject	*GameData	= [[GameManager Manager] GameData];
	//devo salvare CurrentResult;
	//settare i valori per i minigames
	[GameData saveGameData];
}


-(void)updateLabels
{
	//aggiorniamo le stelle
	switch (LastResult.star)
	{
		case 0:
			Star1.visible = false;
			Star2.visible = false;
			Star3.visible = false;
			break;
			
		case 1:
			Star1.visible = true;
			Star2.visible = false;
			Star3.visible = false;
			break;
			
		case 2:
			Star1.visible = true;
			Star2.visible = true;
			Star3.visible = false;
			break;
			
		case 3:
			Star1.visible = true;
			Star2.visible = true;
			Star3.visible = true;
			break;
	}
	Total.string	= [NSString stringWithFormat: @"%u", LastResult.points];
	if (NewResult)
	{//improved result
/* /*mostrare una scritta lampeggiante*/
	}
}
@end
