//
//  VRMovieViewController.m
//  VRCinema
//
//  Created by asl on 2017/2/23.
//  Copyright © 2017年 Invisionhealth Digital Inc. All rights reserved.
//

#import "VRMovieViewController.h"
#import <SceneKit/SceneKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#import <MediaPlayer/MediaPlayer.h>
#import <GLKit/GLKit.h>
#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

#define SCENE_R 200
#define SCENE_SIZE  2048
#define CAMERA_FOX  70             //50
#define CAMERA_HEIGHT   20          //20
#define GROUND_POS  -50
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define MENU_ZAN         @"MENU_ZAN"
#define TIMER_FPS   4

#define TAG_ANIMATION_KEY   @"animation_key"

@interface VRMovieViewController ()<SCNSceneRendererDelegate,UIGestureRecognizerDelegate>


//基础Scene
@property (nonatomic,retain)SCNScene *rootScene;
@property (nonatomic,retain)SKScene *spriteKitScene;
@property (nonatomic,retain)SCNNode *floorNode;
@property (nonnull,retain)SCNLight *light;  //灯光

//摄像机
@property(nonatomic,retain)SCNView *leftView;
@property(nonatomic,retain)SCNView *rightView;
@property(nonatomic,retain)SCNNode *cameraLeftNode;
@property(nonatomic,retain)SCNNode *cameraRightNode;

@property(nonatomic,retain)SCNNode *cameraRollLeftNode;
@property(nonatomic,retain)SCNNode *cameraPitchLeftNode;
@property(nonatomic,retain)SCNNode *cameraYawLeftNode;

@property(nonatomic,retain)SCNNode *cameraRollRightNode;
@property(nonatomic,retain)SCNNode *cameraPitchRightNode;
@property(nonatomic,retain)SCNNode *cameraYawRightNode;

@property(nonatomic,retain)CMMotionManager *motionManager;

//全景视频播放
@property (nonatomic,retain)SCNNode *videoNode;
@property (nonatomic,retain)SKVideoNode *videoSpriteKitNode;
@property (nonatomic,retain)AVPlayer *videoAvplayer;
@property (nonatomic,retain)AVPlayerItem *videoAvplayerItem;


//场景
@property (nonatomic,retain)NSMutableArray *spaceTheatreArray;               //剧场

//信号量
@property (nonatomic,assign)BOOL isVR;

//播放地址
@property (nonatomic,retain)NSURL *playUrl;
@end

@implementation VRMovieViewController
//摄像机
@synthesize leftView;
@synthesize rightView;
@synthesize cameraLeftNode;
@synthesize cameraRightNode;

@synthesize cameraRollLeftNode;
@synthesize cameraPitchLeftNode;
@synthesize cameraYawLeftNode;

@synthesize cameraRollRightNode;
@synthesize cameraPitchRightNode;
@synthesize cameraYawRightNode;

@synthesize motionManager;

//全景视频播放
@synthesize videoNode;
@synthesize videoSpriteKitNode;
@synthesize videoAvplayer;
@synthesize videoAvplayerItem;

- (id)initWithUrl:(NSURL *)playUrl
{
    self = [super initWithNibName:nil bundle:nil];
    if(self)
    {
        self.playUrl = playUrl;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isVR = YES;
    [self initDatas];
    
    [self initScene];
    
    [self initSceneTheatre];
    
    
    
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    bt.frame = CGRectMake(0, 0, 40, 40);
    bt.layer.cornerRadius = 5.0f;
    [bt setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.5]];
    bt.center = CGPointMake(ScreenWidth  - 40, ScreenHeight / 2);
    [bt setImage:[UIImage imageNamed:@"vr.png"] forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(switchVR) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:bt];
    
    UIButton *closeBt = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBt.frame = CGRectMake(0, 0, 40, 40);
    closeBt.layer.cornerRadius = 5.0f;
    [closeBt setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.5]];
    closeBt.center = CGPointMake(40, ScreenHeight / 2);
    [closeBt setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBt addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBt];
    
    
}

- (void)close
{
//    if(self.videoAvplayerItem != nil)
//    {
//        [self.spaceTheatreArray removeObject:self.videoNode];
//        [self.videoAvplayer pause];
//        [self.videoSpriteKitNode pause];
//        [self.videoNode setPaused:YES];
//        [self.videoSpriteKitNode removeFromParent];
//        [self.videoNode removeFromParentNode];
//        self.spriteKitScene.paused = YES;
//        self.videoNode = nil;
//        self.videoSpriteKitNode = nil;
//        self.videoAvplayer = nil;
//        self.videoAvplayerItem = nil;
//        self.spriteKitScene = nil;
//    }
//    if(self.spaceTheatreArray != nil)
//    {
//        [self.spaceTheatreArray removeAllObjects];
//        self.spaceTheatreArray = nil;
//    }

    [self.navigationController popViewControllerAnimated:NO];
}

