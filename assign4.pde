PImage title, gameover, startNormal, startHovered, restartNormal, restartHovered;
PImage groundhogIdle, groundhogLeft, groundhogRight, groundhogDown;
PImage bg, life, cabbage, stone1, stone2, soilEmpty, soldier;
PImage soil0, soil1, soil2, soil3, soil4, soil5;
PImage[][] soils, stones;
final int START_BUTTON_WIDTH = 144, START_BUTTON_HEIGHT = 60, START_BUTTON_X = 248, START_BUTTON_Y = 360;
final int SOIL_COL_COUNT = 8, SOIL_ROW_COUNT = 24, SOIL_SIZE = 80, PLAYER_MAX_HEALTH = 5;
final int GAME_START = 0, GAME_RUN = 1, GAME_OVER = 2, GRASS_HEIGHT = 15;
int gameState = 0, playerCol, playerRow, playerHealth = 2, playerMoveDirection = 0, playerMoveTimer = 0, playerMoveDuration = 15;
int[][] soilHealth;
float[] cabbageX, cabbageY, soldierX, soldierY;
float soldierSpeed = 2f, playerX, playerY;
final float PLAYER_INIT_X = 4 * SOIL_SIZE, PLAYER_INIT_Y = - SOIL_SIZE;
boolean leftState = false, rightState = false, downState = false, demoMode = false;

void assign4setup() {
  bg = loadImage("img/bg.jpg");
  title = loadImage("img/title.jpg");
  gameover = loadImage("img/gameover.jpg");
  startNormal = loadImage("img/startNormal.png");
  startHovered = loadImage("img/startHovered.png");
  restartNormal = loadImage("img/restartNormal.png");
  restartHovered = loadImage("img/restartHovered.png");
  groundhogIdle = loadImage("img/groundhogIdle.png");
  groundhogLeft = loadImage("img/groundhogLeft.png");
  groundhogRight = loadImage("img/groundhogRight.png");
  groundhogDown = loadImage("img/groundhogDown.png");
  life = loadImage("img/life.png");
  soldier = loadImage("img/soldier.png");
  cabbage = loadImage("img/cabbage.png");
  stone1 = loadImage("img/stone1.png");
  stone2 = loadImage("img/stone2.png");
  soilEmpty = loadImage("img/soils/soilEmpty.png");
  soil0 = loadImage("img/soil0.png");
  soil1 = loadImage("img/soil1.png");
  soil2 = loadImage("img/soil2.png");
  soil3 = loadImage("img/soil3.png");
  soil4 = loadImage("img/soil4.png");
  soil5 = loadImage("img/soil5.png");
  soils = new PImage[6][5];
  for (int i = 0; i < soils.length; i++) {
    for (int j = 0; j < soils[i].length; j++) {
      soils[i][j] = loadImage("img/soils/soil" + i + "/soil" + i + "_" + j + ".png");
    }
  }
  stones = new PImage[2][5];
  for (int i = 0; i < stones.length; i++) {
    for (int j = 0; j < stones[i].length; j++) {
      stones[i][j] = loadImage("img/stones/stone" + i + "/stone" + i + "_" + j + ".png");
    }
  }
  init();
}

void GAME_START() {
  image(title, 0, 0);
  if (START_BUTTON_X + START_BUTTON_WIDTH > mouseX
    && START_BUTTON_X < mouseX
    && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
    && START_BUTTON_Y < mouseY) {
    image(startHovered, START_BUTTON_X, START_BUTTON_Y);
    if (mousePressed) {
      gameState = GAME_RUN;
      mousePressed = false;
    }
  } else {
    image(startNormal, START_BUTTON_X, START_BUTTON_Y);
  }
}

