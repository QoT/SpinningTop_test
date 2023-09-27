#import "cocos2d.h"
#import "DrawingBrush.h"
#import "DrawingElement.h"
#import "ANCParticleSystem.h"

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface DrawableSprite : CCSprite <CCTargetedTouchDelegate>
{
	CCRenderTexture		*RenderTexture;
	ccColor4B			BackGroundColor;
	CCSprite			*BackGroundImage_;
	bool				maskMode;
	bool				touchEnabled;
	CGPoint				LastPosition;
	bool				Moved;
	
	DrawingBrush		*CurrentBrush_;
	NSMutableArray		*History;
	unsigned int		DrawIndex;
	unsigned int		PointsIndex;
	CGPoint				LastDrawnPoint;

	NSInvocation		*OnUpdate;
}

@property	(nonatomic, readwrite, assign)	DrawingBrush		*CurrentBrush;
@property	(nonatomic, readonly)			DrawingElement		*LastDrawnElement;
@property	(nonatomic, readonly)			DrawingElement		*LastElement;

@property	(nonatomic, readwrite)			ccColor4B			BackGroundColor;
@property	(nonatomic, readwrite, assign)	CCSprite			*BackGroundImage;
@property	(nonatomic, readwrite)			bool				maskMode;
//@property	(nonatomic, readwrite)			bool				enable;
@property	(nonatomic, readwrite)			bool				touchEnabled;

+(id)newDrawableSpriteWithBackGroundImage: (CCSprite *)BackGround;
+(id)newDrawableSpriteWithSize: (CGSize) Size andBackGroundColor: (ccColor4B)Color;
+(id)newDrawableSpriteWithFile: (NSString*)FileName;
+(id)newDrawableSpriteWithDictionary: (NSDictionary*)Data;
-(id)initWithSize: (CGSize)Size;
-(id)initDrawableSpriteWithBackGroundImage: (CCSprite *)BackGround;
-(id)initDrawableSpriteWithSize: (CGSize) Size andBackGroundColor: (ccColor4B)Color;

-(void)clearSprite;
-(void)clearUndo;
-(void)undoLastDraw;
-(void)applyBrush;
-(DrawingElement*)newElement: (int)elementType;

-(void) drawPointAtPosition: (CGPoint)Position;
-(void) drawLineStartAtPoint: (CGPoint)Point;
-(void) drawLineAddPoint: (CGPoint)Point;
-(void) drawLineClose;
-(void) drawLineWithPoints: (NSArray*)Points;

-(void)registerOnUpdateDelegate: (id)target selector: (SEL) selector;
-(float)getTotalLength;
-(float)getLastElementLength;

-(float)getCoverageFactorMask: (ccColor4B)MaskColor RefColor: (ccColor4B)RefColor Step: (int)Step;
@end


