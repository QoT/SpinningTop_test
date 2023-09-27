//
//  Menu.m
//  Prova
//
//  Created by mad4chip on 14/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DrawMenu.h"
#import "GameManager.h"
#import "functions.h"
#import "CocosAddOn.h"
#import "ObjectiveCAddOn.h"

@implementation DrawMenu
-(id)initMenu
{
	if ((self = [super initWithFile: DRAW_PLIST SceneManager: [GameManager Manager]]))
	{
		[self	addChild: [ANCParticleSystemManager newParticleSystemManager] z: 2];
		ANCSprite	*Sprite		= [ANCSprite spriteWithFile: @"sparo su.png@geremia.plist"];//abilitato non premuto
		ANCSprite	*Sprite1	= [ANCSprite spriteWithFile: @"sparo giu'.png@geremia.plist"];
		
		Sprite.position			= CGPointZero;
		Sprite.anchorPoint		= CGPointZero;
		Sprite1.position		= CGPointZero;
		Sprite1.anchorPoint		= CGPointZero;
		
		[MainLayer	addChild: Sprite	z: 2];
		[MainLayer	addChild: Sprite1	z: 2];
		
		EnableButton	= [SneakyButtonSkinnedBase	buttonWithRect: CGRectMake([Sprite width] / 2, [Sprite height] / 2, [Sprite width], [Sprite height])
														Sprite:	Sprite
											   ActivatedSprite:	Sprite1
												 PressedSprite:	Sprite1
												DisabledSprite:	nil];
		EnableButton.position		= ccp([Sprite width] / 2, [Sprite height] / 2);
		EnableButton.isHoldable		= true;
		[MainLayer	addChild: EnableButton];

		Top	= [MimiTop newTopFromFile: @"Top.plist"];
		[Top registerOnUpdateDelegate: self];
//		Sprite					= [ANCSprite spriteWithFile: @"bestiario_sfondo_01.png@gruppo_2_A.plist"];
		Sprite					= [ANCSprite spriteWithFile: @"crossing_road_background.png"];
		Sprite.position			= ccp(ScreenSize.width/2, ScreenSize.height/2);
//		Sprite.rotation			= M_PI /4;
		Top.MovePath			= Sprite;
		Top.NegatePath			= true;

		[MainLayer addChild: Top z: 1];

		Target			= [ANCSprite spriteWithFile: @"countdown-hd.png"];
		Target.position	= ccp(200, 200);
		[MainLayer addChild: Target z: 2];

		Label				= [CCLabelTTF labelWithString: @"" fontName: @"Marker Felt" fontSize: 12];
		Label.string		= @"0";
		Label.position		= ccp(10, 40);
		Label.anchorPoint	= CGPointZero;
		[MainLayer addChild: Label z: 2];
	}
	return self;
}

-(void)topUpdateEvent: (MimiEvents)Event position: (CGPoint)position
{
	switch (Event) {
		case MIMITOP_TOUCH_BEGIN:			NSLog(@"MIMITOP_TOUCH_BEGIN");			break;
		case MIMITOP_TOUCH_MOVED:			NSLog(@"MIMITOP_TOUCH_MOVED");			break;
		case MIMITOP_TOUCH_END:				NSLog(@"MIMITOP_TOUCH_END");			break;
		case MIMITOP_TOUCH_CANCELLED:		NSLog(@"MIMITOP_TOUCH_CANCELLED");		break;
		case MIMITOP_EXIT_MOVE_RECT:		NSLog(@"MIMITOP_EXIT_MOVE_RECT");		break;
		case MIMITOP_FALLTOUCH_BEGIN:		NSLog(@"MIMITOP_FALLTOUCH_BEGIN");		break;
		case MIMITOP_FALLTOUCH_MOVED:		NSLog(@"MIMITOP_FALLTOUCH_MOVED");		break;
		case MIMITOP_FALLTOUCH_END:			NSLog(@"MIMITOP_FALLTOUCH_END");		break;
		case MIMITOP_FALLTOUCH_CANCELLED:	NSLog(@"MIMITOP_FALLTOUCH_CANCELLED");	break;
	}

	if ((Event == MIMITOP_FALLTOUCH_BEGIN) || (Event == MIMITOP_TOUCH_END) || (Event == MIMITOP_TOUCH_CANCELLED))
	{
		Target.color		= ccc3(255, 255, 255);
		if (Top.AttachedNode == Target)
		{
			Top.AttachedNode	= nil;
			[Target runAction: [CCMoveTo actionWithDuration: 3 position: ccp(200, 200)]];
		}
	}
	else if ((Top.TopPresent) && (CircleIntersectPoint(Top.TopPosition, Target.position, [Target width] / 2)))
	{
		if (Event == MIMITOP_TOUCH_BEGIN)
		{
			Target.color		= ccc3(0, 255, 0);
			[Target stopAllActions];
			Top.AttachedNode	= Target;
		}
		else	Target.color	= ccc3(255, 0, 0);
	}
	else 	Target.color		= ccc3(255, 255, 255);
//	Label.string	= [NSString stringWithFormat: @"Posizione (%.2f,%.2f) Lunghezza totale: %.2f ultimo: %.2f", Top.TopPosition.x, Top.TopPosition.y, [Top.PaperSheet getTotalLength], [Top.PaperSheet getLastElementLength]];
}

-(bool)RoleHandler: (CCNode*)Node andData: (NSDictionary*)Dictionary
{
	if ([[Dictionary localizedObjectForKey:@"role"] isEqualToString: @"mainLayer"])
		MainLayer	= (CCLayer*)Node;
	return true;
}


-(void)BtnClick: (CCMenuItem*)Button
{
	int	Scene	= Button.tag;
	if (Scene == -1)		[Top.PaperSheet clearSprite];
	else if (Scene == -2)	[Top.PaperSheet undoLastDraw];
}
@end
