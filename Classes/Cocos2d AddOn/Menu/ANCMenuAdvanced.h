//
//  ANCMenuAdvanced.h
//  Prova
//
//  Created by mad4chip on 29/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCMenuAdvanced.h"

@protocol DragableMenuItemProtocol
-(bool)draggable;
-(void)dragStart: (CGPoint)Position;
-(void)dragToPoint: (CGPoint)Position;
-(void)dragEnd:(CGPoint)Position;
@end

@protocol ClickDisabledMenuItemProtocol
-(void)disabledClick;
@end
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define	MENU_ALIGN_COLS_NUM			0
#define	MENU_ALIGN_ROWS_NUM			1
#define	MENU_ALIGN_LEFT_TO_RIGHT	0
#define	MENU_ALIGN_RIGHT_TO_LEFT	2
#define	MENU_ALIGN_TOP_TO_BOTTOM	0
#define	MENU_ALIGN_BOTTOM_TO_TOP	4

#define	PREV_POINTS_NUM				4

@interface ANCMenuAdvanced : CCMenuAdvanced
{
	ccTime		PrevTouchTime[PREV_POINTS_NUM];
	CGPoint		PrevTouchPosition[PREV_POINTS_NUM];
	CGPoint		ScrollSpeed;
	float		Acceleration;
}

@property (readwrite, nonatomic) float		Acceleration;

-(void) allignItemsInGridWithPadding: (CGSize)padding align: (int)Align itemsNum: (int)itemsNum;

@end