//
//  BBRock.m
//  SpaceRocks
//
//  Created by ben smith on 3/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBRock.h"
#import "BBCollider.h"
#import "BBAnimation.h"

#pragma mark Rocks mesh
// the rocks are going to be randomly generated
// so we just need some basic info about them
static NSInteger BBRockVertexSize = 2;
static NSInteger BBRockColorSize = 4;

@implementation BBRock

@synthesize smashCount;

- (id) init
{
	self = [super init];
	if (self != nil) {
		smashCount = 0;
	}
	return self;
}

+(BBRock*)randomRock
{
	return [BBRock randomRockWithScale:NSMakeRange(35, 55)];
}

+(BBRock*)randomRockWithScale:(NSRange)scaleRange
{
	BBRock * rock = [[BBRock alloc] init];
	CGFloat scale = RANDOM_INT(scaleRange.location,NSMaxRange(scaleRange)); 
	rock.scale = BBPointMake(scale, scale, 1.0); 
	CGFloat x = RANDOM_INT(100,230);
	NSInteger flipX = RANDOM_INT(1,10);
	if (flipX <= 5) x *= -1.0;
	CGFloat y = RANDOM_INT(0,320) - 160;
	rock.translation = BBPointMake(x, y, 0.0);
	// the rocks will be moving either up or down in the y axis
	CGFloat speed = RANDOM_INT(1,100)/100.0 * 60.0;
	NSInteger flipY = RANDOM_INT(1,10);
	if (flipY <= 5) speed *= -1.0;
	rock.speed = BBPointMake(0.0, speed, 0.0);
	
	CGFloat rotSpeed = RANDOM_INT(1,100)/200.0 * 60.0;
	NSInteger flipRot = RANDOM_INT(1,10);
	if (flipRot <= 5) rotSpeed *= -1.0;
	rock.rotationalSpeed = BBPointMake(0.0, 0.0, rotSpeed);
	return [rock autorelease];	
}

-(void)awake
{
	self.mesh = [[BBMaterialController sharedMaterialController] quadFromAtlasKey:@"rockTexture"];
	mesh.radius = 0.5;

	// malloc some memory for our vertexes and colors
	verts = (CGFloat *) malloc(4 * BBRockVertexSize * sizeof(CGFloat));
	colors = (CGFloat *) malloc(4 * BBRockColorSize * sizeof(CGFloat));

	CGFloat r = (CGFloat)RANDOM_INT(1,100)/100.0;
	CGFloat g = (CGFloat)RANDOM_INT(1,100)/100.0;
	CGFloat b = (CGFloat)RANDOM_INT(1,100)/100.0;
	// now the colors, just make it white for now, all 1's
	NSInteger vertexIndex = 0;
	for (vertexIndex = 0; vertexIndex < 16; vertexIndex += 4) {
		colors[vertexIndex] = r;
		colors[vertexIndex + 1] = g;
		colors[vertexIndex + 2] = b;
		colors[vertexIndex + 3] = 1.0;
	}

	
	self.collider = [BBCollider collider];
//	[self.collider setCheckForCollision:YES];
}

// called once every frame
-(void)render
{
	mesh.colors = colors;
	mesh.colorSize = 4;
	[super render];
}

-(void)smash
{
	smashCount++;
	// queue myself for removal
	[[BBSceneController sharedSceneController] removeObjectFromScene:self];

	// your rock asplode!
	BBAnimation * splodey = [[BBAnimation alloc] initWithAtlasKeys:[NSArray arrayWithObjects:@"bang1",@"bang2",@"bang3",nil] loops:NO speed:6];
	splodey.active = YES;
	splodey.translation = self.translation;
	splodey.scale = self.scale;
	[[BBSceneController sharedSceneController] addObjectToScene:splodey];
	[splodey release];
	
	
	// if we have already been smashed once, then that is it
	if (smashCount >= 2) return;
		
	// need to break ourself apart
	NSInteger smallRockScale = scale.x / 3.0;
	
	BBRock * newRock = [[BBRock alloc] init];
	newRock.scale = BBPointMake(smallRockScale, smallRockScale, 1.0); 
	// now we need to position it 
	BBPoint position = BBPointMake(0.0, 0.5, 0.0);
	newRock.translation = BBPointMatrixMultiply(position , matrix);
	newRock.speed = BBPointMake(speed.x + (position.x * SMASH_SPEED_FACTOR), speed.y + (position.y * SMASH_SPEED_FACTOR), 0.0);
	newRock.rotationalSpeed = rotationalSpeed;
	newRock.smashCount = smashCount;
	[[BBSceneController sharedSceneController] addObjectToScene:newRock];
	[newRock release];

	newRock = [[BBRock alloc] init];
	newRock.scale = BBPointMake(smallRockScale, smallRockScale, 1.0); 
	// now we need to position it 
	position = BBPointMake(0.35, -0.35, 0.0);
	newRock.translation = BBPointMatrixMultiply(position , matrix);
	newRock.speed = BBPointMake(speed.x + (position.x * SMASH_SPEED_FACTOR), speed.y + (position.y * SMASH_SPEED_FACTOR), 0.0);
	newRock.rotationalSpeed = rotationalSpeed;
	newRock.smashCount = smashCount;
	[[BBSceneController sharedSceneController] addObjectToScene:newRock];
	[newRock release];

	newRock = [[BBRock alloc] init];
	newRock.scale = BBPointMake(smallRockScale, smallRockScale, 1.0); 
	// now we need to position it 
	position = BBPointMake(-0.35, -0.35, 0.0);
	newRock.translation = BBPointMatrixMultiply(position , matrix);
	newRock.speed = BBPointMake(speed.x + (position.x * SMASH_SPEED_FACTOR), speed.y + (position.y * SMASH_SPEED_FACTOR), 0.0);
	newRock.rotationalSpeed = rotationalSpeed;
	newRock.smashCount = smashCount;
	[[BBSceneController sharedSceneController] addObjectToScene:newRock];
	[newRock release];
	
}

// called once every frame
-(void)update
{
	[super update];
}

- (void) dealloc
{
	if (verts) free(verts);
	if (colors) free(colors);
	[super dealloc];
}

@end
