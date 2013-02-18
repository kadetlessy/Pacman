//
//  AppDelegate.h
//  Pacman
//
//  Created by Администратор on 2/11/13.
//  Copyright (c) 2013 Olesya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    OpenGLView* _glView;
}

@property (strong, nonatomic) UIWindow *window;

@end
