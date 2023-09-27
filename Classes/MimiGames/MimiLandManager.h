//  ImagePuzzle.h

//  Prova
//
//  Created by mad4chip on 14/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "ANCScene.h"
#import "ANCSprite.h"
#import "CCProgressBar.h"
#import "SneakyButtonSkinnedBase.h"
#import "MimiTop.h"

typedef struct
{
	int				star;	//-1 livello non superato
	unsigned int	points;
}TGameResult;


@interface MimiLandManager : ANCScene <MimiTopUpdate>
{
	CCLayer				*RetryLayer;
	CCLayer				*WinLayer;
	CCLayer				*MainLayer;
	CCLayer				*MarkerLayer;
	MimiTop				*Mimi;
	ANCSprite			*Marker;
	ANCSprite			*MarkerOn;

	SneakyButton		*ActionBtn;
	ANCSprite			*Action_Up;
	ANCSprite			*Action_Down;

	ANCMenuButton		*Menu;
	ANCMenuButton		*Retry;
	ANCMenuButton		*Next;

	CCProgressBar		*CountDown;

	CCLabelBMFont		*Level;
	CCLabelBMFont		*StarBonus;
	CCLabelBMFont		*TimeBonus;
	CCLabelBMFont		*Total;

	CGRect				OriginalStartRect;
	bool				OffScreenTimer;

	float				totalTime;
	float				ElapsedTime;
	float				maxExitTime;

	bool				NewResult;	//si è migliorato il vecchio risultato
	TGameResult			LastResult;	//contiene il precedente risultato, se lo si migliora contiene il nuovo
	ANCSprite			*Star1;
	ANCSprite			*Star2;
	ANCSprite			*Star3;
}

-(void)hidePutHere;
-(void)showPutHere;
-(void)topUpdateEvent:(MimiEvents)Event position:(CGPoint)position;
-(void)resetGame;				//resetta timer e variabili
-(void)initGame;				//inizializza un nuovo schema
-(void)startGame;				//fà partire il gioco
-(void)updateTimer:(ccTime)dt;	//timer in gioco per il tempo trascorso
-(void)ActionButtonPressed;		//bottone di azione premuto, da implementare nella superclasse
-(void)closeGame: (bool)forceLose;//uso interno
-(void)forceLose;				//da chiamare per forzare perso
-(void)finishGame;				//da chiamare alla fine dello schema, decide se vinto o perso
-(void)loseGame;				//mostra i layer quando perso
-(void)winGame;					//mostra i layer quando vinto
-(TGameResult)getGameResult;	//calcola il risultato, da implementare nella superclasse
-(void)updateLabels;			//aggiorna le scritte in caso di vittoria
-(void)saveLastResult;			//salva il nuovo risultato
@end

