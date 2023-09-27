//
//  RunAction.h
//  Prova
//
//  Created by mad4chip on 20/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface  RunAction : CCActionInterval
{
	CCAction	*ActionToRun;
	id			RealTarget;
}
//@property (nonatomic,readonly)			ccTime	elapsed;
@property (nonatomic,readwrite, assign) id			RealTarget;
@property (nonatomic,readonly)			CCAction	*ActionToRun;

+(id) actionWithActionToRun: (CCAction*)action;
+(id) actionWithActionToRun: (CCAction*)action andTarget: (id)Target;
+(id) actionWithActionToRun: (CCAction*)action forceInstant: (bool) forceInstant;
+(id) actionWithActionToRun: (CCAction*)action andTarget: (id)Target forceInstant: (bool) forceInstant;
-(id) initWithActionToRun: (CCAction*)action andTarget: (id)Target forceInstant: (bool) forceInstant;
@end
