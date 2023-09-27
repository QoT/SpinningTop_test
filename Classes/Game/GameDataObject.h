//
//  GameData.h
//  Prova
//
//  Created by mad4chip on 25/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import "GameConfig.h"
#import <GameKit/GameKit.h>

@interface GameDataObject : NSObject
{
	//contiene tutti i mondi
	NSMutableDictionary *Status;
	NSString			*CurrentWorld;
	int					*CurrentStage;
	
	//extra data
	float				MusicVolume;
	float				EffectVolume;
	unsigned int		Video;
}

@property (readwrite, nonatomic, assign)	NSMutableDictionary	*Status;
@property (readwrite, nonatomic)			unsigned int		Video;
@property (readwrite, nonatomic)			float				MusicVolume;
@property (readwrite, nonatomic)			float				EffectVolume;


+(id)gameData;
-(id)initData;
-(void)initGameData;
-(void)initExtraData;
-(void)initGameCenter;
-(void)saveGameData; //salva il dizionario all'inizio
-(void)saveGameStatus: (NSMutableDictionary*)NewStatus;
-(bool)loadGameData;
-(void)unlockWorld:(NSString*)WorldName;
-(void)unlockStage:(NSString*)WorldName stage:(int)Stage;
@end
