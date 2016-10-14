//
//  BBCollider.m
//  SpaceRocks
//
//  Created by ben smith on 7/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBCollider.h"
#import "BBSceneObject.h"
#import "BBMesh.h"



#pragma mark circle mesh
static NSInteger BBCircleVertexSize = 2;
static NSInteger BBCircleColorSize = 4;

static NSInteger BBCircleOutlineVertexesCount = 20;
static CGFloat BBCircleOutlineVertexes[40] = {1.0000,0.0000,0.9511,0.3090,0.8090,0.5878,0.5878,0.8090,0.3090,0.9511,0.0000,1.0000,-0.3090,0.9511,-0.5878,0.8090,-0.8090,0.5878,-0.9511,0.3090,-1.0000,0.0000,-0.9511,-0.3090,-0.8090,-0.5878,-0.5878,-0.8090,-0.3090,-0.9511,-0.0000,-1.0000,0.3090,-0.9511,0.5878,-0.8090,0.8090,-0.5878,0.9511,-0.3090};

static CGFloat BBCircleColorValues[80] = 
{1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 
1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 
1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 
1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 
1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0} ;



@implementation BBCollider

@synthesize checkForCollision,maxRadius,collisionVertexes;

+(BBCollider*)collider
{
	BBCollider * collider = [[BBCollider alloc] init];
	if (DEBUG_DRAW_COLLIDERS) {
		collider.active = YES;
		[collider awake];		
	}
	collider.checkForCollision = NO;
	return [collider autorelease];	
}


-(void)updateCollider:(BBSceneObject*)sceneObject
{
	if (sceneObject == nil) return;
	transformedCentroid = BBPointMatrixMultiply([sceneObject mesh].centroid , [sceneObject matrix]);
	translation = transformedCentroid;
	maxRadius = sceneObject.scale.x;
	if (maxRadius < sceneObject.scale.y) 	maxRadius = sceneObject.scale.y;
	if ((maxRadius < sceneObject.scale.z) && ([sceneObject mesh].vertexSize > 2)) maxRadius = sceneObject.scale.z;
	maxRadius *= [sceneObject mesh].radius;

	scale = BBPointMake(maxRadius, maxRadius,1.0);
}

-(BOOL)doesCollideWithCollider:(BBCollider*)aCollider
{
	// just need to check the distance between our two points and 
	// our radius
	CGFloat collisionDistance = self.maxRadius + aCollider.maxRadius;
	CGFloat objectDistance = BBPointDistance(self.translation, aCollider.translation);
	if (objectDistance < collisionDistance) return YES;
	return NO;
}

-(BOOL)doesCollideWithMesh:(BBSceneObject*)sceneObject
{
	return [self doesCollideWithVertexes:sceneObject.mesh.vertexes count:sceneObject.mesh.vertexCount size:sceneObject.mesh.vertexSize matrix:[sceneObject matrix]];
}

-(BOOL)doesCollideWithVertexes:(CGFloat*)vertexes 
												 count:(NSInteger)vertexCount
												size:(NSInteger)size
												matrix:(CGFloat*)transform
{
	NSInteger index;
	// step through each vertex of the scene object
	// transform it into real space coordinates
	// and check it against our radius
	for (index = 0; index < vertexCount; index++) {
		NSInteger position = index * size;
		BBPoint vert;
		if (size > 2) {
			vert = BBPointMake(vertexes[position], vertexes[position + 1], vertexes[position + 2]);		
		} else {
			vert = BBPointMake(vertexes[position], vertexes[position + 1], 0.0);		
		}
		vert = BBPointMatrixMultiply(vert , transform);
		CGFloat distance = BBPointDistance(self.translation, vert);
		if (distance < self.maxRadius) {
			return YES;
		}
	}
	return NO;
}




#pragma mark Scene Object methods for debugging;

-(void)awake
{
	mesh = [[BBMesh alloc] initWithVertexes:BBCircleOutlineVertexes 
															vertexCount:BBCircleOutlineVertexesCount 
														 vertexSize:BBCircleVertexSize
															renderStyle:GL_LINE_LOOP];
	mesh.colors = BBCircleColorValues;
	mesh.colorSize = BBCircleColorSize;
}


-(void)render
{
	if (!mesh || !active) return; // if we do not have a mesh, no need to render
	// clear the matrix
	glPushMatrix();
	glLoadIdentity();
	glTranslatef(translation.x, translation.y, translation.z);
	glScalef(scale.x, scale.y, scale.z);
	[mesh render];	
	glPopMatrix();
}


- (void) dealloc
{
	[super dealloc];
}

@end
