//
//  ANCScene.m
//  Prova
//
//  Created by mad4chip on 21/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANCScene.h"
#import "CocosAddOn.h"
#import "ANCSprite.h"
#import "ANCAnimationCache.h"
#import "ObjectiveCAddOn.h"
#import "functions.h"
#import "ColoredSquareSprite.h"
#import "ColoredCircleSprite.h"
#import "SoundManager.h"
#import "SoundDescriptor.h"
/*
@implementation ANCScene_Builder

+(id)buildScene: (ANCScene*) Scene fromDictionary: (NSDictionary*)Dictionary
{
	return [[[self alloc] buildScene: Scene fromDictionary: Dictionary] autorelease];
}

-(id)buildScene: (ANCScene*) Scene fromDictionary: (NSDictionary*)Dictionary
{
	if ((self = [super init]))
	{
		Configuration	= [NSMutableArray		arrayWithCapacity: 0];
		SceneParts		= [NSMutableDictionary	dictionaryWithCapacity: 0];
		CfgDeepLevel	= 0;

		FirstLayer		= true;
		useVertexZ		= false;
		
	}
}

-(NSDictionary*)getCfgElementForKey: (NSString*)Key
{
	int	CfgDeepLevel	= [Configuration count];
	id	Result			= nil;
	for (int i = CfgDeepLevel - 1; i >= 0; i--)
		if ((Result = [[Configuration objectAtIndex: i] localizedObjectForKey: Key]))
			return Result;
	return Result;
}

-(void)dealloc
{
	[Configuration	release];
	[SceneParts		release];
	[super dealloc];
}
@end
*/
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation ANCScene

+(id)initMenu
{
	return [[[self alloc] initMenu] autorelease];
}

-(id)initMenu
{
	NSAssert(false, @"Please override me");
	return nil;
}

+(id)sceneWithFile: (NSString *)FileName SceneManager: (id<SceneManagerProtocol>)Manager
{
	return [[[self alloc] initWithFile: FileName SceneManager: Manager] autorelease];
}

-(id)initWithFile: (NSString *)FileName SceneManager: (id<SceneManagerProtocol>)Manager
{
	NSMutableDictionary	*FileContent	= [NSMutableDictionary dictionaryWithContentsOfFile: [CCFileUtils fullPathFromRelativePath: FileName]];
	return [self initWithDictionary: FileContent SceneManager: Manager];
}

+(id)sceneWithDictionary: (NSDictionary *)Dictionary SceneManager: (id<SceneManagerProtocol>)Manager
{
	return [[[self alloc] initWithDictionary: (NSDictionary *)Dictionary SceneManager: Manager] autorelease];
}

-(bool)RoleHandler: (CCNode*)Node andData: (NSDictionary*)Dictionary
{	return true;	}

-(void)BtnClick: (CCMenuItem*)Button
{
	NSAssert(Button.tag >= 0, @"Only tag >= 0 are supported");
	[(id<SceneManagerProtocol>)SceneManager ChangeScene: Button.tag];
}

-(id)initWithDictionary: (NSDictionary *)Dictionary SceneManager: (id<SceneManagerProtocol>)Manager
{
	if ((self = [self init]))
	{
		Configuration			= [Dictionary retain];
		ConfigurationLevels		= [[NSMutableArray		arrayWithCapacity: 0] retain];
		SceneParts				= [[NSMutableDictionary dictionaryWithCapacity: 0] retain];
		[[ANCAnimationCache sharedAnimationCache] lockOutClean];
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		isStandardTouchEnabled_	= false;
		isTargetedTouchEnabled_	= false;
		isAccelerometerEnabled_	= false;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		isMouseEnabled_			= false;
		isKeyboardEnabled_		= false;
#endif

		FirstLayer		= true;
		useVertexZ		= false;
		delay			= 0;
		SceneManager	= Manager;
		[self ParseDictionary: Dictionary Parent: self];
		if (delay == 0)
				[self animationsEnd];
		else	[self runAction: [CCSequence actionOne: [CCDelayTime actionWithDuration: delay]
												   two: [CCCallFunc actionWithTarget: self selector: @selector(animationsEnd)]]];
		[[ANCAnimationCache sharedAnimationCache] unlockClean];

		BackgroundMusic	= [Dictionary localizedObjectForKey: @"backgroundmusic"];
		[BackgroundMusic retain];
	}
	return self;
}

//caso 1	l'ultimo livello di ConfigurationLevels è una stringa		=>	ritorna quella altrimenti cerca
//caso 2	l'ultimo livello di ConfigurationLevels NON è una stringa	=>	cerca l'oggetto corrispondente a Key
//caso 3	Key non è stato trovato nell'ultimo livello					=>	cerca nei livelli precedenti con Key = @Key
-(NSString*)getCfgElementForKey: (NSString*)Key required: (bool)required recursive: (bool) recursive
{
	NSString		*Result	= nil;
	NSDictionary	*Row	= [ConfigurationLevels lastObject];

	if ([Row isKindOfClass: [NSString class]])
		return (NSString*)Row;

	if (!(Result = [Row localizedObjectForKey: Key]) && recursive)
	{
		int	CfgDeepLevel	= [Configuration count];
		Key					= [NSString stringWithFormat: @"@%@", Key];//inserisce la @ avanti alla chiave per cercare i parametri ereditati
		for (int i = CfgDeepLevel - 2; i >= 0; i--)//esclude il livello corrente
			if ((Result = [[ConfigurationLevels objectAtIndex: i] localizedObjectForKey: Key]))
				break;
	}
	NSAssert(Result || !required, @"Misssing a required parameter %@", Key);
	return Result;
}

