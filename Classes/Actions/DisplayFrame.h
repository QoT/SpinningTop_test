//
//  DisplayFrame.h
//  Prova
//
//  Created by mad4chip on 20/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface DisplayFrame : CCActionInstant
{
	CCSpriteFrame	*Frame2Display;
}

+(id) actionWithSpriteFrame: (CCSpriteFrame*)Frame;
-(id) initWithSpriteFrame: (CCSpriteFrame*)Frame;
@end

