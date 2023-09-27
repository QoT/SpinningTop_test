//
//  Screw.h
//  SpinningTop
//
//  Created by mad4chip on 14/11/12.
//
//

#import "cocos2d.h"
#import "ANCSprite.h"


@interface GrassObject : ANCSprite
{
	bool		isLive;
	NSString	*Type;
}

@property (readwrite, nonatomic)			bool	isLive;//0 = Non Tagliata; 1 = Tagliata
@property (readwrite, nonatomic, assign)	NSString *Type;

+(id)grassWithType: (NSString*) type;
-(void)Dead;
-(void)Live;
@end
