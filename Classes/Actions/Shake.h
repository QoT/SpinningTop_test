//
//  MoveByJoystic.h
//  Prova
//
//  Created by mad4chip on 29/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface Shake : CCActionInterval
{
	float	Width;
	CGPoint	positionOffset;
	int		Repetitions;
	int		K1;
	int		K2;
	int		K3;
	int		K4;
}

+(id) actionWithDuration: (ccTime) Time andWidth: (float)W repetitions: (int)rep;
-(id) initWithDuration: (ccTime) Time andWidth: (float)W repetitions: (int)rep;
-(CGPoint)getShift: (ccTime) t;
@end
