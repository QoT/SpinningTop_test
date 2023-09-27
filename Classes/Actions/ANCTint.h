//
//  ANCSetColorAndOpacity.h
//  Farm Attack
//
//  Created by mad4chip on 28/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


@interface ANCSetTint : CCActionInstant
{
	ccColor4B	Tint;
}

+(id) actionWithColorRed:(GLshort)r green:(GLshort)g blue:(GLshort)b;
+(id) actionWithColor: (ccColor3B)t;
+(id) actionWithTintRed:(GLshort)r green:(GLshort)g blue:(GLshort)b opacity: (GLshort)o;
+(id) actionWithTint: (ccColor4B)t;
-(id) initWithTint: (ccColor4B)t;
@end

//-----------------------------------------------------------------------------------------------------------------------------------------------------------
@interface ANCTintTo : CCActionInterval <NSCopying>
{
	ccColor4B to_;
	ccColor4B from_;
}

+(id) actionWithDuration:(ccTime)t andTint: (ccColor4B)t;
+(id) actionWithDuration:(ccTime)t red:(GLubyte)r green:(GLubyte)g blue:(GLubyte)b;
+(id) actionWithDuration:(ccTime)t red:(GLubyte)r green:(GLubyte)g blue:(GLubyte)b opacity: (GLshort)o;
-(id) initWithDuration: (ccTime) t andTint: (ccColor4B)tint;
@end

//-----------------------------------------------------------------------------------------------------------------------------------------------------------
@interface ANCTintBy : ANCTintTo
{}

@end