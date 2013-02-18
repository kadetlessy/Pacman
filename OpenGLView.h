//
//  OpenGLView.h
//  Pacman
//
//  Created by Администратор on 2/11/13.
//  Copyright (c) 2013 Olesya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES2/glext.h>


@interface OpenGLView : UIView {
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _modelViewUniform;
    GLuint _texCoordSlot;
    GLuint _textureUniform;
    
    GLuint _forestTexture;
    GLuint _pointTexture;
    GLuint _cherryTexture;
    GLuint _appleTexture;
    GLuint _pearTexture;
    GLuint _strawberryTexture;
    GLuint _emptyTexture;
    NSArray *_monsterTextures;
    NSArray *_pacmanTextures;
    NSArray *_gameTextures;

    NSTimeInterval _timeOfLastUpdate;
}


@end
