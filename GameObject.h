//
//  GameObject.h
//  Pacman
//
//  Created by Администратор on 2/14/13.
//  Copyright (c) 2013 Olesya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameObject : NSObject

typedef struct
{
    int x;
    int y;
} Coords;

@property (nonatomic) Coords gameCoordinates; //координаты объекта в матрице игры
@property (nonatomic) CGPoint currentOffset; //накапливаемое смещение от текущих игровых координат
@property (nonatomic) NSInteger moveDirection; //текущее направление движение
@property (nonatomic) NSInteger moveSpeed; //скорость движения

- (void)updateGameState:(CGFloat)dt;
- (void)updateCurrentOffset:(CGFloat)dt;

@end
