//
//  MoveByJoystic.h
//  Prova
//
//  Created by mad4chip on 29/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface Fly : CCAction
{
	CGPoint	LastPosition;	//posizione precedente senza shift
	CGPoint	OffSet;			//shift iniziale
	float	Distance;		//distanza percorsa
	float	Width;			//ampiezza delle evoluzioni
	float	WalkLength[2];	//lunghezza di una evoluzione
	int		K[2][4];
}

+(id) actionWithWidth: (float)W andWalkLength: (float)WalkL;
-(id) initWithWidth: (float)W andWalkLength: (float)WalkL;
-(CGPoint) getShift: (int) i;
-(float*)WalkLength;
-(int*)K;
-(float)Distance;
@end
