//
//  BBSpaceShip.m
//  SpaceRocks
//
//  Created by ben smith on 3/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBSpaceShip.h"
#import "BBMissile.h"
#import "BBRock.h"
#import "BBCollider.h"

#pragma mark Space Ship

static CGFloat BBSpaceShipCollisionVertexes[12] = {0.0,0.4,0.0,-0.4,-0.3,0.05,0.3,0.05,-0.45,-0.35,0.45,-0.35};
static CGFloat BBSpaceShipCollisionVertCount = 6;



@implementation BBSpaceShip
// called once when the object is first created.
-(void)awake
{
	self.mesh = [[BBMaterialController sharedMaterialController] quadFromAtlasKey:@"ship"];
	self.scale = BBPointMake(40, 40, 1.0);
	mesh.radius = 0.45;
	self.collider = [BBCollider collider];
	[self.collider setCheckForCollision:YES];
	dead = NO;
}

-(void)fireMissile
{
	// need to spawn a missile
	BBMissile * missile = [[BBMissile alloc] init];
	// we need to position it at the tip of our ship
	CGFloat radians = rotation.z/BBRADIANS_TO_DEGREES;
	CGFloat speedX = -sinf(radians) * 3.0 * 60.0; // 180 pixels per second
	CGFloat speedY = cosf(radians) * 3.0 * 60.0;

	missile.speed = BBPointMake(speedX, speedY, 0.0);
	
	missile.translation = BBPointMatrixMultiply(BBPointMake(0.0, 0.5, 0.0), matrix);
	missile.rotation = BBPointMake(0.0, 0.0, self.rotation.z);

	[[BBSceneController sharedSceneController] addObjectToScene:missile];
	[missile release];
	
	[[BBSceneController sharedSceneController].inputController setFireMissile:NO];
}

// called once every frame
-(void)update
{
	[super update];
	
	if (dead) {
		[self deadUpdate];
		return;		
	}
	
	CGFloat rightTurn = [[BBSceneController sharedSceneController].inputController rightMagnitude];
	CGFloat leftTurn = [[BBSceneController sharedSceneController].inputController leftMagnitude];

	rotation.z += ((rightTurn * -1.0) + leftTurn) * TURN_SPEED_FACTOR;

	if ([[BBSceneController sharedSceneController].inputController fireMissile]) [self fireMissile];

	
	CGFloat forwardMag = [[BBSceneController sharedSceneController].inputController forwardMagnitude] * THRUST_SPEED_FACTOR;
	if (forwardMag <= 0.0001) return; // we are not moving so return early
	
	CGFloat radians = rotation.z/BBRADIANS_TO_DEGREES;
	// now we need to do the thrusters
	// figure out the components of the speed
	speed.x += sinf(radians) * -forwardMag;
	speed.y += cosf(radians) * forwardMag;
}

-(void)deadUpdate
{
	[(BBAnimatedQuad*)mesh updateAnimation];
	if ([(BBAnimatedQuad*)mesh didFinish]) {
		[[BBSceneController sharedSceneController] removeObjectFromScene:self];	
		[[BBSceneController sharedSceneController] gameOver];
	}
}

- (void)didCollideWith:(BBSceneObject*)sceneObject; 
{
	// if we did not hit a rock, then get out early
	if (![sceneObject isKindOfClass:[BBRock class]]) return;
	// OK, we really want to make sure that we were hit.
	// so we are going to do a secondary check to make sure one of our vertexes is inside the
	// collision radius of the rock
	if (![sceneObject.collider doesCollideWithVertexes:BBSpaceShipCollisionVertexes
				count:BBSpaceShipCollisionVertCount size:2 matrix:[self matrix]]) return;
	
	// we did hit a rock! smash it!
	[(BBRock*)sceneObject smash];
	
	// we are dead! bummer
	dead = YES;
	
	self.mesh = [[BBMaterialController sharedMaterialController] animationFromAtlasKeys:[NSArray arrayWithObjects:@"shipDestroy1",@"shipDestroy2",@"shipDestroy3",@"shipDestroy4",nil]];
	self.collider.checkForCollision = NO;
	[(BBAnimatedQuad*)mesh setSpeed:6];
	// now destroy ourself		
}

@end
