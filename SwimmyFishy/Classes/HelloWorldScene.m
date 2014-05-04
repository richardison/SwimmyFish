//
//  HelloWorldScene.m
//  SwimmyFishy
//
//  Created by Richard Ison on 2014-05-03.
//  Copyright Richard Ison 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "HelloWorldScene.h"
#import "IntroScene.h"


// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation HelloWorldScene
{
    CCSprite *_sprite;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (HelloWorldScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    [self drawWorld];
    
    // Create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Verdana-Bold" fontSize:18.0f];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.85f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];

    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    [self startTimers];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}






- (void) drawWorld {
    [self drawBackground];
    [self drawPhysicsWorld];
    [self drawFish];
    [self drawScore];
}



- (void) drawBackground {

    //Top
    topBackground               = [CCSprite spriteWithImageNamed:@"TopBackground.png"];
    topBackground.anchorPoint   = ccp(0,0);
    topBackground.position      = ccp(0, self.contentSize.height - topBackground.contentSize.height);
    
    [self addChild:topBackground];
    
    topBackground2               = [CCSprite spriteWithImageNamed:@"TopBackground.png"];
    topBackground2.anchorPoint   = ccp(0,0);
    topBackground2.position      = ccp([topBackground boundingBox].size.width - 1, self.contentSize.height - topBackground.contentSize.height);
    
    [self addChild:topBackground2];
    
    
    //Bottom
    bottomBackground               = [CCSprite spriteWithImageNamed:@"BottomBackground.png"];
    bottomBackground.anchorPoint   = ccp(0,0);
    bottomBackground.position      = ccp(0,0);
    
    [self addChild:bottomBackground];

}


- (void) drawPhysicsWorld {
    
    physicsWorld                    = [CCPhysicsNode node];
    physicsWorld.gravity            = ccp(0, 0);
    physicsWorld.debugDraw          = NO;
    physicsWorld.collisionDelegate  = self;
    
    [self addChild:physicsWorld];
}


- (void) drawFish {

    player = [CCSprite spriteWithImageNamed:@"fishy.png"];
    player.position = ccp(self.contentSize.width/5, self.contentSize.height/2);
    player.physicsBody                = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, player.contentSize}
                                                       cornerRadius:0];
    player.physicsBody.collisionGroup = @"playerGroup";
    player.physicsBody.collisionType  = @"projectileCollision";
    
    [physicsWorld addChild: player];
}


- (void) drawScore {

    score = 0;
    scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", score]
                                    fontName:@"American Typewriter" fontSize:40];
    scoreLabel.positionType = CCPositionTypeNormalized;
    scoreLabel.color = [CCColor whiteColor];
    scoreLabel.position = ccp(0.5f, 0.9f);
    [self addChild:scoreLabel];

}

- (void) startTimers{
    jumpVel = 5;
    timer = [ NSTimer scheduledTimerWithTimeInterval:0.020 target:self selector:@selector(jump) userInfo:nil repeats:YES];
    [self schedule:@selector(scrollBackground:) interval:0.005];
    [self schedule:@selector(addObjects:) interval:2];
}


- (void) scrollBackground:(CCTime)dt{

    //Scroll to the left to the left
    
    topBackground.position = ccp(topBackground.position.x - 1, topBackground.position.y);
    topBackground2.position = ccp(topBackground2.position.x - 1, topBackground2.position.y);
    
    
    if (topBackground.position.x < - [topBackground boundingBox].size.width) {
        topBackground.position = ccp(topBackground2.position.x + [topBackground2 boundingBox].size.width,
                                     topBackground.position.y);
    }
    
    
    if (topBackground2.position.x < - [topBackground2 boundingBox].size.width) {
        topBackground2.position = ccp(topBackground.position.x + [topBackground boundingBox].size.width,
                                     topBackground2.position.y);
    }


}


- (void) jump {

    if (player.position.y > 40) jumpVel -= 0.25;
    else {
        if (jumpVel !=5) {
            jumpVel = 0;
        }
    }
    
    player.position = ccp(player.position.x, player.position.y + jumpVel);
}


