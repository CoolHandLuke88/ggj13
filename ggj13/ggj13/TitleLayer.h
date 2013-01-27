//
//  TitleLayer.h
//  ggj13
//
//  Created by Brennon Redmyer on 1/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "BoxDebugLayer.h"
#import "GLES-Render.h"
#import "PhysicsSprite.h"
@interface TitleLayer : CCLayer {
    b2World *_world;
    b2Body *_body;
    CCSprite *_block;
    b2Vec2 _mouseWorld;
    b2MouseJoint *_mouseJoint;
}
+ (CCScene *)scene;
@end
