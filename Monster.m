//
//  Monster.m
//  Pacman
//
//  Created by Администратор on 2/15/13.
//  Copyright (c) 2013 Olesya. All rights reserved.
//

#import "Monster.h"
#import "GameManager.h"

@implementation Monster

@synthesize moveDirection, currentOffset, gameCoordinates, moveSpeed;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        moveSpeed = MONSTER_SPEED;
    }
    return self;
}

- (void)setGameCoordinates:(Coords)newCoordinates
{
    GameManager *sharedGameManager = [GameManager sharedInstance];
    gameCoordinates = newCoordinates;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"Monster's coordinates were changed"
     object:self];

    NSInteger direction = UNDEFINED;
    NSInteger minDirection;
    double minDist = MAXFLOAT;
    for (int dx = -1; dx < 2; dx++) {
        for (int dy = -1; dy < 2; dy++) {
            if (abs(dx) != abs(dy)) {
                direction++;
                if (moveDirection + direction != 3) { //чтобы монстр не зациклился на двух соседних клетках
                    newCoordinates.x = gameCoordinates.x + dx;
                    newCoordinates.y = gameCoordinates.y + dy;
                    
                    if ((newCoordinates.x >= 0) && (newCoordinates.x < [sharedGameManager.labirint count]) && (newCoordinates.y >= 0) && (newCoordinates.y < [[sharedGameManager.labirint objectAtIndex:gameCoordinates.x] count]) && (![sharedGameManager.labirint[newCoordinates.x][newCoordinates.y] isEqualToNumber:@(WALL)])) {
                        double dist = sqrt([self sqr:(newCoordinates.x - sharedGameManager.pacman.gameCoordinates.x)] +
                                           [self sqr:(newCoordinates.y - sharedGameManager.pacman.gameCoordinates.y)]);
                        if (dist < minDist) {
                            minDist = dist;
                            minDirection = direction;
                        }
                    }
                }
            }
        }
    }
    self.moveDirection = minDirection;
}
- (double)sqr:(double)x
{
    return x * x;
}


@end