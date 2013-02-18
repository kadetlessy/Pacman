//
//  GameManagerViewController.m
//  Pacman
//
//  Created by Администратор on 2/14/13.
//  Copyright (c) 2013 Olesya. All rights reserved.
//

#import "GameManager.h"
#import "OpenGLView.h"
#import "GameOverView.h"

@interface GameManager ()

@end

@implementation GameManager

@synthesize labirint, pacman, monster, foodCount, gameState, gameScore, scoreLabel;

static GameManager *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (GameManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self registerSwipeRecognizers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateGameState:)
                                                 name:@"Pacman's coordinates were changed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateGameState:)
                                                 name:@"Monster's coordinates were changed"
                                               object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    [self gameInitialization];
}

- (void)gameInitialization
{
    pacman = [[Pacman alloc] init];
    monster = [[Monster alloc] init];
    foodCount = 0;
    gameScore = 0;
    scoreLabel.text = [NSString stringWithFormat:@"%d/%d", gameScore, TOTAL_SCORE];
    gameState = GAME_ON;
    
    [self loadLabirint];
    OpenGLView *subView = [[OpenGLView alloc] initWithFrame:CGRectMake(0, 0, 320, 440)];
    subView.tag = 1;
    [self.view addSubview:subView];
}

- (void)loadLabirint
{
	NSError *error;
	[NSBundle mainBundle] ;
	NSStringEncoding encoding;
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"labirint" ofType:@"txt"];
	NSString *labirintData = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&error];
	if (labirintData == nil)
	{
		NSLog(@"Error loading labirint data! %@", error);
		return;
	}
	labirintData = [[labirintData componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString: @""];
	if ([labirintData length] < (LABIRINT_COLUMNS_NUM*LABIRINT_LINES_NUM))
	{
		NSLog(@"Labirint data has incorrect size!");
		return;
	}
    
    labirint = [[NSMutableArray alloc] init];
    int x = 0;
    Coords pacmanCoords, monsterCoords;
    for (int i = 0; i < LABIRINT_LINES_NUM; i++) {
        NSMutableArray *row = [[NSMutableArray alloc] init];
        for (int j = 0; j < LABIRINT_COLUMNS_NUM; j++){
            int digit = [labirintData characterAtIndex:x] - '0';
            if (digit == PACMAN) {
                pacmanCoords.x = i;
                pacmanCoords.y = j;
            }
            if (digit == MONSTER) {
                monsterCoords.x = i;
                monsterCoords.y = j;
            }
            if (digit == FOOD) {
                foodCount++;
            }
            [row addObject:@(digit)];
            x++;
        }
        [labirint addObject:row];
    }
    
    int fruit = CHERRY;
    while (fruit != 9) {
        x = arc4random() % LABIRINT_LINES_NUM;
        int y = arc4random() % LABIRINT_COLUMNS_NUM;
        if ([labirint[x][y] isEqualToNumber:@(FOOD)]) {
            [labirint[x] replaceObjectAtIndex:y withObject:@(fruit)];
            fruit++;
        }
    }
    
    NSLog(@"%ld", (long)foodCount);

    pacman.gameCoordinates = pacmanCoords;
    monster.gameCoordinates = monsterCoords;
    
}


- (void)updateGameState:(NSNotification *)notification
{
    if (abs(self.pacman.gameCoordinates.x - self.monster.gameCoordinates.x) + abs(self.pacman.gameCoordinates.y - self.monster.gameCoordinates.y) == 1) {
        self.gameState = GAME_OVER;
        GameOverView *customAlertView = [[GameOverView alloc] initWithTitle:@"GAME OVER"
                                                                    message:[NSString stringWithFormat:@"YOU LOSE WITH SCORE %d", gameScore]
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
        [customAlertView show];
        sharedInstance = nil;
    } else if ([[notification name] isEqualToString:@"Pacman's coordinates were changed"]) {
        int item = [self.labirint[self.pacman.gameCoordinates.x][self.pacman.gameCoordinates.y] integerValue];
        if ((item != NOTHING) && (item != PACMAN) && (item != MONSTER)) {
            self.foodCount--;
            if (item >= CHERRY) {
                gameScore += POINTS_FOR_FRUIT;
                [(UIImageView*)[self.view viewWithTag:item] setHighlighted:YES];
            } else {
                gameScore += POINTS_FOR_FOOD;
            }
            scoreLabel.text = [NSString stringWithFormat:@"%d/%d", gameScore, TOTAL_SCORE];
            [self.labirint[self.pacman.gameCoordinates.x] replaceObjectAtIndex:self.pacman.gameCoordinates.y withObject:@(NOTHING)];
            if (self.foodCount == 0) {
                self.gameState = GAME_OVER;
                GameOverView *customAlertView = [[GameOverView alloc] initWithTitle:@"GAME OVER"
                                                                            message:@"CONGRATULATION! YOU WIN!"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                [customAlertView show];
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"]) {
        exit(1);
    }
}


- (IBAction)swipeDetected:(UISwipeGestureRecognizer *)sender {
    NSInteger newDirection;
    
    switch (sender.direction) {
        case UISwipeGestureRecognizerDirectionUp: newDirection = UP;
            break;
            
        case UISwipeGestureRecognizerDirectionLeft: newDirection = LEFT;
            break;
            
        case UISwipeGestureRecognizerDirectionRight: newDirection = RIGHT;
            break;
            
        case UISwipeGestureRecognizerDirectionDown: newDirection = DOWN;
            break;
            
            
    }
    
    if (pacman.collision) {
        pacman.moveDirection = newDirection;
        pacman.collision = NO;
    } else {
        pacman.waitedDirection = newDirection;
    }
}


- (void)registerSwipeRecognizers
{
    UISwipeGestureRecognizer *swipeRRecognizer =
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(swipeDetected:)];
    swipeRRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRRecognizer];
    
    UISwipeGestureRecognizer *swipeLRecognizer =
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(swipeDetected:)];
    swipeLRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLRecognizer];
    
    UISwipeGestureRecognizer *swipeURecognizer =
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(swipeDetected:)];
    swipeURecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeURecognizer];
    
    UISwipeGestureRecognizer *swipeDRecognizer =
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(swipeDetected:)];
    swipeDRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDRecognizer];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
