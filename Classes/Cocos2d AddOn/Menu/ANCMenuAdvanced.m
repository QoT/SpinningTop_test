//
//  ANCMenuAdvanced.m
//  Prova
//
//  Created by mad4chip on 29/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANCMenuAdvanced.h"
#import "functions.h"
#import "CocosAddOn.h"

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation ANCMenuAdvanced
@synthesize Acceleration;

-(id) initWithItems: (CCMenuItem*) item vaList: (va_list) args
{
	if ((self = [super initWithItems: item vaList: args]))
		Acceleration					= 3;
	return self;
}

//l'implementazione originale ha problemi con CCMenuItemSpriteindependent
-(void) fixPosition
{
	[super fixPosition];

	CCMenuItem *item	= nil;
	CCARRAY_FOREACH(children_, item)
	{
		if (CGRectIntersectsRect([self convertRectToWorldSpace: [item rect]], boundaryRect_))
		{
			if (!item.visible)
				item.visible	= true;
			[item setPosition: [item position]];
		}
		else if (item.visible)
		{
			item.visible	= false;
			[item setPosition: [item position]];//devo aggiornare la posizione altrimentoi al prossimo onEnter riappaiono poichè sono all'interno del rettangolo
		}
	}
}

-(void)setBoundaryRect: (CGRect)Boundary
{
	boundaryRect_	= Boundary;
	if ((!CGRectIsNull(boundaryRect_)) &&
		(!CGRectIsInfinite(boundaryRect_)))
			[self fixPosition];//fà sparire gli elementi fuori alla boundaryRect_
}

//l'implementazione originale non consentiva di implementare l'area attiva
//questa versione inoltre ritorna anche un elemento disabilitato se non ci sono elementi toccati
-(CCMenuItem *) itemForTouch: (UITouch *) touch
{
	CGPoint touchLocation	= [touch locationInView: [touch view]];
	touchLocation			= [[CCDirector sharedDirector] convertToGL: touchLocation];
	
	if ((!CGRectIsNull( self.boundaryRect))		&&
		(!CGRectIsInfinite(self.boundaryRect))	&&
		(!CGRectContainsPoint(self.boundaryRect, touchLocation)))
		return nil;
	
	CCMenuItem* Return = nil;
	if ((selectedItem_) && ([selectedItem_ visible]))
	{
		CGRect r	= [selectedItem_ rect];
		r			= [self convertRectToWorldSpace: r];
		
		if( CGRectContainsPoint( r, touchLocation ) )
		{
			if ([selectedItem_ isEnabled])
				return selectedItem_;
			else if (state_ == kCCMenuStateWaiting)
				Return	= selectedItem_;
		}
	}

	CCMenuItem* item;
//	CCARRAY_FOREACH(children_, item)
//girò l'array dei figli all'incontrario in modo da considerare prima i bottoni che hanno zOrder maggiore
	if (children_ && children_->data->num > 0)
		for(id *__arr__ = children_->data->arr, *end = children_->data->arr + children_->data->num-1;
			end >= __arr__ && ((item = *end) != nil || true);
			end--)
	{// ignore invisible and disabled items: issue #779, #866
		if ([item visible])
		{
			CGRect r	= [item rect];
			r			= [self convertRectToWorldSpace: r];

			if( CGRectContainsPoint( r, touchLocation ) )
			{
				if ([item isEnabled])
					return item;
					
				else if (state_ == kCCMenuStateWaiting)
					Return	= item;
			}
		}
	}
	return Return;
}

//l'implementazione originale considerava anche i tocchi al di fuori del boundaryRect
-(BOOL) isTouchForMe:(UITouch *) touch
{
	CGPoint point		= [[CCDirector sharedDirector] convertToGL:[touch locationInView: [touch view]]];
	CGPoint prevPoint	= [[CCDirector sharedDirector] convertToGL:[touch previousLocationInView: [touch view]]];
	
	if (!CGRectContainsPoint(boundaryRect_, point) && !CGRectContainsPoint(boundaryRect_, prevPoint))
		return false;
	
	point		= [self convertToNodeSpace: point];
	prevPoint	= [self convertToNodeSpace: prevPoint];		
	CGRect rect = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
	
	if (CGRectContainsPoint(rect, point) || CGRectContainsPoint(rect, prevPoint))
		return true;
	return false;
}

