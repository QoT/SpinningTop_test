//
//  ANCScene.h
//  Prova
//
//  Created by mad4chip on 21/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "ANCMenuAdvanced.h"
#import "ANCMenuButton.h"

typedef struct
{
	bool	UseLazyLoad;				//abilita lo scaricamento dinamico della scena
	bool	LoadOnCreate;				//carica la scena alla creazione, forzato a true se UseLazyLoad è false
	bool	UnloadOnHide;				//scarica automaticamente la scena quando è nascosta

	bool	DeallocateOnMemoryWarning;	//dealloca la scena in caso di memoryWarning
	bool	KeepConfigurationContent;	//cancella il contenuto della configurazione all'onEnter
} TMemoryBehaviour;

@class ANCScene;
@protocol SceneManagerProtocol <NSObject>
@optional
-(ANCScene*)ChangeScene: (int)NewSceneID;
-(void)BtnClick: (CCMenuItem*)Button;
@end

@protocol RoleHandlerProtocol <NSObject>
-(bool)RoleHandler: (CCNode*)Node andData: (NSDictionary*)Dictionary;
@end

@interface ANCScene : CCScene <UIAccelerometerDelegate, CCStandardTouchDelegate, CCTargetedTouchDelegate, RoleHandlerProtocol, SceneManagerProtocol>
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		bool	isStandardTouchEnabled_;
		bool	isTargetedTouchEnabled_;
		bool	isAccelerometerEnabled_;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		bool	isMouseEnabled_;
		bool	isKeyboardEnabled_;
#endif
	bool			FirstLayer;
	bool			useVertexZ;

	bool			loaded;
	NSDictionary	*ConfigurationContent;
	NSMutableDictionary	*IncludedFiles;
	NSString		*ConfigurationFile_;
	TMemoryBehaviour MemoryBehaviour;

	id<SceneManagerProtocol>	SceneManager;
	id<RoleHandlerProtocol>		RoleHandler;
	float			delay;
	NSString		*BackgroundMusic;
}

@property(readwrite, nonatomic, assign) NSString	*ConfigurationFile;
@property(readwrite, nonatomic) 		bool		UseLazyLoad;
@property(readonly,	 nonatomic) 		bool		LoadOnCreate;
@property(readwrite, nonatomic)			bool		UnloadOnHide;
@property(readwrite, nonatomic)			bool		DeallocateOnMemoryWarning;
@property(readwrite, nonatomic)			bool		KeepConfigurationContent;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	@property(nonatomic, readwrite) bool isStandardTouchEnabled;
	@property(nonatomic, readwrite) bool isTargetedTouchEnabled;
	@property(nonatomic, readwrite) bool isAccelerometerEnabled;
-(NSInteger) touchDelegatePriority;
-(void)registerWithTouchDispatcher;
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	@property (nonatomic, readwrite) bool isMouseEnabled;
	@property (nonatomic, readwrite) bool isKeyboardEnabled;
	-(NSInteger) mouseDelegatePriority;
	-(NSInteger) keyboardDelegatePriority;
#endif
+(id)initMenu;
-(id)initMenu;
+(id)sceneWithFile: (NSString *)FileName SceneManager: (id<SceneManagerProtocol>)Manager;
+(id)sceneWithFile: (NSString *)FileName SceneManager: (id<SceneManagerProtocol>)Manager RoleHandler: (id<RoleHandlerProtocol>)RoleHandler;
-(id)initWithFile: (NSString *)FileName;
-(id)initWithFile: (NSString *)FileName SceneManager: (id<SceneManagerProtocol>)Manager;
-(id)initWithFile: (NSString *)FileName SceneManager: (id<SceneManagerProtocol>)Manager RoleHandler: (id<RoleHandlerProtocol>)RoleHandler;
-(void)BtnClick: (CCMenuItem*)Button;
-(void)ParseDictionary: (NSDictionary *)Dictionary Parent: (CCNode*)Parent;
-(void)animationsEnd;
-(void)enableMenus;
-(void)disableMenus;
-(bool)receivedMemoryWarning;
-(TMemoryBehaviour) defaultMemoryBehaviour;
-(void)unloadScene;
-(void)reloadScene;
@end

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface CCMenuItem (compareItemWithItem)

-(int)compareItemWithItem: (CCMenuItem*) Item;
@end
