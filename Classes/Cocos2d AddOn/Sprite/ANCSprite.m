//
//  ANCSprite.m
//  Prova
//
//  Created by mad4chip on 22/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameConfig.h"
#import "ANCSprite.h"
#import	"WalkAnimate.h"
#import "CocosAddOn.h"
#import "ANCAnimationCache.h"
#import "RunAction.h"
#import "DisplayFrame.h"
#import "ANCSpriteBatchNode.h"
#import "AudioActions.h"
#import "functions.h"

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark ANCSprite
@implementation ANCSprite
@synthesize Filename;

-(void)removeAnimationByName:(NSString*)name
{
	[[ANCAnimationCache sharedAnimationCache] removeAnimationByName:name forTarget: self];
}

-(id) init
{
	[animations_ release];//viene messo a nil da [super init];
	if ((self = [super init]))
	{
		[CurrentFrame release];
		CurrentFrame	= nil;
		[Filename release];
		Filename		= nil;
		OriginalRect	= CGRectMake(-1, 0, 0, 0);//uncropped
	}
	return self;
}

+(id)spriteWithFile:(NSString *)File
{
	return [[[self alloc] initWithFile:File flags: 0] autorelease];
}

+(id)spriteWithFile:(NSString *)File flags: (int)flags
{
	return [[[self alloc] initWithFile:File flags: flags] autorelease];
}

+(id)spriteWithSprite: (CCSprite*)Sprite;
{
	return [[[self alloc] initWithSprite: Sprite] autorelease];
}

-(id)initWithFile:(NSString *)File
{
	return [self initWithFile: File flags: 0];
}

-(id)initWithFile:(NSString *)File flags: (int)flags
{
	if ((self = [self init]))
		[self updateImage: File flags: flags];
	return self;
}

-(id)initWithSprite: (CCSprite*)Sprite
{
	if ((self = [self init]))
	{
		[self setDisplayFrame: [Sprite displayedFrame]];
		[self setTransform: [Sprite getTransform]];
	}
	return self;	
}

-(void) setDisplayFrame:(CCSpriteFrame*)frame
{
	[CurrentFrame release];
	CurrentFrame	= [frame retain];//impedisce alla cache di rilasciare un frame usato solo in un'immagine
	if (CGSizeIsNull(frame.originalSizeInPixels))
		self.visible	= false;
	else if (!visible_)
		self.visible	= true;
	if (self.cropped)
	{
		CGRect	CropArea	= self.cropArea;
		OriginalRect		= CGRectMake(-1, 0, 0, 0);//uncropped
		[super setDisplayFrame: frame];
		self.cropArea		= CropArea;
	}
	else	[super setDisplayFrame: frame];
}

-(CCSpriteFrame*) displayedFrame
{
	return	CurrentFrame;
}

-(void) setTexture:(CCTexture2D*)newTexture
{
	bool ChangeTexture	= false;
	if ((usesBatchNode_) && (newTexture.name != texture_.name))
		ChangeTexture	= true;
	CCNode				*Parent;
	int					Tag;
	int					Z;

	if (ChangeTexture)
	{
		NSAssert(batchNode_ == parent_, @"Unable to change texture if the sprite is child of another sprite");
		CCLOG(@"Changing texture %d,%d", newTexture.name, texture_.name);
		Tag		= tag_;
		Parent	= batchNode_.parent;	//mi segno i dati del batchnode perchè potrebbe essere deallocato
		Z		= batchNode_.zOrder;
		[self retain];
		[batchNode_ removeChild: self cleanup: false];
		[self setParent:nil];
	}
	[super setTexture: newTexture];
	if (ChangeTexture)
	{
		[Parent addChild: self z:Z tag:Tag];//triggera il metodo addingChild
		[self release];
	}
}