-(void) pushConfigurationLevel: (NSDictionary*) Dictionary
{
	[ConfigurationLevels addObject: Dictionary];
}

-(void) popConfigurationLevel
{
	[ConfigurationLevels removeLastObject];
}

-(void)dealloc
{
	CCLOG(@"ANCScene dealloc %@", [self class]);
	rivedere dealloc
	[BackgroundMusic	release];
	[SceneParts			release];
	[Configuration		release];
	[super dealloc];
}

//--------- funzioni che impostano i principali parametri degli elementi --------------
-(void)applyColorAndTransformToNode: (CCNode*) Node
{
	NSString	*Value;
	if ((Value = [self getCfgElementForKey: @"color"		required: false recursive: true]))	[Node setColorAndOpacity: ccColor4BFromString(Value)];
	if ((Value = [self getCfgElementForKey: @"transform"	required: false recursive: true]))	[Node setTransform: CGTransformFromString(Value)];
	if ((Value = [self getCfgElementForKey: @"scaletosize"	required: false recursive: true]))	[Node scaleToSize: CGSizeFromSizeOrFloatString(Value) keepAspect: true];
	if ((Value = [self getCfgElementForKey: @"stretchtosize"required: false recursive: true]))	[Node scaleToSize: CGSizeFromSizeOrFloatString(Value) keepAspect: false];

	if ((Value = [self getCfgElementForKey: @"scale"		required: false recursive: true]))
	{
		NSLog(@"scale deprecated, use transform instead");
		[Node scaleToSize: CGSizeFromSizeOrFloatString(Value) keepAspect: true];
	}
}

-(void)addToParentAndPlaceNode: (CCNode*) Node
{
	NSString	*Value;
	if ((Value = [self getCfgElementForKey: @"position"		required: false recursive: true]))	[Node setPosition: CGPointFromString(Value)];
	if ((Value = [self getCfgElementForKey: @"anchor"		required: false recursive: true]))
	{
		if (([Node respondsToSelector: @selector(autoCenter)]) && ([Value isEqualToString: @"auto"]))
				[(ANCSprite*)Node autoCenter];
		else	[Node setAnchorPoint: CGPointFromString(Value)];
	}
	if ((Value = [self getCfgElementForKey: @"visible"		required: false recursive: true]) && (![Value boolValue]))	Node.visible	= false;
	if ((Value = [self getCfgElementForKey: @"hidenode"		required: false recursive: true]) && (![Value boolValue]))	[Node hideNode];


	int z		= [[self getCfgElementForKey: @"position"	required: ((void*)CurrentParent != (void*)self) recursive: true] intValue];

	[CurrentParent addChild: Node z: z];

	if (useVertexZ)
	{//da fare dopo aver aggiunto il figlio al padre
		if ((Value = [self getCfgElementForKey: @"vertexz"	required: false recursive: true]))
				[Node setVertexZ: [Value floatValue]];
		else	[Node setVertexZ: vertexZForSprite(Node, 0)];
	}
}

-(void) applyContentSizeOnNode: (CCNode*) Node
{
	NSString	*Value;
	if ((Value = [self getCfgElementForKey: @"size"		required: false recursive: true]))	[Node setContentSize: CGSizeFromString(Value)];
}
//--------- funzioni che impostano i principali parametri degli elementi --------------


//--------- Parser per i vari possibili elementi --------------

//immagini
//legge la chiave @"image"
-(CCNode*) getImageFromDictionary: (NSDictionary*)Config
{
	[self pushConfigurationLevel: Config];//deve essere la prima

	ANCSprite	*Sprite;
	NSString	*FileName	= [self getCfgElementForKey: @"image" required: false recursive: true];
	if (FileName)
	{
		Sprite	= [ANCSprite spriteWithFile: FileName];
		[self applyColorAndTransformToNode: Sprite];
		[self addToParentAndPlaceNode: Sprite];
	}

	[self popConfigurationLevel];//deve essere l'ultima
	return Sprite;
}

//testi
//legge la chiave @"text"
-(CCNode*) getTextFromDictionary: (NSDictionary*)Config
{
	[self pushConfigurationLevel: Config];//deve essere la prima

	CCNode		*TextNode		= nil;
	NSString	*TextString		= [self getCfgElementForKey: @"text"	  required: false recursive: true];
	if (TextString)
	{
		NSString	*FontName	= [self getCfgElementForKey: @"fontname"  required: true recursive: true];
		int			FontSize	= [[self getCfgElementForKey: @"fontsize" required: true recursive: true] intValue];
		NSAssert(FontSize > 0, @"Please set a fontsize");
		if ([[FontName pathExtension] isEqualToString: @"fnt"])
		{
			CCLabelBMFont	*Text;
			Text				= [CCLabelBMFont labelWithString: TextString fntFile: FontName];
			Text.Fontsize		= FontSize;
			Text.contentSize	= [Text TrimmedRect].size;
			TextNode			= Text;
		}
		else
		{
			NSString	*Value	= [self getCfgElementForKey: @"textarea"	required: false recursive: true];
			if (Value)
			{
				CGSize			TextSize	= CGSizeFromString(Value);
				CCTextAlignment	Alignment;
				Value	= [self getCfgElementForKey: @"textalignment"	required: false recursive: true];
				if (Value)
				{
					if		([Value isEqualToString: @"center"])	Alignment	= CCTextAlignmentCenter;
					else if ([Value isEqualToString: @"left"])		Alignment	= CCTextAlignmentLeft;
					else if ([Value isEqualToString: @"right"])		Alignment	= CCTextAlignmentRight;
				}
				else Alignment		= CCTextAlignmentLeft;
				TextNode		= [CCLabelTTF labelWithString: TextString dimensions: TextSize alignment: Alignment fontName: FontName fontSize: FontSize];
			}
			else	TextNode	= [CCLabelTTF labelWithString: TextString fontName: FontName fontSize: FontSize];			
		}

		[self applyColorAndTransformToNode: TextNode];
		[self addToParentAndPlaceNode:		TextNode];
	}

	[self popConfigurationLevel];//deve essere l'ultima
	return TextNode;
}