- (void) addBody: (int) body up:(BOOL) up {

    int bY = up ? 0 : self.contentSize.height - 40;
    int bHeight = 0;
    
    CGPoint bPos = CGPointZero;
    
    for (int i = 0; i < body; i++){
        CCSprite *objBody = [CCSprite spriteWithImageNamed: !up ? @"body-seaweed.png" : @"rodstring.png"];
        
        bPos = CGPointMake(self.contentSize.width + objBody.contentSize.width/2,
                           self.contentSize.height - bY);
        
        if (up) bY += objBody.contentSize.height;
        else bY -= objBody.contentSize.height;
        
        objBody.position = bPos;
        objBody.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, objBody.contentSize} cornerRadius:0];
        objBody.physicsBody.type = CCPhysicsBodyTypeStatic;
        objBody.physicsBody.collisionGroup = @"monsterGroup";
        objBody.physicsBody.collisionType = @"monsterCollision";
        
        [physicsWorld addChild:objBody];
        
        
        
        //Move the bodies to the left
        CCAction *actionMoveBody = [CCActionMoveTo actionWithDuration:2.0
                                                             position:CGPointMake(-objBody.contentSize.width/2,
                                                                                  objBody.position.y)];
        
        CCAction *actionRemove = [CCActionRemove action];
        
        [objBody runAction:[CCActionSequence actionWithArray:@[actionMoveBody, actionRemove]]];
        
        
        bHeight += objBody.contentSize.height;
    }
    
    if (up) {
        CCSprite *hook = [CCSprite spriteWithImageNamed:@"fishhook.png"];
        
        hook.position = CGPointMake(self.contentSize.width + hook.contentSize.width/2,
                                    self.contentSize.height - bY);
        
        hook.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:hook.contentSize.width/2.0f
                                                       andCenter:hook.anchorPointInPoints];
        
        hook.physicsBody.type = CCPhysicsBodyTypeStatic;
        hook.physicsBody.collisionGroup = @"monsterGroup";
        hook.physicsBody.collisionType = @"monsterCollision";
        
        [physicsWorld addChild:hook];
        
        CCAction *actionMoveBody = [CCActionMoveTo actionWithDuration:2.0
                                                             position:CGPointMake(-hook.contentSize.width/2,
                                                                                  hook.position.y)];
        
        CCAction *actionRemove = [CCActionRemove action];
        
        [hook runAction:[CCActionSequence actionWithArray:@[actionMoveBody, actionRemove]]];
       
    } else {
        CCSprite *seaweedTop = [CCSprite spriteWithImageNamed:@"top-seaweed.png"];
        
        seaweedTop.position = CGPointMake(self.contentSize.width + seaweedTop.contentSize.width/2,
                                    self.contentSize.height - bY);
       
        
        seaweedTop.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, seaweedTop.contentSize} cornerRadius:0];
        
        seaweedTop.physicsBody.type = CCPhysicsBodyTypeStatic;
        seaweedTop.physicsBody.collisionGroup = @"monsterGroup";
        seaweedTop.physicsBody.collisionType = @"monsterCollision";
        
        [physicsWorld addChild:seaweedTop];
        
        CCAction *actionMoveDown = [CCActionMoveTo actionWithDuration:2.0
                                                             position:CGPointMake(- seaweedTop.contentSize.width/2,
                                                                                  seaweedTop.position.y)];
        
        CCAction *actionRemove = [CCActionRemove action];
        
        [seaweedTop runAction:[CCActionSequence actionWithArray:@[actionMoveDown, actionRemove]]];
        
       
    }
}


- (void) addObjects:(CCTime) time {
    if (time == 0.0f) return;
    
    int max = 4;
    int rUp = arc4random() % max;
    if (rUp == 0) rUp++;
    
    [self addBody:rUp up:YES];
    [self addBody:max - rUp up:NO];
    
    [self scheduleBlock:^(CCTimer *timer)
     {
         [scoreLabel setString:[NSString stringWithFormat:@"%d", ++score]];
        
     } delay:1.6];



}


// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint touchLoc = [touch locationInNode:self];
    
    jumpVel = 5;
}


- (BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair monsterCollision:(CCNode *)monster projectileCollision:(CCNode *)projectile
{
    //[ self gameOver ];
    
    
    NSLog(@"HIT");
    return YES;
}



// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

// -----------------------------------------------------------------------
@end
