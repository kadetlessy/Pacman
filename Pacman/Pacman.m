//
//  Pacman.m
//  Pacman
//
//  Created by Администратор on 2/17/13.
//  Copyright (c) 2013 Olesya. All rights reserved.
//

#import "Pacman.h"
#import "GameManager.h"

@implementation Pacman

@synthesize availableDirections, waitedDirection, moveDirection, gameCoordinates, collision, moveSpeed;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        moveDirection = UNDEFINED;
        waitedDirection = UNDEFINED;
        availableDirections = [[NSMutableArray alloc] init];
        collision = YES;
        moveSpeed = PACMAN_SPEED;
    }
    return self;
}

- (void)updateCurrentOffset:(CGFloat)dt
{
    if ([availableDirections containsObject:@(moveDirection)]) {
        [super updateCurrentOffset:dt];
    } else {
        collision = YES;
    }
}

- (void)setGameCoordinates:(Coords)newCoordinates
{
    GameManager *sharedGameManager = [GameManager sharedInstance];
    gameCoordinates = newCoordinates;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"Pacman's coordinates were changed"
     object:self];
    
    [availableDirections removeAllObjects];
    NSInteger direction = UNDEFINED;
    for (int dx = -1; dx < 2; dx++) {
        for (int dy = -1; dy < 2; dy++) {
            if (abs(dx) != abs(dy)) {
                direction++;
                newCoordinates.x = gameCoordinates.x + dx;
                newCoordinates.y = gameCoordinates.y + dy;
                if ((newCoordinates.x >= 0) && (newCoordinates.x < [sharedGameManager.labirint count]) && (newCoordinates.y >= 0) && (newCoordinates.y < [[sharedGameManager.labirint objectAtIndex:gameCoordinates.x] count]) && (![sharedGameManager.labirint[newCoordinates.x][newCoordinates.y] isEqualToNumber:@(WALL)])) {
                    [availableDirections addObject:@(direction)];
                }
            }
        }
    }

    if ([availableDirections containsObject:@(waitedDirection)]) {
        moveDirection = waitedDirection;
        waitedDirection = UNDEFINED;
    }
}


@end