//allineamento in griglia
-(void) allignItemsInGridWithPadding: (CGSize)padding align: (int)Align itemsNum: (int)itemsNum
{
	float	CellWidth		= 0;
	float	SpacingWidth;
	float	GridWidth;
	float	CellHeight		= 0;
	float	SpacingHeight;
	float	GridHeight;
	
	int		Rows			= 0;
	int		Cols			= 0;
	
	// calculate and set content size
	CCMenuItem *item;
	CCARRAY_FOREACH(children_, item)
	{
		CellWidth	= MAX(item.contentSize.width * item.scaleX,	 CellWidth);
		CellHeight	= MAX(item.contentSize.height * item.scaleY, CellHeight);
	}
	
	int	temp	= [children_ count];
	Rows		= temp / itemsNum;
	if (temp % itemsNum)	Rows++;
	
	if (Align & MENU_ALIGN_ROWS_NUM)
	{
		Cols		= Rows;
		Rows		= itemsNum;
	}
	else	Cols	= itemsNum;
	
	GridWidth	= (CellWidth  + padding.width)  * Cols;
	GridHeight	= (CellHeight + padding.height) * Rows;
	[self setContentSize: CGSizeMake(GridWidth, GridHeight)];
	
	float x;
	float y;
	if (Align & MENU_ALIGN_RIGHT_TO_LEFT)
	{
		x				= GridWidth - CellWidth/2;
		SpacingWidth	= -CellWidth - padding.width;
	}
	else
	{
		x				= CellWidth/2;
		SpacingWidth	= CellWidth + padding.width;
	}
	
	if (Align & MENU_ALIGN_BOTTOM_TO_TOP)
	{
		y				= CellHeight/2;
		SpacingHeight	= CellHeight + padding.height;
	}
	else
	{
		y				= GridHeight - CellHeight/2;
		SpacingHeight	= -CellHeight - padding.height;
	}
	
	// align items
	CCARRAY_FOREACH(children_, item)
	{
		[item setPosition: ccp(x + ((item.anchorPoint.x - 0.5) * CellWidth), y + ((item.anchorPoint.y - 0.5) * CellHeight))];
		//		CCLOG(@"%3.2f,%3.2f", x, y);
		
		if (Align &  MENU_ALIGN_ROWS_NUM)
		{
			y	+= SpacingHeight;
			if		(y > GridHeight)	y	= CellHeight/2;
			else if (y < 0)				y	= GridHeight - CellHeight/2;
			else	continue;
			x	+= SpacingWidth;
		}
		else
		{
			x	+= SpacingWidth;
			if		(x > GridWidth)		x	= CellWidth/2;
			else if (x < 0)				x	= GridWidth - CellWidth/2;
			else	continue;
			y	+= SpacingHeight;
		}
	}
	
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	if (Align & MENU_ALIGN_LEFT_TO_RIGHT)
	{
		self.nextItemButtonBind = NSRightArrowFunctionKey;
		self.prevItemButtonBind = NSLeftArrowFunctionKey;
	}
	else 
	{
		self.nextItemButtonBind = NSLeftArrowFunctionKey;
		self.prevItemButtonBind = NSRightArrowFunctionKey;
	}
#endif
}

//inerzia
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( state_ != kCCMenuStateWaiting || !visible_ || self.isDisabled )
		return false;
	curTouchLength_ = 0; //< every new touch should reset previous touch length

	selectedItem_ = [self itemForTouch:touch];

	if ((selectedItem_) ||
		(!CGRectIsNull(boundaryRect_) && [self isTouchForMe: touch]))// start slide even if touch began outside of menuitems, but inside menu rect
	{
		[self unscheduleUpdate];
		state_					= kCCMenuStateTrackingTouch;
		ScrollSpeed				= CGPointZero;	//cancella lo scorrimento in atto
		PrevTouchTime[0]		= touch.timestamp;
		PrevTouchPosition[0]	= [touch locationInView: [touch view]];
		for (int i = 1; i < PREV_POINTS_NUM; i++)
		{
			PrevTouchTime[i]		= PrevTouchTime[0];
			PrevTouchPosition[i]	= PrevTouchPosition[0];
		}

		if ([selectedItem_ isEnabled])
		{
			[selectedItem_ selected];
			if ([selectedItem_ conformsToProtocol:@protocol(DragableMenuItemProtocol)] && ([(CCMenuItem<DragableMenuItemProtocol>*) selectedItem_ draggable]))
			{
				CGPoint touchLocation = [selectedItem_ convertTouchToNodeSpace: touch];
				[(CCMenuItem<DragableMenuItemProtocol>*)selectedItem_ dragStart: touchLocation];
			}
		}		
		return true;
	}
	return false;
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchCancelled] -- invalid state");
	if ([selectedItem_ isEnabled])
	{
		if ([selectedItem_ conformsToProtocol:@protocol(DragableMenuItemProtocol)] && ([(CCMenuItem<DragableMenuItemProtocol>*) selectedItem_ draggable]))
		{
			CGPoint touchLocation = [selectedItem_ convertTouchToNodeSpace: touch];
			[(CCMenuItem<DragableMenuItemProtocol>*)selectedItem_ dragEnd: touchLocation];
		}
		[selectedItem_ unselected];
	}
	state_ = kCCMenuStateWaiting;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