/*
Formato nome file:

filename.plist							verrà caricato lo stato di default
animazione@filename.plist				verrà caricata l'animazione indicata
frame_name@filename.plist				verrà mostrato il frame indicato
frame_num@animazione@filename.plist		verrà caricato il frame dell'animazione indicata
repetition*animazione@filename.plist	verrà caricata l'animazione indicata e ripetuta per il numero di volte indicato
image.png								verrà caricata l'immagine
Filename sarà impostato a filename.plist, se necessario il plist sarà caricato
se animazione è la stringa vuota si usa l'animazione di default

con file plist già caricato	(Filename = filename.plist)
nil										verrà caricato lo stato di default
animazione								verrà caricata l'animazione indicata
frame_num@animazione					verrà caricato il frame dell'animazione indicata
le animazioni saranno prese dal Filename impostato

frame_name								verrà mostrato il frame indicato da un plist precedentemente caricato
*/
-(void)updateImage: (NSString *)File
{
	[self updateImage: File flags: 0];
}

-(void)updateImage: (NSString *)File flags: (int)flags
{
	bool				Loaded	= false;
	CCSpriteFrame		*Frame;
	CCTexture2D			*Texture;
	ANCAnimation		*Animation;
	int					FrameNum		= -1;
	int					Repetitions		= 0;
	NSString			*AnimationName	= nil;
	NSArray				*Parts;

	if ([[File pathExtension] isEqualToString:@"plist"])
	{//stò caricando un file di animazioni
		NSString	*NewFileName	= nil;
		Parts						= [File componentsSeparatedByString: @"@"];
		if ([Parts count] == 1)									//filename.plist
			NewFileName	= File;
		else if	([Parts count] == 2)							//animazione@filename.plist
		{
			NewFileName		= [Parts objectAtIndex: 1];
			AnimationName	= [Parts objectAtIndex: 0];
		}
		else if ([Parts count] == 3)							//frame_num@animazione@filename.plist
		{
			NewFileName		= [Parts objectAtIndex: 2];
			FrameNum		= [[Parts objectAtIndex: 0] intValue];
			AnimationName	= [Parts objectAtIndex: 1];
		}
		if ((NewFileName) && (![NewFileName isEqualToString: Filename]))
		{
			[Filename release];
			Filename	= nil;
			Filename	= [NewFileName retain];
			[[ANCAnimationCache sharedAnimationCache] lockOutClean];
			[[ANCAnimationCache sharedAnimationCache] loadAtlasFile: Filename];
			Loaded	= true;
		}
	}
	else if (Filename)
	{//già è stato caricato un file di animazioni cerco tra quelle caricate
		Parts	= [File componentsSeparatedByString: @"@"];
		if	([Parts count] == 2)							//frame_num@animazione
		{
			FrameNum	= [[Parts objectAtIndex: 0] intValue];
			File		= [Parts objectAtIndex: 1];
		}
	}
	if (!AnimationName)
		AnimationName	= File;
	else if ([AnimationName isEqualToString: @""])
		AnimationName	= Filename;
	else
	{
		Parts	= [AnimationName componentsSeparatedByString: @"*"];
		if ([Parts count] == 2)
		{
			Repetitions		= [[Parts objectAtIndex: 0] intValue];
			AnimationName	= [Parts objectAtIndex: 1];
		}
	}

	[self stopAllActionsByTag: ANIMATION_TAG];//ferma le altre animazioni ed i suoni
	if ((Animation = [[ANCAnimationCache sharedAnimationCache] animationByName: AnimationName forTarget: self]))
	{
		Frame		= [[Animation frames] objectAtIndex: ((FrameNum == -1)?(0):(FrameNum))];
		[self setDisplayFrame: Frame];//visualizzo il primo frame dell'animazione
		CCActionInterval	*SoundAction;
		SoundDescriptor		*SoundDesc;
		if (!(flags & NO_SPRITE_AUDIO))
				SoundDesc	= [[Animation.Sound copy] autorelease];//copio il soundDescriptor perchè ogni istanza del suono deve avere la sua copia per poterci operare
		else	SoundDesc	= nil;
		if ((FrameNum == -1) && ([[Animation frames] count] != 1))
		{
			CCActionInterval	*Action;
			if (Animation.WalkLength != 0)
			{
				Action					= [WalkAnimate actionWithAnimation: Animation];
				if (SoundDesc)
				{
					SoundAction				= (CCActionInterval*)[SoundDesc getAudioActionWithRepetitions: 0];
					SoundAction.tag			= ANIMATION_TAG;
					[self runAction: SoundAction];
				}
			}
			else
			{
				Action					= [CCAnimate actionWithAnimation: Animation restoreOriginalFrame: false];
				if (SoundDesc)
				{
					SoundAction				= (CCActionInterval*)[SoundDesc getAudioActionWithRepetitions: 1];
					SoundAction.tag			= ANIMATION_TAG;
					SoundAction				= [RunAction actionWithActionToRun: SoundAction andTarget: nil forceInstant: true];//incapsulo l'azione in una runAction per evitare che la CCSpawn allunghi la sua durata
					Action					= [CCSpawn actionOne: Action two: SoundAction];//il suono deve essere il secondo in modo da non essere ucciso dall'animazione
				}
				if (Repetitions == 0)
						Action			= [CCRepeatForever actionWithAction: Action];
				else	Action			= [CCRepeat actionWithAction: Action times: Repetitions];
			}
			Action.tag					= ANIMATION_TAG;
			[self runAction: Action];
		}
		else if (SoundDesc)
		{
			SoundAction						= (CCActionInterval*)[SoundDesc getAudioActionWithRepetitions: 0];
			SoundAction.tag					= ANIMATION_TAG;
			[self runAction: SoundAction];
		}
	}
	else if ((Frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: AnimationName]))	//plist già caricato cerco nella cache dei frame
		[self setDisplayFrame: Frame];
	else 
