//
//  HelloWorldLayer.mm
//  ggj13
//
//  Created by Brennon Redmyer on 1/25/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "QueryCallback.h"
#import "GameOverLayer.h"
#import "SimpleAudioEngine.h"



@implementation HelloWorldLayer {
    BOOL isGrabbed;
    BOOL hasBeenTouched;
}
+ (id)scene {
    CCScene *scene = [CCScene node];
    HelloWorldLayer *layer = [HelloWorldLayer node];
    [scene addChild:layer];
    return scene;
}
- (id)init {
    self = [super init];
    if (self) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCSprite *tempSprite = [CCSprite spriteWithFile:@"80block.png"];
        int imageHeight = tempSprite.contentSize.height;
        [[CCDirector sharedDirector] setDisplayStats:NO];
        _scoreLabel = [CCLabelTTF labelWithString:@"Score: 0" fontName:@"Arial" fontSize:16];
        _scoreLabel.position = ccp(0 + _scoreLabel.contentSize.width/2, winSize.height - imageHeight - _scoreLabel.contentSize.height/2);
        [self addChild:_scoreLabel z:1];
        // mousejoin nil
        _mouseJoint = nil;
        // enable touch
        self.isTouchEnabled = YES;
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
    
        groundEdge.Set(b2Vec2(0, 2), b2Vec2(winSize.width/PTM_RATIO, 2));
        groundBody->CreateFixture(&boxShapeDef);
        groundEdge.Set(b2Vec2(0, 0), b2Vec2(0, winSize.height/PTM_RATIO));
        groundBody->CreateFixture(&boxShapeDef);
        groundEdge.Set(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
        groundBody->CreateFixture(&boxShapeDef);
        groundEdge.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);
//        [self addLeftBlocks];
//        [self addRightBlocks];
      
        [self schedule:@selector(updateBlock:) interval:3.0f];
        [self schedule:@selector(tick:)];
        
        //Set up sprite
        GLESDebugDraw gGLESDebugDraw;
        self.numberofBar = 32;
        self.newBar = 0;
        //self->_contactListener = new MyContactListener();
        //_world->SetContactListener(self->_contactListener);
        self->contactListener = new ContactListener();
        _world->SetContactListener(self->contactListener);
	/*
     // --unComment Code below to check body collision/shape whatever.
        [self addChild:[BoxDebugLayer debugLayerWithWorld:_world ptmRatio:PTM_RATIO] z:10000];
     */
        
#if 1
		// Use batch node. Faster        
        CCSpriteBatchNode *parent1 = [CCSpriteBatchNode batchNodeWithFile:@"HeartAqua.png" capacity:100];
		heartSpriteTexture_ = [parent1 texture];
        
        CCSpriteBatchNode *parent2 = [CCSpriteBatchNode batchNodeWithFile:@"80block.png" capacity:100];
        blockSpriteTexture_ = [parent2 texture];
        
        //    CCSprite *tempSprite = [CCSprite spriteWithFile:@"80block.png"];
        
        //volumesprite
        volumeMeterSprite = [CCSprite spriteWithFile:@"Volumebar_black.png"];
        volumeMeterSprite.position = ccp(160, 25);
        [self addChild:volumeMeterSprite z:2 tag:0];
#else
        heartSpriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"HeartAqua.png"];
		CCNode *parent1 = [CCNode node];
        
         blockSpriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"80block.png"];
		CCNode *parent2 = [CCNode node];
#endif
        //heart
        [self addChild:parent1 z:0 tag:kTagheartParentNode];
        [self addChild:parent2 z:0 tag:kTagBlockParentNode];
        [self addHeartSpriteAtPosition:ccp(winSize.width/2, winSize.height/2)];
        //[self addNewSpriteAtPosition:ccp(winSize.width+5/2, winSize.height-5/2)];
        [self addTopBlocks];  
     }
    return self;
}
- (void)updateScore {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    [self setScoreLabel:[NSString stringWithFormat:@"Score: %d", score]];
    CCSprite *tempSprite = [CCSprite spriteWithFile:@"80block.png"];
    int imageHeight = tempSprite.contentSize.height;
    _scoreLabel.position = ccp(0 + _scoreLabel.contentSize.width/2, winSize.height - imageHeight - _scoreLabel.contentSize.height/2);
    if (score > 100) {
        CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
    }
}
- (void)setScoreLabel:(NSString *)string {
    _scoreLabel.string = string;
}

