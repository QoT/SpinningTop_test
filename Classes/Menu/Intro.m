
//  Intro.m
//  Prova
//
//  Created by mad4chip on 14/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Intro.h"
#import "GameConfig.h"
#import "GameManager.h"
#import "functions.h"
#import "ObjectiveCAddOn.h"
#import "CocosAddOn.h"
#import "RunAction.h"

@implementation Intro
-(id)initMenu
{
	if ((self = [super initWithFile: INTRO_PLIST SceneManager: [GameManager Manager]]))
	{
		waitImage1	= [[ConfigurationContent objectForKey:@"waitImage1"]floatValue];
		waitImage2	= [[ConfigurationContent objectForKey:@"waitImage2"]floatValue];
		SceneId		= [[ConfigurationContent objectForKey:@"sceneId"]intValue];
	}
	return self;
}

-(void)onEnter
{
	[super onEnter];
	[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:waitImage1],
										[RunAction actionWithActionToRun:[CCHide action] andTarget:Image1],
										[RunAction actionWithActionToRun:[CCShow action] andTarget:Image2],
										[CCDelayTime actionWithDuration:waitImage2],
										[CCCallFuncO actionWithTarget: self  selector: @selector(ChangeSceneObj:) object: [NSNumber numberWithInt:SceneId]],
										nil]];
}

-(void)ChangeSceneObj: (NSNumber*)Scene
{
	[[GameManager Manager] ChangeScene: [Scene intValue]];
}

-(bool)RoleHandler: (CCNode*)Node andData: (NSDictionary*)Dictionary
{
	
	NSString	*Role	= [Dictionary localizedObjectForKey: @"role"];
	if ([Role isEqualToString:@"image1"]) 
		Image1	= (ANCSprite*) Node;
	else if([Role isEqualToString:@"image2"])
		Image2	= (ANCSprite*) Node;
	return true;
}


@end
