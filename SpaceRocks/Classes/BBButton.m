//
//  BBButton.m
//  SpaceRocks
//
//  Created by ben smith on 3/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBButton.h"


#pragma mark square
static NSInteger BBSquareVertexStride = 2;
static NSInteger BBSquareColorStride = 4;
static GLenum BBSquareOutlineRenderStyle = GL_LINE_LOOP;
static NSInteger BBSquareOutlineVertexesCount = 4;
static CGFloat BBSquareOutlineVertexes[8] = {-0.5f, -0.5f, 0.5f,  -0.5f, 0.5f,   0.5f, -0.5f,  0.5f};
static CGFloat BBSquareOutlineColorValues[16] = {1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0};
static GLenum BBSquareFillRenderStyle = GL_TRIANGLE_STRIP;
static NSInteger BBSquareFillVertexesCount = 4;
static CGFloat BBSquareFillVertexes[8] = {-0.5,-0.5, 0.5,-0.5, -0.5,0.5, 0.5,0.5};


@implementation BBButton

@synthesize buttonDownAction,buttonUpAction,target;

// called once when the object is first created.
-(void)awake
{
	pressed = NO;
	mesh = [[BBMesh alloc] initWithVertexes:BBSquareOutlineVertexes vertexCount:BBSquareOutlineVertexesCount vertexStride:BBSquareVertexStride renderStyle:BBSquareOutlineRenderStyle];
	mesh.colors = BBSquareOutlineColorValues;
	mesh.colorStride = BBSquareColorStride;
	screenRect = [[BBSceneController sharedSceneController].inputController 
								screenRectFromMeshRect:self.meshBounds 
								atPoint:CGPointMake(translation.x, translation.y)];
	// this is a bit rendundant, but allows for much simpler subclassing
	[self setNotPressedVertexes];
}

// called once every frame
-(void)update
{
	// check for touches
	[self handleTouches];
	[super update];
}

-(void)setPressedVertexes
{
	mesh.vertexes = BBSquareFillVertexes;
	mesh.renderStyle = BBSquareFillRenderStyle;
	mesh.vertexCount = BBSquareFillVertexesCount;	
	mesh.colors = BBSquareOutlineColorValues;
}

-(void)setNotPressedVertexes
{
	mesh.vertexes = BBSquareOutlineVertexes;
	mesh.renderStyle = BBSquareOutlineRenderStyle;
	mesh.vertexCount = BBSquareOutlineVertexesCount;	
	mesh.colors = BBSquareOutlineColorValues;
}

// Note: this method is slightly different than the in-text version. 
// it is checking for both UITouchPhaseBegan and UITouchPhaseStationary
// the reason for this is that on OS 3.x and above, the phase can change 
// out from under you if you dont check it as soon as the touch event occurs
// since we are checking our touch events based on the game loop timing
// we need to be aware that the UITouchPhaseBegan may have already changed
// to UITouchPhaseStationary and take that into account
-(void)handleTouches
{
	NSSet * touches = [[BBSceneController sharedSceneController].inputController touchEvents];
	if ([touches count] == 0) return;
	
	BOOL pointInBounds = NO;
	for (UITouch * touch in [touches allObjects]) {
		CGPoint touchPoint = [touch locationInView:[touch view]];
		if (CGRectContainsPoint(screenRect, touchPoint)) {
			pointInBounds = YES;
			if ((touch.phase == UITouchPhaseBegan) || ((touch.phase == UITouchPhaseStationary))) [self touchDown];				
		}
	}
	if (!pointInBounds) [self touchUp];
}

-(void)touchUp
{
	if (!pressed) return; // we were already up
	pressed = NO;
	[self setNotPressedVertexes];
	[target performSelector:buttonUpAction];
}

-(void)touchDown
{
	if (pressed) return; // we were already down
	pressed = YES;
	[self setPressedVertexes];
	[target performSelector:buttonDownAction];
}


@end
