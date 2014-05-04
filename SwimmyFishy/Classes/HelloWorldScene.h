//
//  HelloWorldScene.h
//  SwimmyFishy
//
//  Created by Richard Ison on 2014-05-03.
//  Copyright Richard Ison 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using Cocos2D v3
#import "cocos2d.h"
#import "cocos2d-ui.h"

// -----------------------------------------------------------------------

/**
 *  The main scene
 */
@interface HelloWorldScene : CCScene <CCPhysicsCollisionDelegate>{

    CCSprite *      player;
    CCSprite *      topBackground;
    CCSprite *      topBackground2;
    CCSprite *      bottomBackground;
    CCLabelTTF *    scoreLabel;
    CCPhysicsNode*  physicsWorld;
    
    int             score;
    float           jumpVel;
    
    NSTimer *       timer;


}

// -----------------------------------------------------------------------

+ (HelloWorldScene *)scene;
- (id)init;

// -----------------------------------------------------------------------
@end