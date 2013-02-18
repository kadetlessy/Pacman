//
//  OpenGLView.m
//  Pacman
//
//  Created by Администратор on 2/11/13.
//  Copyright (c) 2013 Olesya. All rights reserved.
//

#import "OpenGLView.h"
#import "CC3GLMatrix.h"
#import "GameManager.h"

@implementation OpenGLView

typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
} Vertex;

const Vertex Vertices[] = {
    {{LABIRINT_CELL_SIZE, LABIRINT_CELL_SIZE, 0}, {1, 0, 0, 1}, {1, 1}},
    {{LABIRINT_CELL_SIZE, 0, 0}, {0, 1, 0, 1}, {1, 0}},
    {{0, 0, 0}, {0, 0, 1, 1}, {0, 0}},
    {{0, LABIRINT_CELL_SIZE, 0}, {0, 0, 0, 1}, {0, 1}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self setupVBOs];
        
        _forestTexture = [self setupTexture:@"forest.png"];
        _pointTexture = [self setupTexture:@"point.png"];
        _emptyTexture = [self setupTexture:@"Default.png"];
        
        GLuint pacmanTextureLeft, pacmanTextureRight, pacmanTextureUp, pacmanTextureDown, pacmanTextureFull;
        pacmanTextureLeft = [self setupTexture:@"pacmanLeft.png"];
        pacmanTextureRight = [self setupTexture:@"pacmanRight.png"];
        pacmanTextureUp = [self setupTexture:@"pacmanUp.png"];
        pacmanTextureDown = [self setupTexture:@"pacmanDown.png"];
        pacmanTextureFull = [self setupTexture:@"pacmanFull.png"];
        _pacmanTextures = [[NSArray alloc] initWithObjects:@(pacmanTextureUp), @(pacmanTextureLeft), @(pacmanTextureRight), @(pacmanTextureDown), @(pacmanTextureFull), nil];
        
        GLuint monsterTextureLeft, monsterTextureRight, monsterTextureUp, monsterTextureDown;
        monsterTextureLeft = [self setupTexture:@"monsterLeft.png"];
        monsterTextureRight = [self setupTexture:@"monsterRight.png"];
        monsterTextureUp = [self setupTexture:@"monsterUp.png"];
        monsterTextureDown = [self setupTexture:@"monsterDown.png"];
        _monsterTextures = [[NSArray alloc] initWithObjects:@(monsterTextureUp), @(monsterTextureLeft), @(monsterTextureRight), @(monsterTextureDown), nil];
        
        _cherryTexture = [self setupTexture:@"cherry.png"];
        _appleTexture = [self setupTexture:@"apple.png"];
        _pearTexture = [self setupTexture:@"pear.png"];
        _strawberryTexture = [self setupTexture:@"strawberry.png"];
        _gameTextures = [[NSArray alloc] initWithObjects:@(_forestTexture), @(_pointTexture), @(pacmanTextureLeft), @(_emptyTexture), @(_emptyTexture), @(_cherryTexture), @(_appleTexture), @(_pearTexture), @(_strawberryTexture), nil];

        
        [self renderLabirint];
    }
    return self;
}

- (void)renderLabirint
{
    //glClearColor(192/255.0, 192/255.0, 192/255.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);

    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    GameManager* sharedGameManager = [GameManager sharedInstance];
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    
    int j = 0;
    for (NSMutableArray *row in sharedGameManager.labirint) {
        for (int i = 0; i < [row count]; i++) {
            CC3GLMatrix *modelView = [CC3GLMatrix matrix];
            [modelView populateFromTranslation:CC3VectorMake((i + 1) * LABIRINT_CELL_SIZE, (j + 0.5) * LABIRINT_CELL_SIZE, 0)];
            glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);

            glActiveTexture(GL_TEXTURE0);
            if ([[row objectAtIndex:i] isEqualToNumber:@(MONSTER)]) {
                glBindTexture(GL_TEXTURE_2D, [_monsterTextures[2] intValue]);
            } else if ([[row objectAtIndex:i] isEqualToNumber:@(PACMAN)]) {
                glBindTexture(GL_TEXTURE_2D, [_pacmanTextures[1] intValue]);
            } else {
                glBindTexture(GL_TEXTURE_2D, [[_gameTextures objectAtIndex:[[row objectAtIndex:i] integerValue]] integerValue]);
            }
            glUniform1i(_textureUniform, 0);

            glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                           GL_UNSIGNED_BYTE, 0);
        }
        j++;
    }
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    [self setupDisplayLink];

}

