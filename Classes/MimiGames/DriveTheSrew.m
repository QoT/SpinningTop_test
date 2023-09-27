//
//  OptionMenu.m
//  Prova
//
//  Created by Visone on 10/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DriveTheSrew.h"
#import "GameManager.h"
#import "functions.h"
#import "ObjectiveCAddOn.h"
#import "SneakyButtonSkinnedBase.h"
#import "Screw.h"
#import "CocosAddOn.h"

@implementation DriveTheSrew

-(id)initMenu
{
	if ((self = [super initWithFile: DRIVETHESCREW_PLIST SceneManager: [GameManager Manager]]))
	{
		Screws	= [NSMutableArray arrayWithCapacity: 0];
		[Screws retain];
		
		NSString	*On			= [ConfigurationContent objectForKey: @"screwonimage"];
		NSString	*Off		= [ConfigurationContent objectForKey: @"screwoffimage"];
		NSString	*ScrewMarker= [ConfigurationContent objectForKey: @"markerimage"];
		NSString	*Shadow		= [ConfigurationContent objectForKey: @"screwshadow"];
		float		MarkerScale	= [[ConfigurationContent objectForKey: @"markersize"] floatValue];
		int			Turns		= [[ConfigurationContent objectForKey: @"screwturns"] intValue];
		float		DriveTime	= [[ConfigurationContent objectForKey: @"drivetime"] floatValue];
		float		ScaleFactor	= [[ConfigurationContent objectForKey: @"screwscalefactor"] floatValue];
		CGPoint		Anchor		= CGPointFromString([ConfigurationContent objectForKey: @"screwshadowanchor"]);

		for (NSString *Coordinates in [ConfigurationContent objectForKey: @"screws"])
		{
			ScrewClass	*newScrew	= [ScrewClass newScrewWithOnImage: On OffImage: Off ShadowImage: Shadow Marker: ScrewMarker];
			newScrew.ShadowImage.anchorPoint	= Anchor;
			newScrew.ScrewOnImage.scale			= ScaleFactor;
			newScrew.position	= CGPointFromString( Coordinates);
			newScrew.DriveTime	= DriveTime;
			newScrew.Turns		= Turns;
			newScrew.ScaleFactor= ScaleFactor;
			newScrew.MarkerImage.scale	= MarkerScale;
			[ScrewLayer addChild: newScrew];
			[Screws addObject: newScrew];
		}
		Mimi.DrawEnable	= ActionBtn.value;
	}
	return self;
}

-(bool)RoleHandler: (CCNode*)Node andData: (NSDictionary*)Dictionary
{
	NSString	*Role	= [Dictionary localizedObjectForKey: @"role"];
	if ([Role isEqualToString: @"screw layer"])	ScrewLayer		= (CCLayerColor*)Node;
	return [super RoleHandler: Node andData: Dictionary];
}

-(void)resetGame
{
	[self unscheduleUpdate];
	for (ScrewClass *Screw in Screws)
		[Screw hideMarker];
	[super resetGame];
}

-(void)initGame
{
	for (ScrewClass *Screw in Screws)
		Screw.Value	= 1;
	[Mimi.PaperSheet clearSprite];
	Mimi.drawEnable	= false;
	[super initGame];
}

-(void)startGame
{
	[self scheduleUpdate];
	[super startGame];
}

-(void)ActionPressed
{}

-(void)update: (float)dT
{
	if (Mimi.TopPresent)
	{
		bool	Finished	= true;
		bool	OnAScrew	= false;
		for (ScrewClass *Screw in Screws)
		{
			if (Screw.Value > 0)	Finished	= false;
			if (CircleIntersectPoint(Mimi.TopPosition, Screw.position, Screw.Radius))
			{
				if (Screw.Value > 0)
				{
					[Screw showMarker];
					if (ActionBtn.value)
						[Screw driveMeForTime: dT];
				}
				else	[Screw showMarker];
				OnAScrew		= true;
			}
			else	[Screw hideMarker];
		}
		if (Finished)		[self finishGame];
		else if (OnAScrew)	Mimi.drawEnable	= false;
		else				Mimi.drawEnable	= ActionBtn.value;
	}
}

-(TGameResult)getGameResult
{
	//implementare!!!!!!
	return (TGameResult){3, 1000};
}

-(void)dealloc
{
	[Screws release];
	[super dealloc];
}
@end
