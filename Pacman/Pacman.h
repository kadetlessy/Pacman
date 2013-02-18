//
//  Pacman.h
//  Pacman
//
//  Created by Администратор on 2/17/13.
//  Copyright (c) 2013 Olesya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"

@interface Pacman : GameObject

@property NSInteger waitedDirection; //"заказанное" пользователем направление движения, устанавливается, как только это возможно без порождения коллизий
@property (nonatomic, strong) NSMutableArray *availableDirections; //возможные направления движения из текущего положения
@property (nonatomic) BOOL collision; //yes - стопор перед стеной лабиринта

- (void)updateCurrentOffset:(CGFloat)dt;

@end