//super
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchMoved] -- invalid state");
	
	CCMenuItem *currentItem = [self itemForTouch:touch];
	
	if (currentItem != selectedItem_)
	{
		if ([selectedItem_ isEnabled])
		{
			if ([selectedItem_ conformsToProtocol:@protocol(DragableMenuItemProtocol)] && ([(CCMenuItem<DragableMenuItemProtocol>*) selectedItem_ draggable]))
			{
				CGPoint touchLocation = [selectedItem_ convertTouchToNodeSpace: touch];
				[(CCMenuItem<DragableMenuItemProtocol>*)selectedItem_ dragEnd: touchLocation];
			}
			[selectedItem_ unselected];
		}
		selectedItem_ = currentItem;
		if ([selectedItem_ isEnabled])
		{
			[selectedItem_ selected];
			
			if ([selectedItem_ conformsToProtocol:@protocol(DragableMenuItemProtocol)] && ([(CCMenuItem<DragableMenuItemProtocol>*) selectedItem_ draggable]))
			{
				CGPoint touchLocation = [selectedItem_ convertTouchToNodeSpace: touch];
				[(CCMenuItem<DragableMenuItemProtocol>*)selectedItem_ dragStart: touchLocation];
			}
		}
	}
	else if (([selectedItem_ isEnabled]) &&
			 ([selectedItem_ conformsToProtocol:@protocol(DragableMenuItemProtocol)] && 
			 ([(CCMenuItem<DragableMenuItemProtocol>*) selectedItem_ draggable])))
	{
		CGPoint touchLocation = [selectedItem_ convertTouchToNodeSpace: touch];
		[(CCMenuItem<DragableMenuItemProtocol>*)selectedItem_ dragToPoint: touchLocation];
	}

	// scrolling is allowed only with non-zero boundaryRect
	if (!CGRectIsNull(boundaryRect_))
	{	
		// get touch move delta 
		CGPoint point = [touch locationInView: [touch view]];
		CGPoint prevPoint = [ touch previousLocationInView: [touch view] ];	
		point =  [ [CCDirector sharedDirector] convertToGL: point ];
		prevPoint =  [ [CCDirector sharedDirector] convertToGL: prevPoint ];
		CGPoint delta = ccpSub(point, prevPoint);
		
		curTouchLength_ += ccpLength( delta ); 
		
		if (curTouchLength_ >= self.minimumTouchLengthToSlide)
		{
			if ([selectedItem_ isEnabled])
			{
				if ([selectedItem_ conformsToProtocol:@protocol(DragableMenuItemProtocol)] && ([(CCMenuItem<DragableMenuItemProtocol>*) selectedItem_ draggable]))
				{
					CGPoint touchLocation = [selectedItem_ convertTouchToNodeSpace: touch];
					[(CCMenuItem<DragableMenuItemProtocol>*)selectedItem_ dragEnd: touchLocation];
				}
				[selectedItem_ unselected];
			}
			selectedItem_ = nil;
			
			// add delta
			CGPoint newPosition = ccpAdd(self.position, delta );	
			self.position = newPosition;
			
			// stay in externalBorders
			[self fixPosition];
		}
	}