- (void)switchVR
{
    if(self.isVR)
    {
        [self makeIpad];
        self.isVR = NO;
    }
    else{
        [self makeVR];
        self.isVR = YES;
    }
}


- (void)makeIpad
{
    self.leftView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    self.rightView.alpha = 0;
}
- (void)makeVR
{
    self.leftView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight / 2 );
    self.rightView.alpha = 1;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.leftView.playing = YES;
    self.leftView.scene.paused = NO;
    
    self.rightView.playing = YES;
    self.rightView.scene.paused = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(self.leftView != nil)
    {
        self.leftView.playing = NO;
        self.leftView.scene.paused = YES;
    }
    if(self.rightView != nil)
    {
        self.rightView.playing = NO;
        self.rightView.scene.paused = YES;
    }
}

- (void)initDatas
{
    if(self.spaceTheatreArray == nil)
    {
        self.spaceTheatreArray = [[NSMutableArray alloc] initWithCapacity:20];
    }
}

- (void)initScene
{
    self.rootScene = [SCNScene scene];
    self.leftView = [[SCNView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight / 2 ) options:nil];
    self.leftView.scene = self.rootScene;
    self.leftView.alpha = 0;
    self.leftView.playing = NO;
    self.leftView.autoenablesDefaultLighting = YES;
    self.leftView.userInteractionEnabled = YES;
    self.leftView.multipleTouchEnabled = YES;
    [self.leftView setJitteringEnabled:YES];
    [self.leftView autoenablesDefaultLighting];
    self.leftView.backgroundColor = [UIColor clearColor];
    self.leftView.delegate = self;
    [self.view addSubview:self.leftView];
    
    self.rightView = [[SCNView alloc] initWithFrame:CGRectMake(0, ScreenHeight / 2, ScreenWidth, ScreenHeight / 2 ) options:nil];
    self.rightView.scene = self.rootScene;
    self.rightView.alpha = 0;
    self.rightView.playing = NO;
    self.rightView.autoenablesDefaultLighting = YES;
    self.rightView.userInteractionEnabled = YES;
    self.rightView.multipleTouchEnabled = YES;
    [self.rightView setJitteringEnabled:YES];
    [self.rightView autoenablesDefaultLighting];
    self.rightView.backgroundColor = [UIColor clearColor];
    self.rightView.delegate = self;
    [self.view addSubview:self.rightView];
    
    
    //左－－－－－－－－－－－－－－－－－－－－－－－
    //VRCamera *cam = [VRCamera new];
    self.cameraLeftNode = [SCNNode node];
    SCNCamera *cameraLeft = [SCNCamera camera];
    cameraLeft.xFov = CAMERA_FOX;
    cameraLeft.yFov = CAMERA_FOX;
    cameraLeft.zFar = 700;
    self.cameraLeftNode.camera = cameraLeft;
    SCNVector3 v3Left = {-0.1,CAMERA_HEIGHT,0};
    self.cameraLeftNode.position = v3Left;
    self.cameraLeftNode.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(-90), 0, 0);
    
    //右－－－－－－－－－－－－－－－－－－－－－－－
    self.cameraRightNode = [SCNNode node];
    SCNCamera *cameraRight = [SCNCamera camera];
    cameraRight.xFov = CAMERA_FOX;
    cameraRight.yFov = CAMERA_FOX;
    cameraRight.zFar = 700;
    self.cameraRightNode.camera = cameraRight;
    SCNVector3 v3Right = {0.1,CAMERA_HEIGHT,0};
    self.cameraRightNode.position = v3Right;
    self.cameraRightNode.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(-90), 0, 0);
    
    self.cameraRollLeftNode = [SCNNode node];
    self.cameraPitchLeftNode = [SCNNode node];
    self.cameraYawLeftNode = [SCNNode node];
    [self.cameraRollLeftNode addChildNode:self.cameraLeftNode];
    [self.cameraPitchLeftNode addChildNode:self.cameraRollLeftNode];
    [self.cameraYawLeftNode addChildNode:self.cameraPitchLeftNode];
    
    self.cameraRollRightNode = [SCNNode node];
    self.cameraPitchRightNode = [SCNNode node];
    self.cameraYawRightNode = [SCNNode node];
    [self.cameraRollRightNode addChildNode:self.cameraRightNode];
    [self.cameraPitchRightNode addChildNode:self.cameraRollRightNode];
    [self.cameraYawRightNode addChildNode:self.cameraPitchRightNode];
    
    [self.rootScene.rootNode addChildNode:self.cameraYawLeftNode];
    self.leftView.pointOfView = self.cameraLeftNode;
    self.rightView.pointOfView = self.cameraRightNode;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1/60;
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical toQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion *motion, NSError *error) {
    }];
    
    self.light = [SCNLight light];
    self.light.type = SCNLightTypeOmni;
    self.light.color = [UIColor whiteColor];
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = self.light;
    SCNVector3 lightV3 = {0,0,0};
    lightNode.position = lightV3;
    [self.rootScene.rootNode addChildNode:lightNode];
    
    SCNLight *light2 = [SCNLight light];
    light2.type = SCNLightTypeSpot;
    light2.color = [UIColor colorWithWhite:0.3 alpha:1.0f];
    SCNNode *lightNode2 = [SCNNode node];
    lightNode2.light = light2;
    lightNode2.rotation = SCNVector4Make(1, 0, 0, -M_PI/2);
    SCNVector3 light2V3 = {0,900,0};
    lightNode2.position = light2V3;
    [self.rootScene.rootNode addChildNode:lightNode2];
    
    self.leftView.alpha = 1;
    self.rightView.alpha = 1;
}