RETRY:	if ((Texture	= [[CCTextureCache sharedTextureCache] textureForKey: File]))//chiede alla cache l'oggetto texture corrispondente al file
	{
		[Filename release];
		Filename	= nil;
		[animations_ release];
		animations_	= nil;
		[self setDisplayFrame: [CCSpriteFrame frameWithTexture:Texture rect:CGRectMake(0, 0, Texture.contentSize.width, Texture.contentSize.height)]];
//		[self setTexture: Texture];
//		[self setTextureRectInPixels: CGRectMake(0, 0, Texture.contentSize.width, Texture.contentSize.height) rotated:0 untrimmedSize: Texture.contentSize];
	}
	else
	{//le cache non hanno restituito nulla, è un'immagine la carico nella cache
		if (!Loaded)
		{
			Loaded	= true;
			[[ANCAnimationCache sharedAnimationCache] lockOutClean];
			[[ANCAnimationCache sharedAnimationCache] loadAtlasFile: File];
			goto RETRY;
		}
		NSAssert1(false, @"Unable to show image %@", File);
	}
	if (Loaded)
		[[ANCAnimationCache sharedAnimationCache] unlockClean];
}

-(bool)hasState: (NSString*) StateName
{
	if (Filename == nil)	return false;
	if ((!StateName) ||
		([StateName isEqualToString: @""]))
			StateName	= Filename;
	else
	{
		NSArray *StateNameParts	= [StateName componentsSeparatedByString: @"."];
		if ([StateNameParts count] > 1)
		{
			for (StateName in StateNameParts)
				if (![self hasState: StateName])
					return false;
			return true;
		}
	}
	
	if ([[ANCAnimationCache sharedAnimationCache] animationByName: StateName forTarget: self])
		return true;
	return false;
}

