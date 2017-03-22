//
//  AppDelegate.h
//  VRCinema
//
//  Created by asl on 2017/2/23.
//  Copyright © 2017年 Invisionhealth Digital Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