- (void)initSceneTheatre
{
    self.videoAvplayerItem = [AVPlayerItem playerItemWithURL:self.playUrl];
    
    self.videoAvplayer = [AVPlayer playerWithPlayerItem:self.videoAvplayerItem];
    self.videoSpriteKitNode = [SKVideoNode videoNodeWithAVPlayer:self.videoAvplayer];
    
    self.videoNode = [SCNNode node];
    self.videoNode.geometry = [SCNSphere sphereWithRadius:SCENE_R];
    SKScene *spriteKitScene = [SKScene sceneWithSize:CGSizeMake(SCENE_SIZE, SCENE_SIZE)];
    spriteKitScene.scaleMode = SKSceneScaleModeAspectFit;
    self.videoSpriteKitNode.position = CGPointMake(spriteKitScene.size.width / 2, spriteKitScene.size.height / 2);
    self.videoSpriteKitNode.size = spriteKitScene.size;
    [spriteKitScene addChild:self.videoSpriteKitNode];
    
    self.videoNode.geometry.firstMaterial.diffuse.contents = spriteKitScene;
    self.videoNode.geometry.firstMaterial.doubleSided = YES;
    SCNMatrix4 transform = SCNMatrix4MakeRotation((float)M_PI, 0.0, 0.0, 1.0);
    transform = SCNMatrix4Translate(transform, 1.0, 1.0, 0.0);
    
    self.videoNode.pivot = SCNMatrix4MakeRotation((float)M_PI_2,0.0,-1.0,0.0);
    self.videoNode.geometry.firstMaterial.diffuse.contentsTransform = transform;
    self.videoNode.position = SCNVector3Make(0, 0, 0);
    [self.spaceTheatreArray addObject:self.videoNode];
    
    for(SCNNode *node in self.spaceTheatreArray)
    {
        [node setHidden:NO];
        [self.rootScene.rootNode addChildNode:node];
        [self.videoSpriteKitNode play];
    }
}

- (void)renderer:(id <SCNSceneRenderer>)renderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time
{
    if(self.cameraRollLeftNode != nil && self.cameraPitchLeftNode != nil && self.cameraYawLeftNode != nil && self.motionManager != nil)
    {
//        @autoreleasepool {
            SCNVector3 v13 = self.cameraRollLeftNode.eulerAngles;
            v13.z = (float)(0 - self.motionManager.deviceMotion.attitude.roll);
            self.cameraRollLeftNode.eulerAngles = v13;
            self.cameraRollRightNode.eulerAngles = v13;
            
            SCNVector3 v23 = self.cameraPitchLeftNode.eulerAngles;
            v23.x = self.motionManager.deviceMotion.attitude.pitch;
            self.cameraPitchLeftNode.eulerAngles = v23;
            self.cameraPitchRightNode.eulerAngles = v23;
            
            SCNVector3 v33 = self.cameraYawLeftNode.eulerAngles;
            v33.y = self.motionManager.deviceMotion.attitude.yaw;
            self.cameraYawLeftNode.eulerAngles = v33;
            self.cameraYawRightNode.eulerAngles = v33;
//        }
        
    }
}

- (void)dealloc
{
    self.leftView.delegate = nil;
    self.rightView.delegate = nil;
    if(self.videoAvplayerItem != nil)
    {
        [self.spaceTheatreArray removeObject:self.videoNode];
        [self.videoAvplayer pause];
        [self.videoSpriteKitNode pause];
        [self.videoNode setPaused:YES];
        [self.videoSpriteKitNode removeFromParent];
        [self.videoNode removeFromParentNode];
        self.spriteKitScene.paused = YES;
        self.videoNode = nil;
        self.videoSpriteKitNode = nil;
        self.videoAvplayer = nil;
        self.videoAvplayerItem = nil;
        self.spriteKitScene = nil;
    }
    if(self.spaceTheatreArray != nil)
    {
        [self.spaceTheatreArray removeAllObjects];
        self.spaceTheatreArray = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
