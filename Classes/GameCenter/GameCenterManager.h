//
//  GameCenterManager.h
//  Prova
//
//  Created by mad4chip on 25/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <GameKit/GameKit.h>

@interface GameCenterManager : NSObject <NSCoding, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>
{
	bool				hasGameCenter;		// Boolean that is set to true if device supports Game Center and a player has logged in
	NSMutableArray		*unsentScores;		// An array that holds scores that couldn't be sent to Game Center (network timeout, etc.)
	UIViewController	*myViewController;

	//Codice inserito da Marina
	NSMutableArray		*unsentAchievements;		// Store unsent Game Center data
	NSMutableDictionary *achievementsDictionary;	// Store saved Game Center achievement progress

}

@property (readwrite) bool hasGameCenter;
@property (readwrite, retain) NSMutableArray *unsentScores;

-(void)reportScore:(int64_t)score forCategory:(NSString *)category;
-(bool)isGameCenterAPIAvailable;
-(void)authenticateLocalPlayer;
-(void)showLeaderboardForCategory:(NSString *)category;
-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;
+(id)sharedGameCenterManager;
+(void)loadState;
+(void)saveState;
-(void)encodeWithCoder:(NSCoder *)coder;
-(id)initWithCoder:(NSCoder *)coder;

// Achievement methods (Marina)
- (GKAchievement *)getAchievementForIdentifier:(NSString *)identifier;
- (void)reportAchievementIdentifier:(NSString *)identifier percentComplete:(float)percent;
- (void)reportAchievementIdentifier:(NSString *)identifier incrementPercentComplete:(float)percent;
- (void)showAchievements;
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(void)updateArchivements:(NSString *)ArchiveObject percentComplete: (float)percent;
-(void)submitScore:(int)Points Category:(NSString *)category;

@end
