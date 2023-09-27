//
//
//  GameCenterManager
//
//  Created by mad4chip on 25/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import "GameCenterManager.h"
#import "CCDirector.h" 
#import "ccMacros.h"
#import "GameDataObject.h"

@implementation GameCenterManager

@synthesize hasGameCenter, unsentScores;
GameCenterManager *sharedGameCenterManager = nil;

-(id)init
{
	if ((self = [super init]))
	{
		if ([self isGameCenterAPIAvailable])
			hasGameCenter = true;
		else
			hasGameCenter = false;
	}
	return self;
}


-(bool)isGameCenterAPIAvailable
{
	bool localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	bool osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	return (localPlayerClassAvailable && osVersionSupported);
}

- (void)authenticateLocalPlayer
{
	if (hasGameCenter)
	{
		GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
		[localPlayer authenticateWithCompletionHandler:^(NSError *error) 
		 {
			 if (localPlayer.isAuthenticated)
			 {
				//Marina
				// Load player achievements
				[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
				if (error != nil)
				{
					// handle errors
					NSLog(@"Error sending achievements %@", [error description]);
				}
				if (achievements != nil)
				{
					// process array of achievements
					for (GKAchievement* achievement in achievements)
						[achievementsDictionary setObject:achievement forKey:achievement.identifier];
				}
			}];

				 //fine
				 // If unsent scores array has length > 0, try to send saved scores
				 if ([unsentScores count] > 0)
				 {
					 // Create new array to help remove successfully sent scores
					 NSMutableArray *removedScores = [NSMutableArray array];
					 for (GKScore *score in unsentScores)
					 {
						 [score reportScoreWithCompletionHandler:^(NSError *error) 
						  {
							  if   (error != nil){}// If there's an error reporting the score (again!), leave the score in the array
							  else [removedScores addObject:score];
						  }];
					 }
					 [unsentScores removeObjectsInArray:removedScores];
				 }
			 }
			 else hasGameCenter = false;
			 
		 }];
	}
}

- (void)reportScore:(int64_t)score forCategory:(NSString *)category
{
	if (hasGameCenter)
	{
		// Create score object
		GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
		// Set the score value
		scoreReporter.value = score;
		// Try to send
		[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
			if (error != nil)
			{
				// Handle reporting error here by adding object to a serializable array, to be sent again later
				[unsentScores addObject:scoreReporter];
				NSLog(@"Error sending score %@", [error description]);
			}
			else	NSLog(@"Score %@ send", category);
		}];
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
} 


- (void)showLeaderboardForCategory:(NSString *)category
{
	// Only execute if OS supports Game Center & player is logged in
	if (hasGameCenter)
	{
		// Create leaderboard view w/ default Game Center style
		GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
		
		// If view controller was successfully created...
		if (leaderboardController != nil)
		{
			// Leaderboard config
			leaderboardController.leaderboardDelegate = self;	// The leaderboard view controller will send messages to this object
			leaderboardController.category = category;	// Set category here
			leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;	// GKLeaderboardTimeScopeToday, GKLeaderboardTimeScopeWeek, GKLeaderboardTimeScopeAllTime
			
			// Create an additional UIViewController to attach the GKLeaderboardViewController to
			myViewController = [[UIViewController alloc] init];
			
			// Add the temporary UIViewController to the main OpenGL view
			[[[CCDirector sharedDirector] openGLView] addSubview:myViewController.view];
			// Tell UIViewController to present the leaderboard
			[myViewController presentModalViewController:leaderboardController animated:NO];
			
			leaderboardController.view.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(360.0f));
            leaderboardController.view.bounds = CGRectMake(0, 0, 480, 320);
			leaderboardController.view.center = CGPointMake(240,160 );
			

//			[[UIApplication sharedApplication] setStatusBarOrientation:[[[CCDirector sharedDirector] openGLView] ViewController].currentOrientation animated:NO];
			
		}
	}
}

+(id)sharedGameCenterManager 
{
	if(!sharedGameCenterManager)
		sharedGameCenterManager = [[self alloc] init];
	return sharedGameCenterManager;
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[myViewController dismissModalViewControllerAnimated:YES];
	[myViewController release];
}