void GAME_RUN() {
  image(bg, 0, 0);
  stroke(255, 255, 0);
  strokeWeight(5);
  fill(253, 184, 19);
  ellipse(590, 50, 120, 120);
  pushMatrix();
  translate(0, max(SOIL_SIZE * -18, SOIL_SIZE * 1 - playerY));
  fill(124, 204, 25);
  noStroke();
  rect(0, -GRASS_HEIGHT, width, GRASS_HEIGHT);
  for (int i = 0; i < soilHealth.length; i++) {
    for (int j = 0; j < soilHealth[i].length; j++) {
      int areaIndex = floor(j / 4);
      if (soilHealth[i][j]>0)image(soils[areaIndex][int((constrain(soilHealth[i][j], 0, 15)-1)/3)], i * SOIL_SIZE, j * SOIL_SIZE);
      if (soilHealth[i][j]>15) {
        image(stones[0][int((constrain(soilHealth[i][j], 0, 30)-16)/3)], i * SOIL_SIZE, j * SOIL_SIZE);
      }          
      if (soilHealth[i][j]>30) {
        image(stones[1][int((soilHealth[i][j]-31)/3)], i * SOIL_SIZE, j * SOIL_SIZE);
      }
      if (soilHealth[i][j]<=0) {
        image(soilEmpty, i * SOIL_SIZE, j * SOIL_SIZE);
      }
    }
  }
  for (int i=0; i<6; i++) {
    image(cabbage, cabbageX[i], cabbageY[i]);
    if (playerX<cabbageX[i]+80&&playerX+80>cabbageX[i]&&playerY+80>cabbageY[i]&&playerY<cabbageY[i]+80 && playerHealth<5) {
      cabbageX[i]=-1000;
      playerHealth++;
    }
  }
  PImage groundhogDisplay = groundhogIdle;
  if (playerMoveTimer == 0) {
    if (playerRow<23&&soilHealth[playerCol][playerRow+1]<=0) {
      playerMoveDirection = DOWN;
      playerMoveTimer = playerMoveDuration;
    }
    if (leftState) {
      groundhogDisplay = groundhogLeft;
      if (playerCol > 0) {
        if (playerRow>=0&&soilHealth[playerCol-1][playerRow]>0) {
          soilHealth[playerCol-1][playerRow]--;
        } else {
          playerMoveDirection = LEFT;
          playerMoveTimer = playerMoveDuration;
        }
      }
    } else if (rightState) {
      groundhogDisplay = groundhogRight;
      if (playerCol < SOIL_COL_COUNT - 1) {
        if (playerRow>=0&&soilHealth[playerCol+1][playerRow]>0) {
          soilHealth[playerCol+1][playerRow]--;
        } else {
          playerMoveDirection = RIGHT;
          playerMoveTimer = playerMoveDuration;
        }
      }
    } else if (downState) {
      groundhogDisplay = groundhogDown;
      if (playerRow < SOIL_ROW_COUNT - 1) {    
        soilHealth[playerCol][playerRow+1]--;
      }
    }
  }
  if (playerMoveTimer > 0) {
    playerMoveTimer --;
    switch(playerMoveDirection) {
    case LEFT:
      groundhogDisplay = groundhogLeft;
      if (playerMoveTimer == 0) {
        playerCol--;
        playerX = SOIL_SIZE * playerCol;
      } else {
        playerX = (float(playerMoveTimer) / playerMoveDuration + playerCol - 1) * SOIL_SIZE;
      }
      break;
    case RIGHT:
      groundhogDisplay = groundhogRight;
      if (playerMoveTimer == 0) {
        playerCol++;
        playerX = SOIL_SIZE * playerCol;
      } else {
        playerX = (1f - float(playerMoveTimer) / playerMoveDuration + playerCol) * SOIL_SIZE;
      }
      break;
    case DOWN:
      groundhogDisplay = groundhogDown;
      if (playerMoveTimer == 0) {
        playerRow++;
        playerY = SOIL_SIZE * playerRow;
      } else {
        playerY = (1f - float(playerMoveTimer) / playerMoveDuration + playerRow) * SOIL_SIZE;
      }
      break;
    }
  }
  image(groundhogDisplay, playerX, playerY);
  for (int i=0; i<6; i++) {
    soldierX[i]+=soldierSpeed;
    if (soldierX[i]>width) {
      soldierX[i]=-80;
    }
    image(soldier, soldierX[i], soldierY[i]);
    if (playerX<soldierX[i]+soldier.width&&playerX+groundhogIdle.width>soldierX[i]&&playerY+groundhogDown.height>soldierY[i]&&playerY<soldierY[i]+soldier.height) {      
      playerX = PLAYER_INIT_X;
      playerY = PLAYER_INIT_Y;
      playerCol = (int) (playerX / 80);
      playerRow = (int) (playerY / 80);
      playerMoveTimer = 0;
      playerHealth--;    
      soilHealth[4][0]=15;
    }
  }
  if (demoMode) {  
    fill(255);
    textSize(26);
    textAlign(LEFT, TOP);
    for (int i = 0; i < soilHealth.length; i++) {
      for (int j = 0; j < soilHealth[i].length; j++) {
        text(soilHealth[i][j], i * SOIL_SIZE, j * SOIL_SIZE);
      }
    }
  }
  popMatrix();
  if (playerHealth <= 5) {
    for (int i = 0; i<playerHealth; i++) {
      int x = 10+i*70;
      int y = 10;
      image(life, x, y);
    }
  }
  if (playerHealth <= 0) {
    gameState = GAME_OVER;
  }
}

