//
//  DisplayFrame.h
//  Prova
//
//  Created by mad4chip on 20/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface CCSetColor : CCActionInstant
{
	ccColor3B Color;
}

+(id) actionWithColorRed:(GLshort)r green:(GLshort)g blue:(GLshort)b;
-(id) initWithColorRed:(GLshort)r green:(GLshort)g blue:(GLshort)b;
@end

