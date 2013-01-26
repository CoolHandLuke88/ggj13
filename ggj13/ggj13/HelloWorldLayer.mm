//
//  HelloWorldLayer.mm
//  ggj13
//
//  Created by Brennon Redmyer on 1/25/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "HelloWorldLayer.h"
@implementation HelloWorldLayer
+ (id)scene {
    CCScene *scene = [CCScene node];
    HelloWorldLayer *layer = [HelloWorldLayer node];
    [scene addChild:layer];
    return scene;
}
- (id)init {
    self = [super init];
    if (self) {
        // enable touch
        self.isTouchEnabled = YES;
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // create sprite and add it to the layer
//        _block = [CCSprite spriteWithFile:@"block_base.png"];
//        _block.position = ccp(100, 300);
        // create a world
        b2Vec2 gravity = b2Vec2(0.0f, -8.0f);
        _world = new b2World(gravity);
        // create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0, 0);
        b2Body *groundBody = _world->CreateBody(&groundBodyDef);
        b2EdgeShape groundEdge;
        b2FixtureDef boxShapeDef;
        boxShapeDef.shape = &groundEdge;
        // wall definitions
        groundEdge.Set(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);
        [self addBlocks];
        [self schedule:@selector(tick:)];
    }
    return self;
}
- (void)addBlocks {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCSprite *tempSprite = [CCSprite spriteWithFile:@"block_base.png"];
    int imageWidth = tempSprite.contentSize.width;
    int imageHeight = tempSprite.contentSize.height;
    int numBlocks = winSize.width / imageWidth;
    _blockArray = [NSMutableArray arrayWithCapacity:numBlocks];
    for (int i = 0; i < numBlocks; i++) {
        _body = nil;
        _block = nil;
        _block = [CCSprite spriteWithFile:@"block_base.png"];
        _block.position = CGPointMake(_block.contentSize.width * i+_block.contentSize.width * 0.5f, winSize.height - _block.contentSize.height/2);
        // create block body and shape
        b2BodyDef blockBodyDef;
        blockBodyDef.type = b2_staticBody;
        blockBodyDef.position.Set(_block.position.x/PTM_RATIO, _block.position.y/PTM_RATIO);
        blockBodyDef.userData = _block;
        _body = _world->CreateBody(&blockBodyDef);
        // modified for box shape instead of circle (from Ray Wenderlich's tutorial series)
        b2PolygonShape box;
        box.SetAsBox(16/PTM_RATIO, 16/PTM_RATIO);
        b2FixtureDef blockShapeDef;
        blockShapeDef.shape = &box;
        blockShapeDef.density = 1.0f;
        blockShapeDef.friction = 0.2f;
        blockShapeDef.restitution = 0;
        _body->CreateFixture(&blockShapeDef);
        [self addChild:_block];
    }
}
- (void)tick:(ccTime)dt {
    _world->Step(dt, 10, 10);
    for (b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *blockData = (CCSprite *)b->GetUserData();
            blockData.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            blockData.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // switch bodydef to dynamic and back
    /*
    CCLOG(@"Touch!!");
    for (b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetType() == b2_dynamicBody) {
            CCLOG(@"Bodies dynamic, going static...");
            b->SetType(b2_staticBody);
        } else {
            CCLOG(@"Bodies static, going dynamic...");
            b->SetType(b2_dynamicBody);
        }
    }
    */
    // apply random force
    float rand = CCRANDOM_0_1() * 50;
    b2Vec2 force = b2Vec2(0, rand);
    _body->ApplyLinearImpulse(force, _body->GetPosition());
}
@end