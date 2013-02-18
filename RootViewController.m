//
//  RootViewController.m
//  Pacman
//
//  Created by Администратор on 2/18/13.
//  Copyright (c) 2013 Olesya. All rights reserved.
//

#import "RootViewController.h"
#import "GameManager.h"

@interface RootViewController ()

@end

@implementation RootViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startGamePressed:(UIButton *)sender {
    GameManager* sharedGameManager = [GameManager sharedInstance];
    sharedGameManager = [sharedGameManager initWithNibName:@"GameManager" bundle:nil];
	[self presentViewController:sharedGameManager animated:YES completion:nil];
}
@end