void GAME_OVER() {
  image(gameover, 0, 0);
  if (START_BUTTON_X + START_BUTTON_WIDTH > mouseX
    && START_BUTTON_X < mouseX
    && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
    && START_BUTTON_Y < mouseY) {
    image(restartHovered, START_BUTTON_X, START_BUTTON_Y);
    if (mousePressed) {
      gameState = GAME_RUN;
      mousePressed = false;
      init();
    }
  } else {
    image(restartNormal, START_BUTTON_X, START_BUTTON_Y);
  }
}

void init() {
  playerX = PLAYER_INIT_X;
  playerY = PLAYER_INIT_Y;
  playerCol = (int) (playerX / SOIL_SIZE);
  playerRow = (int) (playerY / SOIL_SIZE);
  playerMoveTimer = 0;
  playerHealth = 2;
  soilHealth = new int[SOIL_COL_COUNT][SOIL_ROW_COUNT];
  for (int i = 0; i < soilHealth.length; i++) {
    for (int j = 0; j < soilHealth[i].length; j++) {
      soilHealth[i][j] = 15;
      int X = i;
      int Y = X;
      soilHealth[X][Y] = 30;
    }
  }
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j<4; j++) {
      int X = 6+i-j*4;
      int Y = 8+i;
      if (0<=X && X<8) {
        soilHealth[X][Y] = 30;
      }
      int X2 = -i+1+4*j;
      int Y2 = 8+i;
      if (0<=X2 && X2<8) {
        soilHealth[X2][Y2] = 30;
      }
    }
  }
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j<16; j++) {
      if (j %3 ==1) {
        int X = -i+j;
        int Y = 16+i;
        if (0<=X && X<8) {
          soilHealth[X][Y] = 30;
        }
      }
      if (j %3 ==2) {
        int X = -i+j;
        int Y = 16+i;
        if (0<=X && X<8) {
          soilHealth[X][Y] = 45;
        }
      }
    }
  }
  for (int i = 1; i < 24; i ++) { 
    int count = (int)random(2)+1;
    int lastX= -1;
    int Y = i;
    for (int j = 0; j < count; j++) {
      int X = (int)random(8);
      if (lastX == X) {
        j--;
      } else {
        soilHealth[X][Y] = 0;
        lastX = X;
      }
    }
  }
  soldierX = new float[6] ;
  soldierY = new float[6] ;
  for (int i = 0; i<soldierX.length; i++) {
    soldierX[i] = random(8)*SOIL_SIZE;
    soldierY[i] = (int)random(4)*SOIL_SIZE+SOIL_SIZE*i*4;
  }
  cabbageX = new float[6] ;
  cabbageY = new float[6] ;
  for (int i = 0; i<cabbageX.length; i++) {
    cabbageX[i] = (int)random(8)*SOIL_SIZE;
    cabbageY[i] = (int)random(4)*SOIL_SIZE+SOIL_SIZE*i*4;
  }
}

void keyPressed() {
  if (key==CODED) {
    switch(keyCode) {
    case LEFT:
      leftState = true;
      break;
    case RIGHT:
      rightState = true;
      break;
    case DOWN:
      downState = true;
      break;
    }
  } else {
    if (key=='b') {
      demoMode = !demoMode;
    }
  }
}

void keyReleased() {
  if (key==CODED) {
    switch(keyCode) {
    case LEFT:
      leftState = false;
      break;
    case RIGHT:
      rightState = false;
      break;
    case DOWN:
      downState = false;
      break;
    }
  }
}

void setup() {
  size(640, 480, P2D);
  assign4setup();
}

void draw() {
  switch (gameState) {
  case GAME_START:
    GAME_START();
    break;
  case GAME_RUN:
    GAME_RUN();
    break;
  case GAME_OVER:
    GAME_OVER();   
    break;
  }
}
