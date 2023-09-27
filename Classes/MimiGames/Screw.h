//
//  Screw.h
//  SpinningTop
//
//  Created by mad4chip on 14/11/12.
//
//

#import "cocos2d.h"
#import "ANCSprite.h"

#define SCREW	false
#define UNSCREW	true

@interface ScrewClass : CCNode
{
	int			Turns;

	ANCSprite	*ShadowImage;
	ANCSprite	*ScrewOnImage;
	ANCSprite	*ScrewOffImage;
	ANCSprite	*MarkerImage;
	float		Value;
	float		DriveTime;
	float		ScaleFactor;
}

@property (readwrite, nonatomic)	float	Value;		//0 = Avvitata; 1 = Svitata
@property (readwrite, nonatomic)	int		Turns;
@property (readwrite, nonatomic)	float	DriveTime;
@property (readwrite, nonatomic)	bool	Direction;
@property (readwrite, nonatomic)	float	ScaleFactor;
@property (readonly,  nonatomic)	float	Radius;

@property (readonly, nonatomic)		ANCSprite	*ShadowImage;
@property (readonly, nonatomic)		ANCSprite	*ScrewOnImage;
@property (readonly, nonatomic)		ANCSprite	*ScrewOffImage;
@property (readonly, nonatomic)		ANCSprite	*MarkerImage;

+(id)newScrewWithOnImage: (NSString*)On OffImage: (NSString*)Off ShadowImage: (NSString*)Shadow Marker: (NSString*)Shadow;
-(id)initScrewWithOnImage: (NSString*)On OffImage: (NSString*)Off ShadowImage: (NSString*)Shadow Marker: (NSString*)Shadow;

-(void)driveMeForTime: (float)Time;
-(void)showMarker;
-(void)hideMarker;
@end
