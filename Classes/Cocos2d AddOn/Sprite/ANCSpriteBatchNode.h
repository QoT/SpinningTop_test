//
//  ANCSprite.h
//  Prova
//
//  Created by mad4chip on 22/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface ANCSpriteBatchNode : CCSpriteBatchNode
{
	NSMutableDictionary	*BatchesDict;
	bool				autoDeallocate;
}
@property (readwrite, assign, nonatomic) NSMutableDictionary	*BatchesDict;

+(void)addSprite: (ANCSprite*)Sprite toFather: (CCNode*)Father onZ: (int)z;
-(NSMutableDictionary*)BatchesDict;
@end

