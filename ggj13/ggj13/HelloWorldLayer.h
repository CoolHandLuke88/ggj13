//
//  HelloWorldLayer.h
//  ggj13
//
//  Created by Brennon Redmyer on 1/25/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import "cocos2d.h"
#import "Box2D.h"
#import "BoxDebugLayer.h"
#import "GLES-Render.h"
#import "PhysicsSprite.h"

#define PTM_RATIO 32.0
#define ptm(__x__) (__x__/PTM_RATIO)

enum {
	kTagParentNode = 1,
    kTagheartParentNode = 2,
};

@interface HelloWorldLayer : CCLayer {
    // NSMutableArray *_topBlockArray;
    NSMutableArray *_rightBlockArray;
    NSMutableArray *_leftBlockArray;
    b2World *_world;
    b2Body *_body;
    CCSprite *_block;
    b2Vec2 _mouseWorld;
    b2MouseJoint *_mouseJoint;
    //added code for hearty heart and volumeeeeeeee...
    CCTexture2D *heartSpriteTexture_;	// weak ref
    CCSprite *volumeMeterSprite;
    CCSprite *volumeBarSprite;
    CCLabelTTF *_scoreLabel;
    int score;
}
@property (strong, nonatomic) NSMutableArray *topBlockArray;
@property (strong, nonatomic) NSMutableArray *topMissingArray;
@property (assign, nonatomic) b2Body *grabbedBody;
@property (assign, nonatomic) CGPoint snapPoint;
-(void) addHeartSpriteAtPosition:(CGPoint)p;
+ (id)scene;
@end