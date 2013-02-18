//
//  CustomPacmanLabel.m
//  Pacman
//
//  Created by Администратор on 2/18/13.
//  Copyright (c) 2013 Olesya. All rights reserved.
//

#import "CustomPacmanLabel.h"

@implementation CustomPacmanLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"emulogic" size:self.font.pointSize];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