+ (void)loadState
{
	@synchronized([GameCenterManager class]) 
	{
		// just in case loadState is called before GameCenterManager inits
		if (!sharedGameCenterManager)
			[GameCenterManager sharedGameCenterManager];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *file = [documentsDirectory stringByAppendingPathComponent:@"GameCenterManager.bin"];
		Boolean saveFileExists = [[NSFileManager defaultManager] fileExistsAtPath:file];
		
		if (saveFileExists) 
		{
			// don't need to set the result to anything here since we're just getting initwithCoder to be called.
			// if you try to overwrite sharedGameCenterManager here, an assert will be thrown.
			[NSKeyedUnarchiver unarchiveObjectWithFile:file];
		}
	}
}

+ (void)saveState
{
	@synchronized([GameCenterManager class]) 
	{  
		GameCenterManager *state = [GameCenterManager sharedGameCenterManager];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *saveFile = [documentsDirectory stringByAppendingPathComponent:@"GameCenterManager.bin"];
		[NSKeyedArchiver archiveRootObject:state toFile:saveFile];
	}
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeBool:self.hasGameCenter forKey:@"hasGameCenter"];
	[coder encodeObject:self.unsentScores forKey:@"unsentScores"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if ((self = [super init]))
	{
		self.hasGameCenter = [coder decodeBoolForKey:@"hasGameCenter"];
		self.unsentScores = [coder decodeObjectForKey:@"unsentScores"];
	}
	return self;
}


//Codice inserito da Marina
- (GKAchievement *)getAchievementForIdentifier:(NSString *)identifier
{
	if (hasGameCenter)
	{
		GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
		if (achievement == nil)
		{
			achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
			[achievementsDictionary setObject:achievement forKey:achievement.identifier];
			
		}
		return [[achievement retain] autorelease];
	}
	return nil;
}

- (void)reportAchievementIdentifier:(NSString *)identifier percentComplete:(float)percent
{
	if (hasGameCenter)
	{
		// Instantiate GKAchievement object for an achievement (set up in iTunes Connect)
		GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
		if (achievement)
		{
			achievement.percentComplete = percent;
			[achievement reportAchievementWithCompletionHandler:^(NSError *error)
			{
				if (error != nil)
				{
					// Retain the achievement object and try again later
					[unsentAchievements addObject: achievement];
					NSLog(@"Error sending achievement! %@", [error description]);
				}
				else	NSLog(@"Achievement %@ send", identifier);
			}];
		}
	}
}

- (void)reportAchievementIdentifier:(NSString *)identifier incrementPercentComplete:(float)percent
{
	if (hasGameCenter)
	{
		// Instantiate GKAchievement object for an achievement (set up in iTunes Connect)
		GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
		if (achievement)
		{
			achievement.percentComplete += percent;
			[achievement reportAchievementWithCompletionHandler:^(NSError *error)
			{
				if (error != nil)
				{
					// Retain the achievement object and try again later
					[unsentAchievements addObject: achievement];
					NSLog(@"Error sending achievement! %@", [error description]);
				}
				else	NSLog(@"Achievement %@ send", identifier);
			}];
		}
	}
}


- (void)showAchievements
{
	if (hasGameCenter)
	{
		GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
		if (achievements != nil)
		{
			achievements.achievementDelegate = self;
			// Create an additional UIViewController to attach the GKAchievementViewController to
			myViewController = [[UIViewController alloc] init];
			// Add the temporary UIViewController to the main OpenGL view
			[[[CCDirector sharedDirector] openGLView] addSubview:myViewController.view];
			[myViewController presentModalViewController:achievements animated:YES];
		}
		[achievements release];
	}
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	[myViewController dismissModalViewControllerAnimated:YES];
	[myViewController release];
}

-(void)updateArchivements: (NSString *)ArchiveObject percentComplete: (float)percent
{
	if (hasGameCenter)
	{
//		GKAchievement *achievement;
//		achievement = [self getAchievementForIdentifier:ArchiveObject];
		[self reportAchievementIdentifier:ArchiveObject percentComplete:percent];
	}
}

-(void)submitScore:(int)Points Category:(NSString *)category;
{
    if (hasGameCenter)
        [self reportScore:Points forCategory: category];
}
@end
