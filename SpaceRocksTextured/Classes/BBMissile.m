//
//  BBMissile.m
//  SpaceRocks
//
//  Created by ben smith on 5/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBMissile.h"
#import "BBRock.h"
#import "BBCollider.h"
#import "BBAnimatedQuad.h"

#pragma mark Missile mesh

static CGFloat BBMissileCollisionVertexes[6] = {0.0,0.45,-0.25,-0.1,0.25,-0.1};
static CGFloat BBMissileCollisionVertCount = 3;

@implementation BBMissile

-(void)awake
{
	self.mesh = [[BBMaterialController sharedMaterialController] animationFromAtlasKeys:[NSArray arrayWithObjects:@"missile1",@"missile2",@"missile3",nil]];
	self.scale = BBPointMake(12, 31, 1.0);
	

	[(BBAnimatedQuad*)mesh setLoops:YES];
	mesh.radius = 0.35;
	self.collider = [BBCollider collider];
	[self.collider setCheckForCollision:YES];
}


// called once every frame
-(void)update
{
	[super update];
	if ([mesh isKindOfClass:[BBAnimatedQuad class]]) [(BBAnimatedQuad*)mesh updateAnimation];
}

-(void)checkArenaBounds
{
	BOOL outOfArena = NO;
	if (translation.x > (240.0 + CGRectGetWidth(self.meshBounds)/2.0)) outOfArena = YES; 
	if (translation.x < (-240.0 - CGRectGetWidth(self.meshBounds)/2.0)) outOfArena = YES; 
	
	if (translation.y > (160.0 + CGRectGetHeight(self.meshBounds)/2.0)) outOfArena = YES; 
	if (translation.y < (-160.0 - CGRectGetHeight(self.meshBounds)/2.0)) outOfArena = YES; 
	
	if (outOfArena) {
		[[BBSceneController sharedSceneController] removeObjectFromScene:self];
	}
}


- (void)didCollideWith:(BBSceneObject*)sceneObject; 
{
	// if we did not hit a rock, then get out early
	if (![sceneObject isKindOfClass:[BBRock class]]) return;
	// OK, we really want to make sure that we were hit.
	// so we are going to do a secondary check to make sure one of our vertexes is inside the
	// collision radius of the rock
	if (![sceneObject.collider doesCollideWithVertexes:BBMissileCollisionVertexes
				count:BBMissileCollisionVertCount size:2 matrix:[self matrix]]) return;	
	// we did hit a rock! smash it!
	[(BBRock*)sceneObject smash];
	// now destroy ourself
	[[BBSceneController sharedSceneController] removeObjectFromScene:self];	
}

@end
