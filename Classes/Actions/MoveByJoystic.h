//
//  MoveByJoystic.h
//  Prova
//
//  Created by mad4chip on 29/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "SneakyJoystick.h"

@interface MoveByJoystic : CCAction
{
	SneakyJoystick	*Joystick;
	float			*MaxSpeed;
	CGRect			Area;
}

+(id) actionWithJoystick: (SneakyJoystick*) Joy maxSpeed: (float*)Speed andRect: (CGRect) RectArea;
-(id) initWithJoystick: (SneakyJoystick*) Joy maxSpeed: (float*)Speed andRect: (CGRect) RectArea;
	
@end