//

	for (int i = PREV_POINTS_NUM - 1; i > 0; i--)
	{
		PrevTouchTime[i]		= PrevTouchTime[i - 1];
		PrevTouchPosition[i]	= PrevTouchPosition[i - 1];
	}
	PrevTouchTime[0]		= touch.timestamp;
	PrevTouchPosition[0]	= [touch locationInView: [touch view]];
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchEnded] -- invalid state");

	if ([selectedItem_ isEnabled])
	{
		if ([selectedItem_ conformsToProtocol:@protocol(DragableMenuItemProtocol)] && ([(CCMenuItem<DragableMenuItemProtocol>*) selectedItem_ draggable]))
		{
			CGPoint touchLocation = [selectedItem_ convertTouchToNodeSpace: touch];
			[(CCMenuItem<DragableMenuItemProtocol>*)selectedItem_ dragEnd: touchLocation];

		}
		[selectedItem_ activate];
		[selectedItem_ unselected];
	}
	else if ([selectedItem_ respondsToSelector:@selector(disabledClick)])//se ho cliccato su un elemento disabilitato chiamo disabledClick
		[(CCMenuItem<ClickDisabledMenuItemProtocol>*)selectedItem_ disabledClick];
	state_			= kCCMenuStateWaiting;
	selectedItem_	= nil;

	// scrolling is allowed only with non-zero boundaryRect
	if ( CGRectIsNull( self.boundaryRect) || CGRectIsInfinite(self.boundaryRect) )
		return;

	CGPoint	TouchPosition		= [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
	ccTime	TouchTime			= touch.timestamp;
	ScrollSpeed					= CGPointZero;
	
	for (int i = 0; i < PREV_POINTS_NUM - 1; i++)
	{
		CGPoint	TempPoint;
		ccTime	TempTime;
		
		PrevTouchPosition[i]	= [[CCDirector sharedDirector] convertToGL: PrevTouchPosition[i]];
		TempPoint				= PrevTouchPosition[i];
		PrevTouchPosition[i]	= ccpSub(TouchPosition, PrevTouchPosition[i]);
		TouchPosition			= TempPoint;
		
		TempTime				= PrevTouchTime[i];
		PrevTouchTime[i]		= TouchTime - PrevTouchTime[i];
		TouchTime				= TempTime;
		
		if (PrevTouchTime[i] != 0)
				PrevTouchPosition[i]	= ccpMult(PrevTouchPosition[i],  1 / (PrevTouchTime[i]));
		else	PrevTouchPosition[i]	= CGPointZero;
		ScrollSpeed				= ccpAdd(ScrollSpeed, PrevTouchPosition[i]);
	}
	ScrollSpeed					= ccpMult(ScrollSpeed, (float)1/ PREV_POINTS_NUM);
	if (!CGPointIsNull(ScrollSpeed))
		[self scheduleUpdate];
	else 	CCLOG(@"Speed is null");
	CCLOG(@"Speed is (%.2f,%.2f)", ScrollSpeed.x, ScrollSpeed.y);
}

//*/
-(void)update: (ccTime)DeltaT
{
	CGPoint	Versor;
	CGPoint	TempPosition	= ccpMult(ScrollSpeed, DeltaT);	//calcolo l'offset in base alla velocità
	
	//	CCLOG(@"ScrollSpeed: (%.2f,%.2f)", ScrollSpeed.x, ScrollSpeed.y);
	//	CCLOG(@"Scrolling (%.2f,%.2f)", TempPosition.x, TempPosition.y);
	TempPosition			= ccpAdd(self.position, TempPosition);	//aggiungo l'offset
	self.position			= TempPosition;
	[self fixPosition];	//sposto il menu e verifico se resta nei bordi
	TempPosition			= ccpSub(self.position, TempPosition);	//se sbatte sul bordo la differenza sarà diversa da zero
	
	if (round(TempPosition.x) != 0)
		ScrollSpeed				= ccp(0,		ScrollSpeed.y);
	if (round(TempPosition.y) != 0)
		ScrollSpeed				= ccp(ScrollSpeed.x,	0);
	
	Versor					= ccp(fsign(ScrollSpeed.x),	fsign(ScrollSpeed.y));	//calcolo il versore dello spostamento
	ScrollSpeed				= ccp(abs(ScrollSpeed.x),	abs(ScrollSpeed.y));		//faccio il valore assoluto della velocità
	ScrollSpeed				= ccpSub(ScrollSpeed, ccp(Acceleration * DeltaT * (ScrollSpeed.x + 1), Acceleration * DeltaT * (ScrollSpeed.y + 1)));	//applico la decelerazione
	
	if (ScrollSpeed.x < 0)	ScrollSpeed	= ccp(0,		ScrollSpeed.y);	//se la velocità và < di zero la azzero
	if (ScrollSpeed.y < 0)	ScrollSpeed	= ccp(ScrollSpeed.x,	0);
	if (CGPointIsNull(ScrollSpeed))	//se la velocità risultante è zero è finito lo scrolling
		[self unscheduleUpdate];
	else	ScrollSpeed		= ccp(ScrollSpeed.x * Versor.x, ScrollSpeed.y * Versor.y);	//altrimenti riapplico il versore
																						//	CCLOG(@"New ScrollSpeed: (%.2f,%.2f)", ScrollSpeed.x, ScrollSpeed.y);
}
@end
