//
//  ANCParticleSystem.h
//  Farm Attack
//
//  Created by mad4chip on 24/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import "cocos2d.h"
#import "ANCParticleSystem.h"

@interface ANCParticleSystemManager : CCNode
{
	NSMutableDictionary	*UnusedParticleSystems;
	NSMutableDictionary	*LoadedFiles;
}

+(id)sharedParticleSystemManager;
+(id)newParticleSystemManager;
-(id)initParticleSystemManager;
-(NSDictionary*)preloadParticleSystemWithFile: (NSString*)FileName;
-(ANCParticleSystem*)newParticleSystemWithFile: (NSString*)FileName;
-(void)unloadParticleSystemWithFile: (NSString*)FileName;
-(void)removeUnusedParticleSystems;
-(void) stopAllParticleSystems;
@end