//layer
//legge la chiave @"layercolor"
-(CCNode*) getLayerFromDictionary: (NSDictionary*)Config
{
	[self pushConfigurationLevel: Config];//deve essere la prima

	CCLayer		*Layer	= nil;
	NSString	*Value	= [self getCfgElementForKey: @"layercolor"	required: false recursive: true];
	
	if (Value)
	{
		ccColor4B	StartColor	= ccColor4BFromString(Value);
		Value					= [self getCfgElementForKey: @"layerendcolor"	required: false recursive: true];
		if (Value)
		{
			ccColor4B EndColor	= ccColor4BFromString(Value);
			Value				= [self getCfgElementForKey: @"vector"	required: true recursive: true];
			Layer				= [CCLayerGradient layerWithColor: StartColor fadingTo: EndColor alongVector: CGPointFromString(Value)];
		}
		else	Layer		= [CCLayerColor layerWithColor: StartColor];

		if (FirstLayer)
		{
			Layer.anchorPoint	= CGPointZero;//il primo layer copre tutto lo schermo
			Layer.position		= CGPointZero;
			FirstLayer			= false;
			[self addToParentAndPlaceNode:	Layer];
		}
		else
		{
			Layer.isRelativeAnchorPoint	= true;
			[self addToParentAndPlaceNode:	Layer];
			[self applyContentSizeOnNode:	Layer];
		}
	}

	[self popConfigurationLevel];//deve essere l'ultima
	return Layer;
}
//--------- Parser per i vari possibili elementi --------------


-(void)ParseDictionary: (NSDictionary *)Dictionary Parent: (CCNode*)Parent
{
	NSAssert(Dictionary, @"Dictionary cannot be nil");
																															//valori predefiniti
	[ConfigurationLevels addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"{  0,   0,   0,   0}",	@"@layercolor",	//colore		per layer	se non sà cosa creare crea un layer trasparente
																				@"{255, 255, 255, 255}",	@"@color",		//colore		per testi, cerchi, rettangoli
																				@"{  0,   0}",				@"@position",	//posizione		per tutto
																				@"{  0,   0}",				@"@anchor",		//anchorpoint	per tutto
									 nil]];

	NSString	*Value;
	if ((Value = [Dictionary localizedObjectForKey: @"usevertexz"]) && ([Value boolValue]))
		useVertexZ	= true;
	if ((Value = [Dictionary localizedObjectForKey: @"atlas"]))
		[[ANCAnimationCache sharedAnimationCache] loadAtlasFile: Value];
	CurrentParent	= self;

	[self getLayerFromDictionary: Dictionary];
}




