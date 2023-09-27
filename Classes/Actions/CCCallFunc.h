//
//  CCCallFunc.h
//  Farm Attack
//
//  Created by mad4chip on 01/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


@interface CCCallFuncOO : CCCallFuncO
{
	id	object1_;
}

@property (nonatomic, readwrite, retain) id object1;
+(id) actionWithTarget: (id) t selector:(SEL) s object:(id)object object:(id)object1;
-(id) initWithTarget:(id) t selector:(SEL) s object:(id)object object:(id)object1;
@end
