//
//  CombineAction.h
//  Prova
//
//  Created by mad4chip on 19/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


@interface CombineMoveAction : CCActionInterval
{
	CCFiniteTimeAction	*XAction;
	CCFiniteTimeAction	*YAction;
}

+(id) actionWithXAction: (CCActionInterval*) XAction_ andYAction: (CCActionInterval*) YAction_;
-(id) initWithXAction: (CCActionInterval*) XAction_ andYAction: (CCActionInterval*) YAction_;
@end