-(void)oldParseDictionary: (NSDictionary *)Dictionary Parent: (CCNode*)Parent
{
	NSAssert(Dictionary, @"Dictionary cannot be nil");

	CGPoint				BtnPosition;
	CCNode				*NormalSprite;
	CCNode				*SelectedSprite;
	CCNode				*DisabledSprite;

	ANCSprite			*ItemBackground;
	NSString			*ItemBackgroundFile;
	ANCSprite			*ItemForeground;
	NSString			*ItemForegroundFile;
	
	ANCMenuButton		*MenuButton;
	NSDictionary		*ButtonData;
	NSString			*Scene;
	NSString			*Value;
	CGPoint				Anchor;
	bool				AutoAnchor		= false;
	float				BtnRotation;
	int					z;
	ANCMenuAdvanced		*Menu			= nil;
	CCLayer				*Layer;

	NSString			*ButtonText;
	NSString			*FontName;
	int					FontSize;
	ccColor3B			FontColor	= ccc3(255, 255, 255);
	ccColor4B			Color;
	SoundDescriptor		*Sound				= nil;
	SoundDescriptor		*DisabledSound		= nil;

	if ((Value = [Dictionary localizedObjectForKey: @"layercolor"]))
	{
		ccColor4B	StartColor			= ccColor4BFromString(Value);
		if ((Value = [Dictionary localizedObjectForKey: @"layerendcolor"]))
		{
			Color						= ccColor4BFromString(Value);
			if ((Value = [Dictionary localizedObjectForKey: @"vector"]))
							Layer		= [CCLayerGradient layerWithColor: StartColor fadingTo: Color alongVector: CGPointFromString(Value)];
			else			Layer		= [CCLayerGradient layerWithColor: StartColor fadingTo: Color];
		}
		else				Layer		= [CCLayerColor layerWithColor: StartColor];
	}
	else					Layer		= [CCLayerColor layerWithColor: ccc4(0, 0, 0, 0)];
	if (([Dictionary localizedObjectForKey: @"role"]) &&
		(![self RoleHandler: Layer andData: Dictionary]))
			return;
	Layer.anchorPoint	= CGPointZero;
	Layer.position		= CGPointZero;
	if (FirstLayer)
	{
		Value							= [Dictionary localizedObjectForKey: @"usevertexz"];
		if ((Value) && ([Value boolValue]))
			useVertexZ					= true;
	}
	else
	{
		if ((Value = [Dictionary localizedObjectForKey: @"anchor"]))	Layer.anchorPoint	= CGPointFromString(Value);
		if ((Value = [Dictionary localizedObjectForKey: @"position"]))	Layer.position		= CGPointFromString(Value);
		if ((Value = [Dictionary localizedObjectForKey: @"size"]))		[Layer setContentSize: CGSizeFromString(Value)];
		Layer.isRelativeAnchorPoint		= true;
	}

	if (!(Value = [Dictionary localizedObjectForKey: @"z"]))
	{
		NSAssert(FirstLayer, @"Missing z for Layer");	// il primo layer può non avere z
		z								= 0;
	}
	else	z							= [Value intValue];
	FirstLayer	= false;

	if ((Value = [Dictionary localizedObjectForKey: @"include"]))
	{
		if ([Value isKindOfClass: [NSArray class]])
			for (NSString *Name in (NSArray*)Value)
			{
				NSDictionary	*FileContent	= [NSDictionary dictionaryWithContentsOfFile: [CCFileUtils fullPathFromRelativePath: Name]];
				NSAssert(FileContent, @"Unable to include file %@", Name);
				[self ParseDictionary: FileContent Parent: Layer];
			}
		else
		{
			NSDictionary	*FileContent	= [NSDictionary dictionaryWithContentsOfFile: [CCFileUtils fullPathFromRelativePath: Value]];
			NSAssert(FileContent, @"Unable to include file %@", Value);
			[self ParseDictionary: FileContent Parent: Layer];
		}
	}

	if ((useVertexZ) && 
		(Value = [Dictionary localizedObjectForKey: @"vertexz"]))
			Layer.vertexZ	= [Value floatValue];
	[Parent addChild: Layer z: z];
	SetVertexZForNode(Dictionary, Layer);
	if ((Value = [Dictionary localizedObjectForKey: @"visible"]) && (![Value boolValue]))
		Layer.visible					= false;
	if ((Value = [Dictionary localizedObjectForKey: @"hidenode"]) && (![Value boolValue]))
		[Layer hideNode];

	if ((Value = [Dictionary localizedObjectForKey: @"atlas"]))
		[[ANCAnimationCache sharedAnimationCache] loadAtlasFile: Value];

	ItemBackgroundFile					= [Dictionary localizedObjectForKey: @"itembackground"];
	ItemForegroundFile					= [Dictionary localizedObjectForKey: @"itemForeground"];
	FontName							= [Dictionary localizedObjectForKey: @"fontname"];
	FontSize							= [[Dictionary localizedObjectForKey: @"fontsize"] intValue];
	if ((Value = [Dictionary localizedObjectForKey: @"fontcolor"]))
		FontColor						= ccColor3BFromString(Value);
	if ((Value = [Dictionary localizedObjectForKey: @"buttonclick"]))
		Sound							= [SoundDescriptor soundDescriptorFromDictionary: (NSDictionary*)Value];
	if ((Value = [Dictionary localizedObjectForKey: @"disabledclick"]))
		DisabledSound					= [SoundDescriptor soundDescriptorFromDictionary: (NSDictionary*)Value];

	for (NSString *Key in Dictionary)
	{
		ButtonData						= [Dictionary localizedObjectForKey: Key];
		if (![ButtonData isKindOfClass: [NSDictionary class]])
			continue;	//evita le stringhe che definiscono il layer
		if ([ButtonData localizedObjectForKey: @"layercolor"])
		{//gruppi di tasti
			[self ParseDictionary: ButtonData Parent: Layer];
			continue;
		}

		if ((Value = [ButtonData localizedObjectForKey: @"include"]))
		{
			if ([Value isKindOfClass: [NSArray class]])
				for (NSString *Name in (NSArray*)Value)
				{
					NSDictionary	*FileContent	= [NSDictionary dictionaryWithContentsOfFile: [CCFileUtils fullPathFromRelativePath: Name]];
					NSAssert(FileContent, @"Unable to include file %@", Name);
					[self ParseDictionary: FileContent Parent: Layer];
				}
			else
			{
				NSDictionary	*FileContent	= [NSDictionary dictionaryWithContentsOfFile: [CCFileUtils fullPathFromRelativePath: Value]];
				NSAssert(FileContent, @"Unable to include file %@", Value);
				[self ParseDictionary: FileContent Parent: Layer];
			}
			continue;
		}

		CCLOG(@"ANCScene Key %@", Key);
		Value							= [ButtonData localizedObjectForKey: @"z"];
		NSAssert(Value, @"Missing z for %@", Key);
		z								= [Value intValue];

		if ((Value = [ButtonData localizedObjectForKey: @"anchor"]))
		{
			if ([Value isEqualToString: @"auto"])
					AutoAnchor			= true;
			else	Anchor				= CGPointFromString(Value);
		}
		else	Anchor					= CGPointZero;
		
		if ((Value = [ButtonData localizedObjectForKey: @"position"]))
					BtnPosition			= CGPointFromString(Value);
		else		BtnPosition			= CGPointZero;
		
		if ((Value = [ButtonData localizedObjectForKey: @"tmx"]))
		{
			CCTMXTiledMap *TMX_Map		= [CCTMXTiledMap tiledMapWithTMXFile: Value];
			TMX_Map.anchorPoint			= Anchor;
			TMX_Map.position			= BtnPosition;
			if (([ButtonData localizedObjectForKey: @"role"]) &&
				(![self RoleHandler: TMX_Map andData: ButtonData]))
					return;			
			[self addChild:TMX_Map z: z];

			if ((useVertexZ) &&
				(Value = [Dictionary localizedObjectForKey: @"vertexz"]))
			{
				float	VertexZ	= [Value floatValue];
				CCNode	*Node;
				TMX_Map.vertexZ	= VertexZ;
				CCARRAY_FOREACH(TMX_Map.children, Node)
				{
					Node.vertexZ	= VertexZ;
				}
			}
			continue;
		}

		ButtonText		= nil;//uso ButtonText due volte non levare
		NormalSprite	= nil;
		DisabledSprite	= nil;
		SelectedSprite	= nil;
		ItemBackground	= nil;
		ItemForeground	= nil;
		if ((NormalSprite = [self getImageFromDictionary: ButtonData]))
		{
			CCFiniteTimeAction	*Action;
			Action			= (CCFiniteTimeAction*)[NormalSprite getActionByTag: ANIMATION_TAG];
			if (([Action isKindOfClass: [CCFiniteTimeAction class]]) &&
				(Action.duration > delay))
					delay	= Action.duration;
		}
		else
		{
			if ((Value = [ButtonData localizedObjectForKey: @"color"]))
					Color	= ccColor4BFromString(Value);
			else	Color	= ccc4(255, 255, 255, 255);

			if		((Value = [ButtonData localizedObjectForKey: @"circleradius"]))		NormalSprite	= [ColoredCircleSprite circleWithColor: Color radius: [Value floatValue]];
			else if ((Value = [ButtonData localizedObjectForKey: @"rectanglesize"]))	NormalSprite	= [ColoredSquareSprite squareWithColor: Color size:	  CGSizeFromString(Value)];
			else if ((ButtonText = [ButtonData localizedObjectForKey: @"text"]))
			{
				if ((Value = [ButtonData localizedObjectForKey: @"fontname"]))	FontName	= Value;
				if ((Value = [ButtonData localizedObjectForKey: @"fontsize"]))	FontSize	= [Value intValue];
				if ((Value = [ButtonData localizedObjectForKey: @"fontcolor"]))	FontColor	= ccColor3BFromString(Value);
				NSAssert(FontName, @"Please set a font name to use");
				NSAssert(FontSize > 0, @"Please set a fontsize");
				if ([[FontName pathExtension] isEqualToString: @"fnt"])
				{
					//uso il font preso dall'immagine
					NSAssert([ButtonData localizedObjectForKey: @"textarea"] == nil, @"Text Area could not be used! CUSTOM FONT");
					NormalSprite = [CCLabelBMFont labelWithString: ButtonText fntFile:FontName];
					((CCLabelBMFont *)NormalSprite).Fontsize	= FontSize;
					((CCLabelBMFont *)NormalSprite).color		= FontColor;
					NormalSprite.contentSize = [NormalSprite TrimmedRect].size;
				}
				else
				{
					//uso il font normale
					if ((Value = [ButtonData localizedObjectForKey: @"textarea"]))
					{
						CGSize			TextSize	= CGSizeFromString(Value);
						CCTextAlignment	Alignment;
						if ((Value = [ButtonData localizedObjectForKey: @"textalignment"]))
						{
							if		([Value isEqualToString: @"center"])	Alignment	= CCTextAlignmentCenter;
							else if ([Value isEqualToString: @"left"])		Alignment	= CCTextAlignmentLeft;
							else if ([Value isEqualToString: @"right"])		Alignment	= CCTextAlignmentRight;
						}
						else Alignment		= CCTextAlignmentLeft;
						NormalSprite		= [CCLabelTTF labelWithString: ButtonText dimensions: TextSize alignment: Alignment fontName: FontName fontSize: FontSize];
					}
					else	NormalSprite	= [CCLabelTTF labelWithString: ButtonText fontName: FontName fontSize: FontSize];
					NormalSprite.color		= FontColor;
				}
			}
		}
		BtnRotation						= [[ButtonData localizedObjectForKey: @"rotation"] floatValue];
		if ((Scene = [ButtonData localizedObjectForKey: @"scene"]))
		{//tasto di un menu
			
			
			if (NormalSprite)
			{
				if ((Value = [ButtonData localizedObjectForKey: @"selectedimage"]))
					SelectedSprite	= [self getImageFromDictionary: Value];
/*				{
					SelectedSprite			= [ANCSprite spriteWithFile: Value];
					SelectedSprite.scaleX	= NormalSprite.scaleX;
					SelectedSprite.scaleY	= NormalSprite.scaleY;				
				}
*/
/*				else if (ButtonText)
				{
					if ((Value = [ButtonData localizedObjectForKey: @"fontname"]))	FontName	= Value;
					if ((Value = [ButtonData localizedObjectForKey: @"fontsize"]))	FontSize	= [Value intValue];
					if ((Value = [ButtonData localizedObjectForKey: @"fontcolor"]))	FontColor	= ccColor3BFromString(Value);
					NSAssert(FontName, @"Please set a font name to use");
					NSAssert(FontSize > 0, @"Please set a fontsize");
					SelectedSprite			= [CCLabelTTF labelWithString: ButtonText fontName: FontName fontSize: FontSize];
				}
*/	/*			else									   
				{
					SelectedSprite			= [[NormalSprite copy] autorelease];
					if ((Value = [ButtonData localizedObjectForKey: @"scaleonselect"]))
					{
						CGPoint	temp				= CGPointFromString(Value);
						SelectedSprite.scaleX		= temp.x * NormalSprite.scaleX;
						SelectedSprite.scaleY		= temp.y * NormalSprite.scaleY;
					}
					if ((Value = [ButtonData localizedObjectForKey: @"tintonselect"]))
						SelectedSprite.color	= ccColor3BFromString(Value);
				}
				Value					= [ButtonData localizedObjectForKey: @"rotateonselect"];
				SelectedSprite.rotation	= (BtnRotation + [Value floatValue]) / 180 * M_PI;
	 */
			}
			else
			{
				Value						= [ButtonData localizedObjectForKey: @"size"];
				NSAssert(Value, @"Missing size for button", Key);
				CGSize Size					= CGSizeFromString(Value);
				NormalSprite				= [ColoredSquareSprite squareWithColor: ccc4(255, 255, 255, 0) size: Size];
				SelectedSprite				= [ColoredSquareSprite squareWithColor: ccc4(255, 255, 255, 0) size: Size];
			}

			if ((Value = [ButtonData localizedObjectForKey: @"disabledimage"]))
				DisabledSprite			= [ANCSprite spriteWithFile: Value];

			if ((Value = [ButtonData localizedObjectForKey: @"opacitydisabled"]))
				NSLog(@"opacitydisabled deprecated");

			//creo qui MenuButton per poterlo passare a RoleHandler
			//verifico se c'è un background internamente
			if ((Value = [ButtonData localizedObjectForKey: @"itembackground"]))	
				ItemBackground	= [ANCSprite spriteWithFile: Value];
			else if (ItemBackgroundFile)	
				ItemBackground	= [ANCSprite spriteWithFile: ItemBackgroundFile];
			//verifico se c'è un foreground internamente
			if ((Value = [ButtonData localizedObjectForKey: @"foreground"]))	
				ItemForeground	= [ANCSprite spriteWithFile: Value];
			else if (ItemForegroundFile)	
				ItemForeground	= [ANCSprite spriteWithFile: ItemForegroundFile];

			
			MenuButton	= [ANCMenuButton itemFromNormalSprite: NormalSprite selectedSprite: SelectedSprite disabledSprite: DisabledSprite target: self selector: @selector(BtnClick:)];
			if ((Value = [ButtonData localizedObjectForKey: @"buttonclick"]))		Sound						= [SoundDescriptor soundDescriptorFromDictionary: (NSDictionary*)Value];
			if ((Value = [ButtonData localizedObjectForKey: @"disabledclick"]))		DisabledSound				= [SoundDescriptor soundDescriptorFromDictionary: (NSDictionary*)Value];
			MenuButton.Sound			= Sound;
			MenuButton.DisabledSound	= DisabledSound;
			MenuButton.backgroundImage	= ItemBackground;
			MenuButton.foregroundImage	= ItemForeground;

			[self applyColorAndTransformFromDictionary: ButtonData onNode: MenuButton];
			
			if ((Value = [ButtonData localizedObjectForKey: @"tintdisabled"]))		MenuButton.TintDisabled			= ccColor4BFromString(Value);
			if ((Value = [ButtonData localizedObjectForKey: @"tintonselect"]))		MenuButton.TintOnSelect			= ccColor4BFromString(Value);
			if ((Value = [ButtonData localizedObjectForKey: @"transformonselect"]))	MenuButton.TransformOnSelect	= CGTransformFromString(Value);
			
//			MenuButton.rotation	= BtnRotation;
//			if ((Value = [ButtonData localizedObjectForKey: @"scale"]))				MenuButton.scale			= [Value floatValue];
			if ((Value = [ButtonData localizedObjectForKey: @"rotateonselect"]))
				NSLog(@"rotateonselect deprecated, use transformonselect instead");
//				MenuButton.RotationOnSelect	= [Value floatValue];
			if ((Value = [ButtonData localizedObjectForKey: @"scaleonselect"]))
				NSLog(@"scaleonselect deprecated, use transformonselect instead");
//			{
//					CGPoint	temp				= CGPointFromString(Value);
//					MenuButton.ScaleOnSelect	= temp;
//			}
			MenuButton.tag				= [Scene intValue];
		}
		else
		{
			NormalSprite.rotation			= BtnRotation;
			if (!NormalSprite)
			{
				NSLog(@"Missing image for %@", Key);
				continue;
			}
		}
		if (([ButtonData localizedObjectForKey: @"role"]) &&
			(![self RoleHandler: ((Scene)?((CCNode*)MenuButton):((CCNode*)NormalSprite)) andData: ButtonData]))
				continue;

		[Layer addChild: NormalSprite	z: z];
		SetVertexZForNode(ButtonData, NormalSprite);

		if (Scene)
		{
			if (SelectedSprite)
			{
				[Layer addChild: SelectedSprite	z: z];
				SetVertexZForNode(ButtonData, SelectedSprite);
			}
			if (DisabledSprite)
			{
				[Layer addChild: DisabledSprite	z: z];
				SetVertexZForNode(ButtonData, DisabledSprite);
			}

			if (!Menu)
			{
				Menu	= [ANCMenuAdvanced menuWithItems: nil];
				[Layer addChild: Menu];
				if (!Layer.visible)	Menu.isDisabled	= true;
				if ((Value = [Dictionary localizedObjectForKey: @"menuanchor"]))	Menu.anchorPoint	= CGPointFromString(Value);
				if ((Value = [Dictionary localizedObjectForKey: @"menuposition"]))	Menu.position		= CGPointFromString(Value);
			}
			if (ItemBackground)
			{
				[Layer addChild: ItemBackground z: z-1];
				SetVertexZForNode(ButtonData, ItemBackground);
			}
			if (ItemForeground)
			{
				[Layer addChild: ItemForeground z: z+1];
				SetVertexZForNode(ButtonData, ItemForeground);
			}

			[Menu addChild: MenuButton];//non disegna nulla quindi non importa z
			if (AutoAnchor)
			{
				[NormalSprite autoCenter];
				MenuButton.anchorPoint	= NormalSprite.anchorPoint;
			}
			else	MenuButton.anchorPoint	= Anchor;
			MenuButton.position		= BtnPosition;
			if ((Value = [ButtonData localizedObjectForKey: @"activearea"]))
				[MenuButton setActiveArea: CGRectFromString(Value)];
			if ((Value = [ButtonData localizedObjectForKey: @"visible"]) && (![Value boolValue]))
				MenuButton.visible		= false;

#ifdef SHOW_MENU_AREA
			CCSprite	*PlaceHolder	= [ColoredSquareSprite squareWithColor: ccc4(0, 128, 0, 64) size: [MenuButton boundingBox].size];
			PlaceHolder.position		= NormalSprite.position;
			PlaceHolder.rotation		= NormalSprite.rotation;
			PlaceHolder.anchorPoint		= NormalSprite.anchorPoint;
			[Layer addChild: PlaceHolder z: 1000];
			
#endif
		}
		else
		{
			if (AutoAnchor)
					[NormalSprite autoCenter];				
			else	NormalSprite.anchorPoint	= Anchor;
//			NormalSprite.position				= BtnPosition;
			NormalSprite.position				= BtnPosition; 
			if ((Value = [ButtonData localizedObjectForKey: @"visible"]) && (![Value boolValue]))
			{
				NormalSprite.visible	= false;
				if([NormalSprite respondsToSelector:@selector(StopAnimation)])
					[NormalSprite StopAnimation];
			}
		}
	}
//fine for
	if (Menu)
	{
		CGSize		MenuSize;
		NSString	*MenuSizeStr	= [Dictionary localizedObjectForKey: @"menusize"];
		NSString	*AlignStr		= [Dictionary localizedObjectForKey: @"menualign"];
		NSString	*Padding		= [Dictionary localizedObjectForKey: @"menupadding"];
		
		if (AlignStr)
		{
			[[Menu children] sortUsingSelector: @selector(compareItemWithItem:)];

			float	temp;
			if		(([AlignStr isEqualToString: @"bottomtotop"]) ||
					 ([AlignStr isEqualToString: @"toptobottom"]))
			{
				[Menu alignItemsVerticallyWithPadding:   [Padding floatValue] bottomToTop: [AlignStr isEqualToString: @"bottomtotop"]];
				if (MenuSizeStr)
				{
					MenuSize			= [Menu contentSize];
					temp				= [MenuSizeStr floatValue];
					if (temp < MenuSize.height)
						MenuSize.height	= temp;
				}
			}
			else if	(([AlignStr isEqualToString: @"lefttoright"]) ||
					 ([AlignStr isEqualToString: @"righttoleft"]))
			{
				[Menu alignItemsHorizontallyWithPadding: [Padding floatValue] leftToRight: [AlignStr isEqualToString: @"lefttoright"]];
				if (MenuSizeStr)
				{
					MenuSize			= [Menu contentSize];
					temp				= [MenuSizeStr floatValue];
					if (temp < MenuSize.width)
						MenuSize.width	= temp;
				}
			}
			else if ([AlignStr rangeOfString: @"grid"].location != NSNotFound)
			{
				int	Align		= 0;
				if ([AlignStr rangeOfString: @"righttoleft"].location != NSNotFound)
					Align				+= MENU_ALIGN_RIGHT_TO_LEFT;
				if ([AlignStr rangeOfString: @"bottomtotop"].location != NSNotFound)
					Align				+= MENU_ALIGN_BOTTOM_TO_TOP;
				int ItemsNum;

				if ((Value		= [Dictionary localizedObjectForKey: @"menurows"]))
					Align				+= MENU_ALIGN_ROWS_NUM;
				else if ((Value	= [Dictionary localizedObjectForKey: @"menucols"]))
					Align				+= MENU_ALIGN_COLS_NUM;
				else	NSAssert(false, @"Specify cols or rows num of the grid"); 
				ItemsNum				= [Value intValue];

				[Menu allignItemsInGridWithPadding: CGSizeFromString(Padding) align: Align itemsNum: ItemsNum];
				if (MenuSizeStr)
				{
					temp				= [MenuSizeStr floatValue];
					MenuSize			= [Menu contentSize];
					if (temp != 0)
					{
						if (Align & MENU_ALIGN_ROWS_NUM)
						{
							if (temp < MenuSize.width)
								MenuSize.width	= temp;
						}
						else if (temp < MenuSize.height)
							MenuSize.height		= temp;
					}
					else MenuSize		= CGSizeFromString(MenuSizeStr);
				}
			}
			else	NSAssert(false, @"Unknown allignment");
		}
		else if (MenuSizeStr)
			MenuSize				= CGSizeFromString(MenuSizeStr);

		if (MenuSizeStr)
		{
			NSAssert((MenuSize.width != 0) && (MenuSize.height), @"Warning 0 menu area");
			Menu.boundaryRect		= CGRectMake(Menu.position.x - MenuSize.width * Menu.anchorPoint.x, Menu.position.y - MenuSize.height * Menu.anchorPoint.y, MenuSize.width, MenuSize.height);
		}
#ifdef SHOW_MENU_AREA
		if (MenuSizeStr)
		{
			CCSprite	*PlaceHolder	= [ColoredSquareSprite squareWithColor: ccc4(0, 128, 0, 128) size: Menu.boundaryRect.size];
			PlaceHolder.position		= Menu.boundaryRect.origin;
			PlaceHolder.anchorPoint		= CGPointZero;
			[Layer addChild: PlaceHolder z: 1000];
		}
		Menu.debugDraw			= true;
#endif
	}
}

