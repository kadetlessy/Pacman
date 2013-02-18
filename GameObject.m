//
//  GameObject.m
//  Pacman
//
//  Created by Администратор on 2/14/13.
//  Copyright (c) 2013 Olesya. All rights reserved.
//

#import "GameObject.h"
#import "GameManager.h"

@implementation GameObject

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.currentOffset = CGPointMake(0, 0);
    }
    return self;
}

- (void)updateCurrentOffset:(CGFloat)dt
{
    CGPoint newOffset = self.currentOffset;
    switch (self.moveDirection) {
        case LEFT: newOffset.y -= dt;
            break;
            
        case RIGHT: newOffset.y += dt;
            break;
            
        case UP: newOffset.x -= dt;
            break;
            
        case DOWN: newOffset.x += dt;
            break;
            
    }
    
    self.currentOffset = newOffset;
}

- (void)updateGameState:(CGFloat)dt
{
    [self updateCurrentOffset:dt * self.moveSpeed];
    if (LABIRINT_CELL_SIZE - (abs(self.currentOffset.x + self.currentOffset.y)) < 1E-1) {
        
        Coords new;

        new.x = self.gameCoordinates.x + (int)self.currentOffset.x/LABIRINT_CELL_SIZE;
        new.y = self.gameCoordinates.y + (int)self.currentOffset.y/LABIRINT_CELL_SIZE;
        self.gameCoordinates = new;
        
        self.currentOffset = CGPointMake(0, 0);

    }
}


@end
