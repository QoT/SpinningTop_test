//
//  GameManager_CreateScene.h
//  Prova
//
//  Created by mad4chip on 18/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ANCScene.h"
#import "GameManager.h"

@interface GameManager (CreateScene)
-(ANCScene*)createScene: (NSUInteger)NewSceneID;
@end
