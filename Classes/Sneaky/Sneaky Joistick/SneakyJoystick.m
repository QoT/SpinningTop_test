//
//  joystick.m
//  SneakyJoystick
//
//  Created by Nick Pannuto.
//  2/15/09 verion 0.1
//  
//  WIKI: http://wiki.github.com/sneakyness/SneakyJoystick/
//  HTTP SRC: http://github.com/sneakyness/SneakyJoystick.git
//  GIT: git://github.com/sneakyness/SneakyJoystick.git
//  Email: SneakyJoystick@Sneakyness.com 
//  IRC: #cocos2d-iphone irc.freenode.net

#import "SneakyJoystick.h"

#define SJ_PI 3.14159265359f
#define SJ_PI_X_2 6.28318530718f
#define SJ_RAD2DEG 180.0f/SJ_PI
#define SJ_DEG2RAD SJ_PI/180.0f

@interface SneakyJoystick(hidden)
- (void)updateVelocity:(CGPoint)point;
- (void)setTouchRadius;
@end

@implementation SneakyJoystick

@synthesize
stickPosition,
degrees,
velocity,
autoCenter,
isDPad,
hasDeadzone,
numberOfDirections,
joystickRadius,
thumbRadius,
deadRadius,
touched;

+(id)joystickWithRadius: (float)Radius
{
	return [[[self alloc] initWithRadius: Radius] autorelease];
}

-(id)initWithRadius: (float)Radius
{
	self = [super init];
	if(self){
		stickPosition = CGPointZero;
		degrees = 0.0f;
		velocity = CGPointZero;
		autoCenter = YES;
		isDPad = NO;
		hasDeadzone = NO;
		numberOfDirections = 4;
		
		self.joystickRadius = Radius;
		self.thumbRadius = 32.0f;
		self.deadRadius = 0.0f;
	}
	return self;
}

@synthesize	enabled;
-(void)setEnabled: (bool)newValue
{
	if (enabled != newValue)
	{
		if (newValue)
			[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
		else
		{
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
			degrees			= 0.0f;
			velocity		= CGPointZero;
			stickPosition	= CGPointZero;
		}
		enabled	= newValue;
	}
}

-(void)setVisible:(BOOL)newVisible
{
	if (!newVisible)
	{
		stickPosition	= CGPointZero;
		degrees			= 0.0f;
		velocity		= CGPointZero;
	}
	[super setVisible: newVisible];
}

- (void) onEnterTransitionDidFinish
{
	self.enabled	= true;
	[super onEnterTransitionDidFinish];
}

- (void) onExit
{
	self.enabled	= false;
	stickPosition	= CGPointZero;
	[super onExit];
}

-(void)updateVelocity:(CGPoint)point
{
	// Calculate distance and angle from the center.
	float dx = point.x;
	float dy = point.y;
	float dSq = dx * dx + dy * dy;
	
	if(dSq <= deadRadiusSq){
		velocity = CGPointZero;
		degrees = 0.0f;
		stickPosition = point;
		return;
	}

	float angle = atan2f(dy, dx); // in radians
	if(angle < 0){
		angle		+= SJ_PI_X_2;
	}
	float cosAngle;
	float sinAngle;
	
	if(isDPad){
		float anglePerSector = 360.0f / numberOfDirections * SJ_DEG2RAD;
		angle = roundf(angle/anglePerSector) * anglePerSector;
	}
	
	cosAngle = cosf(angle);
	sinAngle = sinf(angle);
	
	// NOTE: Velocity goes from -1.0 to 1.0.
	if (dSq > joystickRadiusSq || isDPad) {
		dx = cosAngle * joystickRadius;
		dy = sinAngle * joystickRadius;
	}
	
	velocity = CGPointMake(dx/joystickRadius, dy/joystickRadius);
	degrees = angle * SJ_RAD2DEG;
	
	// Update the thumb's position
	stickPosition = ccp(dx, dy);
}

- (void) setIsDPad:(BOOL)b
{
	isDPad = b;
	if(isDPad){
		hasDeadzone = YES;
		self.deadRadius = 10.0f;
	}
}

- (void) setJoystickRadius:(float)r
{
	r					= r / CC_CONTENT_SCALE_FACTOR();
	joystickRadius		= r;
	joystickRadiusSq	= r*r;
}

- (void) setThumbRadius:(float)r
{
	thumbRadius = r;
	thumbRadiusSq = r*r;
}

- (void) setDeadRadius:(float)r
{
	deadRadius = r;
	deadRadiusSq = r*r;
}

#pragma mark Touch Delegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (!visible_)	return false;
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	location = [self convertToNodeSpaceAR:location];
	//Do a fast rect check before doing a circle hit check:
	if(location.x < -joystickRadius || location.x > joystickRadius || location.y < -joystickRadius || location.y > joystickRadius)
	{
//		NSLog(@"ccTouchBegan quick check false");
		return false;
	}
	else
	{
		float dSq = location.x*location.x + location.y*location.y;
		if(joystickRadiusSq > dSq)
		{
			[self updateVelocity:location];
			touched		= true;
//			NSLog(@"ccTouchBegan true");
			return true;
		}
	}
//	NSLog(@"ccTouchBegan false");
	return false;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	location = [self convertToNodeSpaceAR:location];
	[self updateVelocity:location];
//	NSLog(@"ccTouchMoved");
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = CGPointZero;

	touched	= false;
	if(!autoCenter)
	{
		location	= [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
		location			= [self convertToNodeSpaceAR:location];
	}
	[self updateVelocity: location];
//	NSLog(@"ccTouchEnded");
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self ccTouchEnded:touch withEvent:event];
//	NSLog(@"ccTouchCancelled");
}

@end