- (void)updateObjects:(CADisplayLink*)displayLink
{ 
    GameManager* sharedGameManager = [GameManager sharedInstance];
    if (sharedGameManager.gameState != GAME_OVER) {
        if (!sharedGameManager.pacman.collision) {
            [self renderSpriteInCoords:sharedGameManager.pacman.gameCoordinates WithOffset:sharedGameManager.pacman.currentOffset WithTexture:_emptyTexture];
            GLuint texture = (abs(sharedGameManager.pacman.currentOffset.x + sharedGameManager.pacman.currentOffset.y) >= 10.0) ? [[_pacmanTextures objectAtIndex:4] intValue] : [[_pacmanTextures objectAtIndex:sharedGameManager.pacman.moveDirection] intValue];
            [sharedGameManager.pacman updateGameState:(CACurrentMediaTime() - _timeOfLastUpdate)];
            [self renderSpriteInCoords:sharedGameManager.pacman.gameCoordinates WithOffset:sharedGameManager.pacman.currentOffset WithTexture:texture];
        }
        
        [self renderSpriteInCoords:sharedGameManager.monster.gameCoordinates WithOffset:sharedGameManager.monster.currentOffset WithTexture:_emptyTexture];
        [self renderSpriteInCoords:sharedGameManager.monster.gameCoordinates WithOffset:CGPointMake(0, 0) WithTexture:[[_gameTextures objectAtIndex:[sharedGameManager.labirint[sharedGameManager.monster.gameCoordinates.x][sharedGameManager.monster.gameCoordinates.y] integerValue]] integerValue]];
        [sharedGameManager.monster updateGameState:(CACurrentMediaTime() - _timeOfLastUpdate)];
        [self renderSpriteInCoords:sharedGameManager.monster.gameCoordinates WithOffset:sharedGameManager.monster.currentOffset WithTexture:[[_monsterTextures objectAtIndex:sharedGameManager.monster.moveDirection] intValue]];
        
        [_context presentRenderbuffer:GL_RENDERBUFFER];
        _timeOfLastUpdate = CACurrentMediaTime();
    } 
}


- (void)renderSpriteInCoords:(Coords)coords WithOffset:(CGPoint)offset WithTexture:(GLuint)texture
{
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    [modelView populateFromTranslation:CC3VectorMake((coords.y + 1) * LABIRINT_CELL_SIZE + offset.y, (coords.x + 0.5) * LABIRINT_CELL_SIZE + offset.x, 0)];
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(_textureUniform, 0);
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
}

- (void)setupVBOs {
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
}

- (void)setupDisplayLink {
    _timeOfLastUpdate = CACurrentMediaTime();
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateObjects:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (GLuint)setupTexture:(NSString *)fileName {
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    return texName;
}



+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)compileShaders {
    
    GLuint vertexShader = [self compileShader:@"SimpleVertex"
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment"
                                       withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    glUseProgram(programHandle);
    
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
    _texCoordSlot = glGetAttribLocation(programHandle, "TexCoordIn");
    glEnableVertexAttribArray(_texCoordSlot);
    _textureUniform = glGetUniformLocation(programHandle, "Texture");
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    GLuint shaderHandle = glCreateShader(shaderType);
    
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
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