-(void)incrementVolumeMeter{
    for (int i = 0; i < 63; i++) {
        if (self.newBar != 0) {
            self.numberofBar = self.newBar;
        }
        if (self.numberofBar == 32) {
            volumeBarSprite = [CCSprite spriteWithFile:@"Volumebar_slider.png"];
            [self addChild:volumeBarSprite z:3 tag:3];
        }
        self.numberofBar = self.numberofBar +4;
        volumeBarSprite.position = ccp(self.numberofBar, 25);
        self.newBar = self.numberofBar;
        
        volumeBarSprite = [CCSprite spriteWithFile:@"Volumebar_slider.png"];
        [self addChild:volumeBarSprite z:3 tag:3+i];
    }
}

- (void)draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
    
    b2Draw *debugDraw = new GLESDebugDraw(PTM_RATIO);
    
    debugDraw->SetFlags(GLESDebugDraw::e_shapeBit);
    
    _world->SetDebugDraw(debugDraw);
    
	_world->DrawDebugData();
	
	kmGLPopMatrix();
}


-(void) addNewSpriteAtPosition:(CGPoint)p ccSprite:(PhysicsSprite *)sprite
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	CCNode *parent = [self getChildByTag:kTagBlockParentNode];
	
    sprite = [PhysicsSprite spriteWithTexture:blockSpriteTexture_];
	[parent addChild:sprite];
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
    bodyDef.userData = sprite;//_block.position.x/PTM_RATIO, _block.position.y/PTM_RATIO
	bodyDef.position.Set(sprite.position.x/PTM_RATIO, sprite.position.y/PTM_RATIO
);
	b2Body *body = _world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(19/PTM_RATIO, 19/PTM_RATIO);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
    sprite.userData = body;
	
	[sprite setPhysicsBody:body];
    [self.topBlockArray addObject:sprite];
}


