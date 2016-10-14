//
//  BBSpaceShip.h
//  SpaceRocks
//
//  Created by ben smith on 3/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import "BBMobileObject.h"


@interface BBSpaceShip : BBMobileObject {
	BOOL dead;
}

- (void)awake;
- (void)deadUpdate;
- (void)didCollideWith:(BBSceneObject*)sceneObject; ;
- (void)fireMissile;
- (void)update;

// 5 methods

@end
