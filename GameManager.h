//
//  GameManagerViewController.h
//  Pacman
//
//  Created by Администратор on 2/14/13.
//  Copyright (c) 2013 Olesya. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Monster.h"
#import "Pacman.h"
#import "CustomPacmanLabel.h"

@interface GameManager : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *labirint;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (nonatomic, strong) Pacman *pacman;
@property (nonatomic, strong) Monster *monster;
@property (nonatomic) NSInteger gameState;
@property (nonatomic) NSInteger foodCount;
@property (nonatomic) NSInteger gameScore;

+ (id)sharedInstance;

@property (strong, nonatomic) IBOutlet CustomPacmanLabel *scoreLabel;

@end
