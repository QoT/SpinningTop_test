
//took from	http://www.raywenderlich.com/4421/how-to-mask-a-sprite-with-cocos2d-1-0
#import "cocos2d.h"
#import "DrawingBrush.h"

#define DRAWING_ELEMENT_UNDEIFNED	0
#define DRAWING_ELEMENT_POINTS		1
#define DRAWING_ELEMENT_LINE		2

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface DrawingElement : NSObject
{
	DrawingBrush		*Brush_;
	NSMutableArray		*Points;
	int					Type;
}

@property	(nonatomic, readonly)			int				Type;
@property	(nonatomic, readonly)			float			Length;
@property	(nonatomic, readwrite, assign)	DrawingBrush	*Brush;

+(id)newDrawingElement: (int)elementType;
-(bool)addPoint: (CGPoint)Point;
-(unsigned int)addPoints: (NSArray*)PointsToAdd;
-(int)pointsNum;
-(CGPoint)lastPoint;
-(CGPoint)pointAtIndex: (int)i;
-(void)startDraw;
-(CGPoint)draw;
-(CGPoint)drawFromPointIndex: (unsigned int)PointIndex lastDrawnPoint: (CGPoint) lastDrawnPoint;
-(void)endDraw;
@end

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface DrawingElementPoints : DrawingElement	{}
@end

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface DrawingElementLine : DrawingElement	{}
@end
