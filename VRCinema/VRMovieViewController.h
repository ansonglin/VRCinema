//
//  VRMovieViewController.h
//  VRCinema
//
//  Created by asl on 2017/2/23.
//  Copyright © 2017年 Invisionhealth Digital Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VRMovieViewController : UIViewController


//local: [NSURL fileURLWithPath:path]
//online: [NSURL URLWithString:@""]
- (id)initWithUrl:(NSURL *)playUrl;

@end