-(ANCAnimation*)getState: (NSString*) StateName
{
	if (Filename == nil)	return nil;
	if ((!StateName) ||
		([StateName isEqualToString: @""]))
			StateName	= Filename;
	ANCAnimation	*Animation	= (ANCAnimation*)[[ANCAnimationCache sharedAnimationCache] animationByName: StateName forTarget: self];
	NSAssert2(Animation, @"State not found %@ for %@", StateName, Filename);
	return Animation;
}

-(CCFiniteTimeAction*)getStateAction:(NSString*) StateName times: (int) Times
{
	return [self getStateAction: StateName times: Times flags: 0];
}

-(CCFiniteTimeAction*)getStateAction:(NSString*) StateName times: (int) Times flags: (int)flags
{
	NSArray				*StateNameParts	= nil;
	int					FrameIndex		= 0;
	CCFiniteTimeAction	*Return;
	if (StateName)
	{
		StateNameParts	= [StateName componentsSeparatedByString: @"@"];
		if		([StateNameParts count] == 2)
		{
			StateName	= [StateNameParts objectAtIndex: 1];
			FrameIndex	= [[StateNameParts objectAtIndex: 0] intValue];
		}
		else if ([StateNameParts count] == 1)
		{
			StateNameParts	= [StateName componentsSeparatedByString: @"."];
			if ([StateNameParts count] > 1)
			{
				NSMutableArray	*Sequence	= [NSMutableArray arrayWithCapacity: [StateNameParts count]];
				for (StateName in StateNameParts)
				{
					Return						= [self getStateAction: StateName times: 1 flags: flags];
					Return.stopSimilarAction	= false;	//impedisce alle azioni interne di uccidere quella esterna
					[Sequence addObject: Return];
				}
				Return						= [CCSequence actionsWithArray: Sequence];
				if (Times == 0)
				{
					Return					= (CCActionInterval*)[CCRepeatForever actionWithAction: (CCActionInterval*)Return];
					Return.tag				= ANIMATION_TAG;
					Return					= [RunAction actionWithActionToRun: Return];
				}
				else if (Times != 1) Return	= [CCRepeat actionWithAction: Return times: Times];
				Return.tag					= ANIMATION_TAG;
				Return.stopSimilarAction	= true;	//ferma altre azioni con lo stesso tag
				return	Return;
			}
			StateNameParts	= nil;
		}
		else	NSAssert(false, @"Cannot decode StateName");
	}
	
	ANCAnimation				*State			= [self getState: StateName];
	CCFiniteTimeAction			*LoopSound		= nil;
	CCFiniteTimeAction			*Sound			= nil;
	SoundDescriptor				*SoundDesc;
	CCFiniteTimeAction			*ParticleAction;
	if ((flags & NO_SPRITE_AUDIO) || (!State.Sound))
		SoundDesc	= nil;
	else
	{
		SoundDesc		= [[State.Sound copy] autorelease];//copio il soundDescriptor perchè ogni istanza del suono deve avere la sua copia per poterci operare
		LoopSound		= (CCFiniteTimeAction*)[SoundDesc getAudioActionWithRepetitions: 0];
		LoopSound.tag	= ANIMATION_TAG;//in modo da essere ucciso quando entra una nuova animazione
		LoopSound		= [RunAction actionWithActionToRun: LoopSound];

		Sound			= (CCFiniteTimeAction*)[SoundDesc getAudioActionWithRepetitions: 1];
		Sound.tag		= ANIMATION_TAG;//in modo da essere ucciso quando entra una nuova animazione
		Sound			= [RunAction actionWithActionToRun: Sound andTarget:nil forceInstant: true];
	}


	if ((flags & NO_PARTICLE) || (!State.Particle))
		ParticleAction	= nil;
	else
	{
		ParticleSystemDescriptor	*Particle	= [[State.Particle copy] autorelease];
		ParticleAction	= [Particle getParticleSystemAction];//copio il ParticleDescriptor perchè ogni istanza deve avere la sua copia per poterci operare
	}

	if (StateNameParts)
	{//ho chiestro un frame
		Return						= [DisplayFrame actionWithSpriteFrame: [[State frames] objectAtIndex: FrameIndex]];
		if (SoundDesc)		Return	= [CCSpawn actionOne: Return two: LoopSound];//il suono deve essere il secondo in modo da non essere ucciso dall'animazione
		if (ParticleAction)	Return	= [CCSpawn actionOne: Return two: ParticleAction];//il particle deve essere il secondo in modo da non essere ucciso dall'animazione
	}
	else
	{
		CCActionInterval	*Animation	= [CCAnimate actionWithAnimation: State restoreOriginalFrame: (flags & RESTORE_ORIGINAL_FRAME)];
		if (SoundDesc)		Animation	= [CCSpawn actionOne: Animation two: Sound];//il suono deve essere il secondo in modo da non essere ucciso dall'animazione
		if (ParticleAction)	Animation	= [CCSpawn actionOne: Animation two: ParticleAction];
		if (Times == 0)
		{
			if (State.WalkLength != 0)
			{
				Return						= [WalkAnimate actionWithAnimation: State];
				Return.tag					= ANIMATION_TAG;
				Return						= [RunAction actionWithActionToRun: Return];
				if (SoundDesc)		Return	= [CCSpawn actionOne: Return two: LoopSound];//il suono deve essere il secondo in modo da non essere ucciso dall'animazione
				if (ParticleAction)	Return	= [CCSpawn actionOne: Return two: ParticleAction];
			}
			else
			{
				if ([State.frames count] == 1)
				{
					Return						= [DisplayFrame actionWithSpriteFrame: [State.frames lastObject]];
					if (Sound)			Return	= [CCSpawn actionOne: Return two: LoopSound];//il suono deve essere il secondo in modo da non essere ucciso dall'animazione
					if (ParticleAction)	Return	= [CCSpawn actionOne: Return two: ParticleAction];
				}
				else
				{//Animation ha già il suono ed il particle all'interno
					Return				= [CCRepeatForever actionWithAction: Animation];
					Return.tag			= ANIMATION_TAG;
					Return				= [RunAction actionWithActionToRun: Return];
				}
			}
		}
		else
		{
			if (Times == 1)	Return		= Animation;
			else			Return		= [CCRepeat actionWithAction: Animation times: Times];
		}
		if ((Times != 0) && (State.HideOnEnd))
			Return						= [CCSequence actionOne: Return two: [CCHide action]];
	}
	Return.tag							= ANIMATION_TAG;
	if (!(flags & DONOT_STOP_SIMILAR_ACTIONS))
		Return.stopSimilarAction		= true;	//ferma altre azioni con lo stesso tag
	return Return;
}

