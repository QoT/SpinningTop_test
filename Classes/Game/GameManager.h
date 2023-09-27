//
//  GameManager.h
//  Prova
//
//  Created by mad4chip on 14/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GameDataObject.h"
#import "ANCMenuButton.h"
#import "ANCScene.h"
#import "ANCSprite.h"

@interface GameManager : NSObject <SceneManagerProtocol>
{
	GameDataObject		*GameData;
//	bool				LowMemDevice;
	NSArray				*CurrentSceneGroup;
	NSMutableArray		*SceneGroups;
	NSMutableDictionary	*SceneObjects;
    NSUInteger			PreviousScene;
}
@property (readonly,	nonatomic)	GameDataObject	*GameData;
//@property (readonly,	nonatomic)	bool			LowMemDevice;

+(id)initGameManager;
-(id)initGameManager;
+(GameManager*)Manager;
-(void)addObject:(id)Object forScene: (NSUInteger)SceneID;
-(id)getObjectForScene: (NSUInteger)SceneID;
-(ANCScene*)ChangeScene: (NSUInteger)NewSceneID withObject: (id) Object;
-(void)addSceneGroup: (NSArray*)ScenesID;
-(void)memoryWarning:(UIApplication *)application;
@end

//------------------------------------------------------------------------------------------------------------------------
@interface LoadingScene : ANCScene
{
	float							Progress_;
	NSMutableArray					*Preload;
    NSUInteger						ScenesCount;
	CCLabelBMFont					*Loading;
	ANCMenuButton					*PressToContinue;
	bool							Clean;
	int								SceneID;
	ANCSprite						*Fork;

}
@property (readwrite, nonatomic) float	Progress;

+(id)loadingSceneWithArray: (NSArray*)Scenes pressToContinue: (bool)Continue sceneToRun:(NSUInteger)sceneId;
-(id)initWithSceneWithArray: (NSArray*)Scenes pressToContinue: (bool)Continue sceneToRun:(int)sceneId;
-(void) ChangeSceneObj: (NSNumber*)Scene;
@end
