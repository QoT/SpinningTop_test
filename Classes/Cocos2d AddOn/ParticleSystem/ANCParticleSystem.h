//
//  ANCParticleSystem.h
//  Farm Attack
//
//  Created by mad4chip on 24/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import "cocos2d.h"

@interface ANCParticleSystem : CCParticleSystemQuad
{
	NSString			*Name_;
	CCNode				*attachToNode_;
	CGPoint				Offset;
}

@property (readwrite, nonatomic, assign)	NSString			*Name;
@property (readwrite, nonatomic, assign)	CCNode				*attachToNode;
@property (readwrite, nonatomic)			CGPoint				Offset;


+(id) particleWithDictionary:(NSDictionary *)dictionary;

-(void)pauseEmission;
-(void)resumeEmission;
-(void)pauseSystem;
-(void)resumeSystem;

@end