-(CCFiniteTimeAction*)runState:(NSString*) StateName times: (int) Times
{
	return [self runState: StateName times: Times flags: 0];
}

-(CCFiniteTimeAction*)runState:(NSString*) StateName times: (int) Times flags: (int)flags
{
	return (CCFiniteTimeAction*)[self runAction: [self getStateAction: StateName times: Times flags: flags]];
}

-(void)StopAnimation
{
	[self stopAllActionsByTag: ANIMATION_TAG];
}

-(bool)addingChildTo:(CCNode*)Father z:(int)z tag:(int) aTag
{
#ifdef DISABLE_BATCH
	return true;
#else
	if ([Father isKindOfClass:[CCSpriteBatchNode class]])
		return true;//evita un loop infinito
	if ([Father isKindOfClass:[ANCSprite class]])
		return true;//non posso aggiungere un batchnode come figlio di una sprite che già li usa
	[ANCSpriteBatchNode addSprite: self toFather: Father onZ: z];
	return false;
#endif
}

-(bool)removingChildFrom: (CCNode*)Father cleanup: (bool)doCleanup
{
	if ([Father.children containsObject: batchNode_] )//verifica che il batchnode a cui è aggregata la sprite sia figlio di Father
	{
		[batchNode_ removeChild: self cleanup: doCleanup];
		return true;
	}
	return false;
}