//chiamato alla fine delle animazioni sulla scena, le animazioni con durata infinita non sono considerate
-(void)animationsEnd
{}

//gestione tocchi, mouse, accellerometro, tastiera presa dal Layer
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(NSInteger) touchDelegatePriority
{
	return 0;
}

@synthesize isAccelerometerEnabled	= isAccelerometerEnabled_;
@synthesize isStandardTouchEnabled	= isStandardTouchEnabled_;
@synthesize isTargetedTouchEnabled	= isTargetedTouchEnabled_;

-(void) setIsAccelerometerEnabled:(bool)enabled
{
	if( enabled != isAccelerometerEnabled_ ) {
		isAccelerometerEnabled_ = enabled;
		if( isRunning_ ) {
			if( enabled )
				[[UIAccelerometer sharedAccelerometer] setDelegate:self];
			else
				[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
		}
	}
}

-(void) setIsStandardTouchEnabled:(bool)enabled
{
	if( isStandardTouchEnabled_ != enabled ) {
		isStandardTouchEnabled_ = enabled;
		if( isRunning_ ) {
			if( enabled )
				[self registerWithTouchDispatcher];
			else
				[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
		}
	}
}

-(void) setIsTargetedTouchEnabled:(bool)enabled
{
	if( isTargetedTouchEnabled_ != enabled ) {
		isTargetedTouchEnabled_ = enabled;
		if( isRunning_ ) {
			if( enabled )
				[self registerWithTouchDispatcher];
			else
				[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
		}
	}
}

-(void)registerWithTouchDispatcher
{
	NSAssert(!isStandardTouchEnabled_ || !isTargetedTouchEnabled_, @"Cannot use both Standard and Targeted touch mode");
	if (isStandardTouchEnabled_)
		[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority: [self touchDelegatePriority]];
	else if (isTargetedTouchEnabled_)
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority: [self touchDelegatePriority] swallowsTouches:YES];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSAssert(false, @"You MUST override ccTouchesBegan:withEvent: to use Standatd Touch mode");
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(false, @"You MUST override ccTouchBegan:withEvent: to use Targeted Touch mode");
	return false;
}

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#pragma mark CCLayer - Mouse & Keyboard events

-(NSInteger) mouseDelegatePriority
{
	return 0;
}

-(bool) isMouseEnabled
{
	return isMouseEnabled_;
}

-(void) setIsMouseEnabled:(bool)enabled
{
	if( isMouseEnabled_ != enabled ) {
		isMouseEnabled_ = enabled;
		
		if( isRunning_ ) {
			if( enabled )
				[[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority:[self mouseDelegatePriority]];
			else
				[[CCEventDispatcher sharedDispatcher] removeMouseDelegate:self];
		}
	}
}

-(NSInteger) keyboardDelegatePriority
{
	return 0;
}

-(bool) isKeyboardEnabled
{
	return isKeyboardEnabled_;
}

-(void) setIsKeyboardEnabled:(bool)enabled
{
	if( isKeyboardEnabled_ != enabled ) {
		isKeyboardEnabled_ = enabled;
		
		if( isRunning_ ) {
			if( enabled )
				[[CCEventDispatcher sharedDispatcher] addKeyboardDelegate:self priority:[self keyboardDelegatePriority] ];
			else
				[[CCEventDispatcher sharedDispatcher] removeKeyboardDelegate:self];
		}
	}
}
#endif // Mac

-(void) onEnter
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	// register 'parent' nodes first
	// since events are propagated in reverse order
	if (isTargetedTouchEnabled_ || isStandardTouchEnabled_)
		[self registerWithTouchDispatcher];
	
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	if( isMouseEnabled_ )
		[[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority:[self mouseDelegatePriority]];
	
	if( isKeyboardEnabled_)
		[[CCEventDispatcher sharedDispatcher] addKeyboardDelegate:self priority:[self keyboardDelegatePriority]];
#endif
	
	// then iterate over all the children
	[super onEnter];
}

// issue #624.
// Can't register mouse, touches here because of #issue #1018, and #1021
-(void) onEnterTransitionDidFinish
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	if( isAccelerometerEnabled_ )
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
#endif

	if ([BackgroundMusic isEqualToString: @""])//se il suono è una stringa vuota non cambio quello in esecuzione
		[[SoundManager sharedManager] stopBackgroundMusic];
	else if (BackgroundMusic != nil)
		[[SoundManager sharedManager] playBackgroundMusic: BackgroundMusic];
	[super onEnterTransitionDidFinish];
}

-(void) onExit
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	if( isStandardTouchEnabled_ || isTargetedTouchEnabled_ )
		[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];

	if( isAccelerometerEnabled_ )
		[[UIAccelerometer sharedAccelerometer] setDelegate:nil];

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	if( isMouseEnabled_ )
		[[CCEventDispatcher sharedDispatcher] removeMouseDelegate:self];

	if( isKeyboardEnabled_ )
		[[CCEventDispatcher sharedDispatcher] removeKeyboardDelegate:self];
#endif

	[super onExit];
}

-(bool)receivedMemoryWarning {return true;}
-(void)disableMenus
{
	CCNode	*Layer	= (CCNode*)children_->data->arr[0];
	ANCMenuAdvanced *child;
	CCARRAY_FOREACH(Layer.children, child)
	if ([child isKindOfClass:[ANCMenuAdvanced class]])
		child.isDisabled = true;
}

-(void)enableMenus
{
	CCNode	*Layer	= (CCNode*)children_->data->arr[0];
	ANCMenuAdvanced *child;
	CCARRAY_FOREACH(Layer.children, child)
	if ([child isKindOfClass:[ANCMenuAdvanced class]])
		child.isDisabled = false;
}

@end

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation CCMenuItem (compareItemWithItem)
-(int)compareItemWithItem: (CCMenuItem*) Item
{
	if		(self.tag == Item.tag)	return NSOrderedSame;
	else if	(self.tag < Item.tag)	return NSOrderedAscending;
	return NSOrderedDescending;
}
@end