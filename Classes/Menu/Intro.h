//  Intro.h

//  Prova
//
//  Created by mad4chip on 14/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "ANCScene.h"
#import "ANCSprite.h"

@interface Intro : ANCScene
{
	ANCSprite *Image1;
	ANCSprite *Image2;
	float waitImage1;
	float waitImage2;
	int SceneId;
}
-(void)ChangeSceneObj: (NSNumber*)Scene;
@end