-(void)setCropped: (bool)Cropped
{
	if (self.cropped == Cropped)
		return;
	NSAssert(self.cropped, @"Cannot corp sprite using self.cropped");
	[self setTextureRect: OriginalRect];
	OriginalRect.origin	= ccp(-1, 0);
}

-(bool)cropped
{
	if (OriginalRect.origin.x >= 0)
			return true;
	else	return false;
}

-(void)setCropArea: (CGRect)Area
{
	if (!self.cropped)
		OriginalRect	= rect_;
	Area.origin			= ccp(Area.origin.x, 1 - Area.size.height - Area.origin.y);//le immagini nella memoria video sono specchiate verticalmente
	CGRect	VisibleRect;
	VisibleRect.origin	= ccpAdd(OriginalRect.origin, ccp(OriginalRect.size.width * Area.origin.x, OriginalRect.size.height * Area.origin.y));
	VisibleRect.size	= CGSizeMake(OriginalRect.size.width * Area.size.width, OriginalRect.size.height * Area.size.height);

	[self setContentSize: VisibleRect.size];
	[self setTextureRectInPixels: VisibleRect rotated: rectRotated_	untrimmedSize: contentSizeInPixels_];
}

-(CGRect)cropArea
{
	if (!self.cropped)	return CGRectMake(0, 0, 1, 1);
	return CGRectMake((rect_.origin.x - OriginalRect.origin.x) / OriginalRect.size.width, (rect_.origin.y - OriginalRect.origin.y) / OriginalRect.size.height,
					 rect_.size.width / OriginalRect.size.width, rect_.size.height / OriginalRect.size.height);
}

-(void)autoCenter
{		
	CGPoint	Center	= [self imageCenter];//in node coordinate, centro l'immagine
	float	Height	= [self untrimmedHeight];
	float	Width	= [self untrimmedWidth];
	NSAssert((Width != 0) && (Height != 0), @"Autocenter failed");
	self.anchorPoint	= ccp(Center.x / Width, Center.y / Height);
}

//ritorna un oggetto di tipo ANCSprite indipendentemente dal tipo di oggetto che si copia
-(id) copyWithZone: (NSZone*) zone
{	
	CCSprite *Sprite	= [[ANCSprite allocWithZone: zone] init];//[self class] per copiare con lo stesso tipo di oggetto
	[Sprite setDisplayFrame: [self displayedFrame]];
/*	Sprite.flipX		= flipX_;
	Sprite.scaleX		= self.scaleX;
	Sprite.flipY		= flipY_;
	Sprite.scaleY		= self.scaleY;
	Sprite.position		= position_;
	Sprite.anchorPoint	= anchorPoint_;
	Sprite.rotation		= rotation_;	//NON SUPPORTATO
*/	[Sprite setTransform: [self getTransform]];
	return Sprite;
}

-(void) setTransform: (CGTransform)Transform
{
	scaleX_		= Transform.scaleX;
	scaleY_		= Transform.scaleY;
	rotation_	= Transform.rotation;
	skewX_		= Transform.skewX;
	skewY_		= Transform.skewY;
	
	isTransformDirty_ = isInverseDirty_ = YES;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	isTransformGLDirty_ = YES;
#endif	
//	SET_DIRTY_RECURSIVELY();
	if( usesBatchNode_ && ! recursiveDirty_ ) {	
		dirty_ = recursiveDirty_ = YES;				
		if( hasChildren_)
			[self setDirtyRecursively:YES];
	}
	
	self.flipX		= Transform.flipX;
	self.flipY		= Transform.flipY;
}

-(CGTransform) getTransform
{
	return (CGTransform){scaleX_, scaleY_, rotation_, skewX_, skewY_, flipX_, flipY_};
}

-(void)dealloc
{
	[CurrentFrame release];
	[Filename release];
    [super dealloc];
}
@end
