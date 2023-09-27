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

@class ANCScene;
@protocol SceneManagerProtocol
-(ANCScene*)ChangeScene: (int)NewSceneID;
-(void)ChangeSceneObj: (NSNumber*)NewSceneID;
@end

/*
@interface ANCScene_Builder : NSObject
{
	NSArray			*Configuration;
	NSDictionary	*SceneParts;
	bool			FirstLayer;
	bool			useVertexZ;
	float			delay;
}
@end
*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface ANCScene : CCScene <UIAccelerometerDelegate, CCStandardTouchDelegate, CCTargetedTouchDelegate>
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		bool	isStandardTouchEnabled_;
		bool	isTargetedTouchEnabled_;
		bool	isAccelerometerEnabled_;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		bool	isMouseEnabled_;
		bool	isKeyboardEnabled_;
#endif
	NSDictionary	*Configuration;
	NSMutableArray	*ConfigurationLevels;
	NSDictionary	*SceneParts;
	CCNode			*CurrentParent;

	bool			FirstLayer;
	bool			useVertexZ;
	float			delay;
	
	id				SceneManager;
	NSString		*BackgroundMusic;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	@property(nonatomic,assign) bool isStandardTouchEnabled;
	@property(nonatomic,assign) bool isTargetedTouchEnabled;
	@property(nonatomic,assign) bool isAccelerometerEnabled;
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
-(id)initWithFile: (NSString *)FileName SceneManager: (id<SceneManagerProtocol>)Manager;
+(id)sceneWithDictionary: (NSDictionary *)Dictionary SceneManager: (id<SceneManagerProtocol>)Manager;
-(id)initWithDictionary: (NSDictionary *)Dictionary SceneManager: (id<SceneManagerProtocol>)Manager;
-(bool)RoleHandler: (CCNode*)Node andData: (NSDictionary*)Dictionary;
-(void)BtnClick: (CCMenuItem*)Button;
-(void)ParseDictionary: (NSDictionary *)Dictionary Parent: (CCNode*)Parent;
-(void)animationsEnd;
-(void)enableMenus;
-(void)disableMenus;
-(bool)receivedMemoryWarning;
@end

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface CCMenuItem (compareItemWithItem)

-(int)compareItemWithItem: (CCMenuItem*) Item;
@end
