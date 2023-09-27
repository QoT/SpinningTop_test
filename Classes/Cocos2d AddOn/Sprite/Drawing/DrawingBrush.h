
//took from	http://www.raywenderlich.com/4421/how-to-mask-a-sprite-with-cocos2d-1-0
#import "cocos2d.h"
@class DrawableSprite;
@interface DrawingBrush : NSObject
{
	NSArray				*Frames_;
	NSArray				*StartFrames_;
	NSArray				*EndFrames_;
	NSArray				*PointFrames_;
	
	float				RepetitionInterval_;
	bool				RandomizeRotation_;
	float				Size_;
	ccColor4B			Color_;
	ccBlendFunc			Blend_;
	
	DrawableSprite		*Sheet_;
}

@property	(nonatomic, readwrite)			ccBlendFunc		Blend;
@property	(nonatomic, readwrite, assign)	NSArray			*Frames;
@property	(nonatomic, readwrite, assign)	NSArray			*StartFrames;
@property	(nonatomic, readwrite, assign)	NSArray			*EndFrames;
@property	(nonatomic, readwrite, assign)	NSArray			*PointFrames;
@property	(nonatomic, readwrite)			bool			RandomizeRotation;
@property	(nonatomic, readwrite)			float			RepetitionInterval;
@property	(nonatomic, readwrite)			float			Size;
@property	(nonatomic, readwrite)			ccColor4B		Color;

@property	(nonatomic, readwrite, assign)	DrawableSprite	*Sheet;

-(void)setImage:		(CCSprite*)Image;
-(void)setEndImage:	(CCSprite*)Image;
-(void)setStartImage:	(CCSprite*)Image;
-(void)setPointImage:	(CCSprite*)Image;

+(id)newDrawingBrush;
+(id)newDrawingBrushWithDictionary: (NSDictionary*)Data;
@end