- (void)addHeartSpriteAtPosition:(CGPoint)p
{
	CCLOG(@"Add heartsprite %0.2f x %02.f",p.x,p.y);
    
    //heart
    CCNode *parent1 = [self getChildByTag:kTagheartParentNode];
	
    //heart
    PhysicsSprite *heartsSprite = [PhysicsSprite spriteWithTexture:heartSpriteTexture_];
    
	
    //heart
    [parent1 addChild:heartsSprite];
	
    
    //heart
    heartsSprite.position = ccp(p.x, p.y);
    
    //heart
    b2BodyDef heartBodyDef;
    heartBodyDef.userData = heartsSprite;
	heartBodyDef.type = b2_staticBody;
	heartBodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *heartBody = _world->CreateBody(&heartBodyDef);
    
    //heart shapes
    //box
    b2PolygonShape heartdynamicBox;
	heartdynamicBox.SetAsBox(.30f, .30f);//These are mid points for our 1m box
    
    // Create circle shape
    b2CircleShape circle;
    circle.m_radius = 46.0/PTM_RATIO;
	
    //any shape we make it
    b2PolygonShape shape;
    int num = 6;
    b2Vec2 verts[] = {
        //middle point
        b2Vec2(0.0f*heartsSprite.scale / PTM_RATIO, 30.8f*heartsSprite.scale / PTM_RATIO),
        //left corner top
        b2Vec2(-35.2f*heartsSprite.scale / PTM_RATIO, 45.0f*heartsSprite.scale / PTM_RATIO),
        //bottom left corner
        b2Vec2(-60.0f*heartsSprite.scale / PTM_RATIO, -01.1f*heartsSprite.scale / PTM_RATIO),
        //center bottom
        b2Vec2(02.0f*heartsSprite.scale / PTM_RATIO, -62.0f*heartsSprite.scale / PTM_RATIO),
        //bottom right corner
        b2Vec2(60.0f*heartsSprite.scale / PTM_RATIO, -01.1f*heartsSprite.scale / PTM_RATIO),
        //top right corner
        b2Vec2(35.2f*heartsSprite.scale / PTM_RATIO, 45.0f*heartsSprite.scale / PTM_RATIO)
    };
    
    shape.Set(verts, num);
    b2FixtureDef heartFixtureDef;
	heartFixtureDef.shape = &circle;
	heartFixtureDef.density = 1.0f;
	heartFixtureDef.friction = 0.3f;
    heartFixtureDef.restitution = 0.4;
	heartBody->CreateFixture(&heartFixtureDef);
     heartFixture = heartBody->CreateFixture(&heartFixtureDef);
    [heartsSprite setPhysicsBody:heartBody];
}
- (void)addTopBlocks {
    
    //fix how we add blocks
    //..add block by ccnode;
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int imageWidth = blockSpriteTexture_.contentSize.width;
    int imageHeight = blockSpriteTexture_.contentSize.height;
    int numBlocks = winSize.width / imageWidth;
   
    self.topBlockArray = [NSMutableArray arrayWithCapacity:numBlocks];
    self.topMissingArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < numBlocks; i++) {
         PhysicsSprite *tempSprite;
        [self addNewSpriteAtPosition:CGPointMake(blockSpriteTexture_.contentSize.width * i+blockSpriteTexture_.contentSize.width * 0.5f, winSize.height - blockSpriteTexture_.contentSize.height/2) ccSprite:tempSprite];
        // create block body and shape
//        b2BodyDef blockBodyDef;
//        blockBodyDef.type = b2_staticBody;
//        blockBodyDef.position.Set(_block.position.x/PTM_RATIO, _block.position.y/PTM_RATIO);
//        blockBodyDef.userData = _block;
//        _body = _world->CreateBody(&blockBodyDef);
    
//        _block.userData = _body;
//        // modified for box shape instead of circle (from Ray Wenderlich's tutorial series)
//        b2PolygonShape box;
//        box.SetAsBox(19/PTM_RATIO, 19/PTM_RATIO);
//        b2FixtureDef blockShapeDef;
//        blockShapeDef.shape = &box;
//        blockShapeDef.density = 1.0f;
//        blockShapeDef.friction = 0.2f;
//        blockShapeDef.restitution = 0;
//        _body->CreateFixture(&blockShapeDef);
//        blockFixture = _body->CreateFixture(&blockShapeDef);
//        [self.topBlockArray addObject:_block];
        // [self.topMissingArray addObject:futureBlock];
//        [self addChild:_block z:0];
    }
}
- (void)addLeftBlocks {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCSprite *tempSprite = [CCSprite spriteWithFile:@"80block.png"];
    int imageWidth = tempSprite.contentSize.width;
    int imageHeight = tempSprite.contentSize.height;
    int numBlocks = winSize.width / imageWidth;
    _leftBlockArray = [NSMutableArray arrayWithCapacity:numBlocks];
    for (int i = 0; i < numBlocks; i++) {
        _body = nil;
        _block = nil;
        _block = [PhysicsSprite spriteWithTexture:blockSpriteTexture_];
        _block.position = CGPointMake(imageWidth/2, (winSize.height - _block.contentSize.height - (_block.contentSize.height * i+_block.contentSize.height * 0.5f)));
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
- (void)addRightBlocks {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCSprite *tempSprite = [CCSprite spriteWithFile:@"80block.png"];
    int imageWidth = tempSprite.contentSize.width;
    int imageHeight = tempSprite.contentSize.height;
    int numBlocks = winSize.width/ imageWidth;
    _rightBlockArray = [NSMutableArray arrayWithCapacity:numBlocks];
    for (int i = 0; i < numBlocks; i++) {
        _body = nil;
        _block = nil;
        _block = [CCSprite spriteWithFile:@"80block.png"];
        _block.position = CGPointMake(winSize.width - imageWidth/2, (winSize.height - _block.contentSize.height - (_block.contentSize.height * i+_block.contentSize.height * 0.5f)));
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
- (void)updateBlock:(ccTime) dt {
    CCLOG(@"array count: %d", self.topBlockArray.count);
    [self chooseBlock:dt withArray:self.topBlockArray];
}



- (void)chooseBlock:(ccTime)dt withArray:(NSMutableArray *)blockArray {
    int numItems = blockArray.count;
    int randIndex = arc4random() % numItems;

    NSMutableArray *missingArray;
    if (blockArray == self.topBlockArray) {
        missingArray = self.topMissingArray;
    }
    PhysicsSprite *block; //= [CCSprite spriteWithFile:@"80block.png"];
    _refBlock = block;
    CCSprite *futureBlock = [CCSprite spriteWithFile:@"80block.png"];
    if (numItems == 0) {
        CCScene *gameOverScene = [GameOverLayer sceneWithWon:NO];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
    }
    for (int i = 0; i < numItems; i++) {
        // holy shit, pissssss
        if (i == randIndex) {
            if ( i != self.lastIndex) {
                NSLog(@"randIndex => %i", randIndex);
                NSLog(@"lastIndex => %i", self.lastIndex);
                self.lastIndex = randIndex;
            
            block = [blockArray objectAtIndex:i];
            if (block == NULL) {
                NSLog(@"block is null");
            }
            b2Body* body = (b2Body *)block.userData;
            if (body != nil)
            {
                futureBlock.color = ccc3(100, 100, 100);
                futureBlock.position = block.position;
                [missingArray addObject:futureBlock];
                CCLOG(@"topmissing count: %d", missingArray.count);
                [self addChild:futureBlock z:-1];
                NSLog(@"The set Tag is currently => %i", i);
                block.tag = i;
                self.assignedBlockTag = i;
                body->SetType(b2_dynamicBody);
                [blockArray removeObject:block];
                break;
                }
            }
        }
    }
}
- (void)tick:(ccTime)dt {
    _world->Step(dt, 10, 10);
    for (b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *blockData = (CCSprite *)b->GetUserData();
            blockData.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            blockData.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
            std::vector<b2Body *>toDestroy;
            std::vector<MyContact>::iterator pos;
            for (pos=contactListener->_contacts.begin();
                 pos != contactListener->_contacts.end(); ++pos) {
                MyContact contact = *pos;
                
                b2Body *bodyA = contact.fixtureA->GetBody();
                b2Body *bodyB = contact.fixtureB->GetBody();
                if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
                    CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
                    CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
                    
                    //Sprite A = ball, Sprite B = Block
                    if (spriteA.tag == self.assignedBlockTag && spriteA && spriteB.tag == -1) {
                        if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) {
                            NSLog(@"This is sprite A TAG DELETION %i", spriteA.tag);
                            [self removeSprite:spriteA];
                            toDestroy.push_back(bodyA);
                        }
                    }
                }
            }
            std::vector<b2Body *>::iterator pos2;
            for (pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
                b2Body *body = *pos2;
                if (body->GetUserData() != NULL) {
                    NSLog(@"We are deleting a body");
                    CCSprite *sprite = (CCSprite *) body->GetUserData();
                    body->SetAwake(false);
                    _world->DestroyBody(body);
                    body = NULL;
                }
            }
            [self updateScore];
            [self checkCollision];
        }
    }
    
    
//        std::vector<b2Body *>toDestroy;
//        std::vector<MyContact>::iterator pos;
//        for (pos=contactListener->_contacts.begin();
//             pos != contactListener->_contacts.end(); ++pos) {
//            MyContact contact = *pos;
//    
//            b2Body *bodyA = contact.fixtureA->GetBody();
//            b2Body *bodyB = contact.fixtureB->GetBody();
//            if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
//                CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
//                CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
//    
//                //Sprite A = ball, Sprite B = Block
//                if (spriteA.tag == self.assignedBlockTag && spriteA && spriteB.tag == -1) {
//                    if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) {
//                         NSLog(@"This is sprite A TAG DELETION %i", spriteA.tag);
//                        spriteA.visible = false;
//                        //sprite removal is causing the crash
//                        self.assignedBlockTag = -2;
//                        spriteA = NULL;
//                        //spriteB = NULL;
//                        [self performSelector:@selector(removeSprite:)  withObject: spriteA afterDelay:1.5];
//                        toDestroy.push_back(bodyA);
//                        //_world->DestroyBody(bodyA);
//               
//                    }
//                }
//            }
//        }
//    
//        std::vector<b2Body *>::iterator pos2;
//        for (pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
//            b2Body *body = *pos2;
//            if (body->GetUserData() != NULL) {
//                NSLog(@"We are deleting a body");
//                CCSprite *sprite = (CCSprite *) body->GetUserData();
//                body->SetAwake(false);
//                 _world->DestroyBody(body);
//                body = NULL;
//               // [self removeChild:sprite cleanup:YES];
//        
//            }
//            // _world->DestroyBody(body);
//    }
//            
//    
//    [self updateScore];
//    [self checkCollision];

}

-(void)removeSprite:(id)sender
{
    CCSprite *spr = (CCSprite*)sender;
    NSLog(@"spr tag is %i", spr.tag);
    refSpr = spr;
   // spr.tag = -2;
    spr.visible = false;
    [spr removeChildByTag:self.assignedBlockTag cleanup:YES];
    //[spr removeAllChildrenWithCleanup:YES];
    //[spr removeFromParentAndCleanup:YES];
    //spr = NULL;
        
    //    printf("Removed ice block\n");
}


- (void)checkCollision {
    int index = -1;
    for (CCSprite *block in self.topMissingArray) {
        CGRect rect = block.boundingBox;
        self.snapPoint = block.position;
        /* block.color = ccc3(100, 100, 100); */
        if (self.grabbedBody != nil) {
            CCSprite *grabbedBlockSprite = (CCSprite*)self.grabbedBody->GetUserData();
            CGRect rect2 = grabbedBlockSprite.boundingBox;
            if (CGRectIntersectsRect(rect, rect2) && hasBeenTouched) {
                hasBeenTouched = NO;
                CCLOG(@"HIT FLING!!!");
                self.grabbedBody->SetTransform(b2Vec2(block.position.x/PTM_RATIO, block.position.y/PTM_RATIO), 0);
                self.grabbedBody->SetType(b2_staticBody);
                block.userData = self.grabbedBody;
                PhysicsSprite *newBlock;
                [self addNewSpriteAtPosition:block.position ccSprite:newBlock];
                grabbedBlockSprite.visible = false;
                [self DeleteBody:self.grabbedBody theSprite:grabbedBlockSprite];
           
                [self.topBlockArray addObject:newBlock];
                index = [self.topMissingArray indexOfObject:block];
                
                score += 10;
            }
        }
//        else if(self.grabbedBody == nil){
//            NSLog(@"grabbedBody is NULL/NIL gone!!!!");
//            b2AABB aabb;
//            b2Vec2 d = b2Vec2(0.001f, 0.001f);
//            aabb.lowerBound = _mouseWorld - d;
//            aabb.upperBound = _mouseWorld + d;
//            QueryCallback callback(_mouseWorld);
//            _world->QueryAABB(&callback, aabb);
//            
//            if (callback.m_fixture)
//            {
//                CCLOG(@"isGrabbed = %d", isGrabbed);
//                b2BodyDef bodyDef;
//                b2Body* groundBody = _world->CreateBody(&bodyDef);
//                
//                b2Body* bodyz = callback.m_fixture->GetBody();
//                _touchedBody = bodyz;
//                CCSprite *spriteA = (CCSprite *) bodyz->GetUserData();
////                spriteA.tag = -2;
//                self.grabbedBody = bodyz;
//                CCLOG(@"Grabbed body!");
//                bodyz->SetAwake(true);
//                
//                b2MouseJointDef md;
//                md.bodyA = groundBody;
//                md.bodyB = bodyz;
//                md.target = _mouseWorld;
//                md.maxForce = 1000.0f * bodyz->GetMass();
//                
//                _mouseJoint = (b2MouseJoint*)_world->CreateJoint(&md);
//            }
//        }
    }
    [self deleteObjects:index];
}

- (void)deleteBody:(b2Body *)getBodyForSprite sprite:(PhysicsSprite *)spriteOnStage inWorld:(b2World *)world_instance{
    for (b2Body *b = world_instance->GetBodyList(); b; b = b->GetNext()) {
        PhysicsSprite *spr = ((PhysicsSprite*)b->GetUserData());
        if (spr == spriteOnStage) {
            if ( b != 0 ) {
                b->SetAwake(false);
                // remove body
                if (_mouseJoint != NULL) {
                    _world->DestroyJoint(_mouseJoint);
                    _mouseJoint = NULL;
                }
                world_instance->DestroyBody(b);
                b = 0;
            }
        }
    }
}

- (void) DeleteBody:(b2Body*) bodyT theSprite:(CCSprite *)spr{
    
    if ( bodyT != 0 ) {
        bodyT->SetAwake(false);
        // remove body
        _world->DestroyBody(bodyT);
         [spr removeChildByTag:spr.tag cleanup:YES];
        bodyT = 0;
    }
}
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* myTouch = [touches anyObject];
	CGPoint location = [myTouch locationInView: [myTouch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	location = [self convertToNodeSpace:location];
    
	_mouseWorld.Set(ptm(location.x), ptm(location.y));
	if (_mouseJoint != NULL)
	{
		return;
	}
    
	b2AABB aabb;
	b2Vec2 d = b2Vec2(0.001f, 0.001f);
	aabb.lowerBound = _mouseWorld - d;
	aabb.upperBound = _mouseWorld + d;
    
	// Query the world for overlapping shapes.
	QueryCallback callback(_mouseWorld);
	_world->QueryAABB(&callback, aabb);
    
	if (callback.m_fixture)
	{
        isGrabbed = YES;
        hasBeenTouched = YES;
        CCLOG(@"isGrabbed = %d", isGrabbed);
		b2BodyDef bodyDef;
		b2Body* groundBody = _world->CreateBody(&bodyDef);
        
		b2Body* bodyz = callback.m_fixture->GetBody();
        _touchedBody = bodyz;
        CCSprite *spriteA = (CCSprite *) bodyz->GetUserData();
        spriteA.tag = -2;
        self.grabbedBody = bodyz;
        CCLOG(@"Grabbed body!");
		bodyz->SetAwake(true);
        
		b2MouseJointDef md;
		md.bodyA = groundBody;
		md.bodyB = bodyz;
		md.target = _mouseWorld;
		md.maxForce = 1000.0f * bodyz->GetMass();
        
		_mouseJoint = (b2MouseJoint*)_world->CreateJoint(&md);
	}
}
- (void)ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch* myTouch = [touches anyObject];
	CGPoint location = [myTouch locationInView: [myTouch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	location = [self convertToNodeSpace:location];
    int index = -1;
	_mouseWorld.Set(ptm(location.x), ptm(location.y));
    
	if (_mouseJoint)
	{
		_mouseJoint->SetTarget(_mouseWorld);
	}
//    for (CCSprite *block in self.topMissingArray) {
//        CGRect rect = block.boundingBox;
//        if (CGRectContainsPoint(rect, location)) {
//            CCLOG(@"HIT!!!");
//            self.snapPoint = block.position;
//            /* block.color = ccc3(100, 100, 100); */
//            CCSprite *grabbedBlockSprite = (CCSprite*)self.grabbedBody->GetUserData();
//            CGRect rect2 = grabbedBlockSprite.boundingBox;
//            if (CGRectIntersectsRect(rect, rect2) && hasBeenTouched) {
//                hasBeenTouched = NO;
//                self.grabbedBody->SetTransform(b2Vec2(block.position.x/PTM_RATIO, block.position.y/PTM_RATIO), 0);
//                self.grabbedBody->SetType(b2_staticBody);
//                block.userData = self.grabbedBody;
//                [self.topBlockArray addObject:block];
//                index = [self.topMissingArray indexOfObject:block];
//                score += 10;
//            }
//        }
//    }
//    [self deleteObjects:index];
}
- (void)deleteObjects:(int)index {
    if (index != -1) {
        [self.topMissingArray removeObjectAtIndex:index];
        CCLOG(@"topmissingarray count: %d", self.topMissingArray.count);
    }
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    b2Body *b = _mouseJoint->GetBodyB();
//    CCSprite *spriteA = (CCSprite *) b->GetUserData();
//    spriteA.tag = -2;
 
  
    UITouch* myTouch = [touches anyObject];
	CGPoint location = [myTouch locationInView: [myTouch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	location = [self convertToNodeSpace:location];
	[self ccTouchesCancelled:touches withEvent:event];
    
}
- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	     
    if (_mouseJoint)
	{
        b2Body *b = _mouseJoint->GetBodyB();
        b2Vec2 velocity = b->GetLinearVelocity();
        float32 speed = velocity.Normalize();

   
        
        CCSprite *spriteA = (CCSprite *) b->GetUserData();
        spriteA.tag = -2;
        if (speed > 35) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"block_flick1.caf"];
        }
      
            _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
		
        if (isGrabbed) {
            isGrabbed = NO;
        
        
        //CCLOG(@"%@", self.grabbedBody->GetUserData());
        CCLOG(@"Released body!");
        CCLOG(@"isGrabbed: %d", isGrabbed);
	}
}
//- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    // switch bodydef to dynamic and back
////    CCLOG(@"Touch!!");
////    for (b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
////        if (b->GetType() == b2_dynamicBody) {
////            CCLOG(@"Bodies dynamic, going static...");
////            b->SetType(b2_staticBody);
////        } else {
////            CCLOG(@"Bodies static, going dynamic...");
////            b->SetType(b2_dynamicBody);
////        }
////    }
//}
}
@end