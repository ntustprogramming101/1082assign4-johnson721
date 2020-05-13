PImage title, gameover, startNormal, startHovered, restartNormal, restartHovered;
PImage groundhogIdle, groundhogLeft, groundhogRight, groundhogDown;
PImage bg, life, cabbage, stone1, stone2, soilEmpty, soldier;
PImage soil0, soil1, soil2, soil3, soil4, soil5;
PImage[][] soils, stones;
final int START_BUTTON_WIDTH = 144, START_BUTTON_HEIGHT = 60, START_BUTTON_X = 248, START_BUTTON_Y = 360;
final int SOIL_COL_COUNT = 8, SOIL_ROW_COUNT = 24, SOIL_SIZE = 80, PLAYER_MAX_HEALTH = 5;
final int GAME_START = 0, GAME_RUN = 1, GAME_OVER = 2, GRASS_HEIGHT = 15, BLOCK=80;
int gameState = 0, playerCol, playerRow, playerHealth = 2, playerMoveDirection = 0, playerMoveTimer = 0, playerMoveDuration = 15;
int[][] soilHealth;
float[] cabbageX, cabbageY, soldierX, soldierY;
float soldierSpeed = 2f, playerX, playerY;
final float PLAYER_INIT_X = 4 * SOIL_SIZE, PLAYER_INIT_Y = - SOIL_SIZE;
boolean leftState = false, rightState = false, downState = false, demoMode = false;
void setup() {
  size(640, 480, P2D);
  assign4setup();
}
void draw() {
  switch (gameState) {
  case GAME_START:// Start Screen
    GAME_START();
    break;
  case GAME_RUN:// In-Game
    GAME_RUN();
    break;
  case GAME_OVER:// Gameover Screen
    GAME_OVER();   
    break;
  }
}
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
  // Load soil images used in assign3 if you don't plan to finish requirement #6
  soil0 = loadImage("img/soil0.png");
  soil1 = loadImage("img/soil1.png");
  soil2 = loadImage("img/soil2.png");
  soil3 = loadImage("img/soil3.png");
  soil4 = loadImage("img/soil4.png");
  soil5 = loadImage("img/soil5.png");
  // Load PImage[][] soils
  soils = new PImage[6][5];
  for (int i = 0; i < soils.length; i++) {
    for (int j = 0; j < soils[i].length; j++) {
      soils[i][j] = loadImage("img/soils/soil" + i + "/soil" + i + "_" + j + ".png");
    }
  }
  // Load PImage[][] stones
  stones = new PImage[2][5];
  for (int i = 0; i < stones.length; i++) {
    for (int j = 0; j < stones[i].length; j++) {
      stones[i][j] = loadImage("img/stones/stone" + i + "/stone" + i + "_" + j + ".png");
    }
  }
  rassign4();
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
  // Background
  image(bg, 0, 0);
  // Sun
  stroke(255, 255, 0);
  strokeWeight(5);
  fill(253, 184, 19);
  ellipse(590, 50, 120, 120);
  // CAREFUL!
  // Because of how this translate value is calculated, the Y value of the ground level is actually 0
  pushMatrix();
  translate(0, max(SOIL_SIZE * -18, SOIL_SIZE * 1 - playerY));
  // Ground
  fill(124, 204, 25);
  noStroke();
  rect(0, -GRASS_HEIGHT, width, GRASS_HEIGHT);
  for (int i = 0; i < soilHealth.length; i++) {
    for (int j = 0; j < soilHealth[i].length; j++) {
      // Change this part to show soil and stone images based on soilHealth value
      // NOTE: To avoid errors on webpage, you can either use floor(j / 4) or (int)(j / 4) to make sure it's an integer.
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
  // Cabbages
  // > Remember to check if playerHealth is smaller than PLAYER_MAX_HEALTH!
  for (int i=0; i<6; i++) {
    image(cabbage, cabbageX[i], cabbageY[i]);
    if (playerX<cabbageX[i]+80&&playerX+80>cabbageX[i]&&playerY+80>cabbageY[i]&&playerY<cabbageY[i]+80 && playerHealth<5) {
      cabbageX[i]=-1000;
      playerHealth++;
    }
  }
  // Groundhog
  PImage groundhogDisplay = groundhogIdle;
  // If player is not moving, we have to decide what player has to do next
  if (playerMoveTimer == 0) {
    // HINT:
    // You can use playerCol and playerRow to get which soil player is currently on
    // Check if "player is NOT at the bottom AND the soil under the player is empty"
    // > If so, then force moving down by setting playerMoveDirection and playerMoveTimer (see downState part below for example)
    // > Else then determine player's action based on input state
    if (playerRow<23&&soilHealth[playerCol][playerRow+1]<=0) {
      playerMoveDirection = DOWN;
      playerMoveTimer = playerMoveDuration;
    }
    if (leftState) {
      groundhogDisplay = groundhogLeft;
      // Check left boundary
      if (playerCol > 0) {
        // HINT:
        // Check if "player is NOT above the ground AND there's soil on the left"
        // > If so, dig it and decrease its health
        // > Else then start moving (set playerMoveDirection and playerMoveTimer)
        if (playerRow>=0&&soilHealth[playerCol-1][playerRow]>0) {
          soilHealth[playerCol-1][playerRow]--;
        } else {
          playerMoveDirection = LEFT;
          playerMoveTimer = playerMoveDuration;
        }
      }
    } else if (rightState) {
      groundhogDisplay = groundhogRight;
      // Check right boundary
      if (playerCol < SOIL_COL_COUNT - 1) {
        // HINT:
        // Check if "player is NOT above the ground AND there's soil on the right"
        // > If so, dig it and decrease its health
        // > Else then start moving (set playerMoveDirection and playerMoveTimer)
        if (playerRow>=0&&soilHealth[playerCol+1][playerRow]>0) {
          soilHealth[playerCol+1][playerRow]--;
        } else {
          playerMoveDirection = RIGHT;
          playerMoveTimer = playerMoveDuration;
        }
      }
    } else if (downState) {
      groundhogDisplay = groundhogDown;
      // Check bottom boundary
      // HINT:
      // We have already checked "player is NOT at the bottom AND the soil under the player is empty",
      // and since we can only get here when the above statement is false,
      // we only have to check again if "player is NOT at the bottom" to make sure there won't be out-of-bound exception
      if (playerRow < SOIL_ROW_COUNT - 1) {    
        // > If so, dig it and decrease its health
        // For requirement #3:
        // Note that player never needs to move down as it will always fall automatically,
        // so the following 2 lines can be removed once you finish requirement #3
        soilHealth[playerCol][playerRow+1]--;
      }
    }
  }
  // If player is now moving?
  // (Separated if-else so player can actually move as soon as an action starts)
  // (I don't think you have to change any of these)
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
  // Soldiers
  // > Remember to stop player's moving! (reset playerMoveTimer)
  // > Remember to recalculate playerCol/playerRow when you reset playerX/playerY!
  // > Remember to reset the soil under player's original position!
  // Demo mode: Show the value of soilHealth on each soil
  // (DO NOT CHANGE THE CODE HERE!)
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
  // Health UI
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
      rassign4();
    }
  } else {
    image(restartNormal, START_BUTTON_X, START_BUTTON_Y);
  }
}
void rassign4() {
  // Initialize player
  playerX = PLAYER_INIT_X;
  playerY = PLAYER_INIT_Y;
  playerCol = (int) (playerX / SOIL_SIZE);
  playerRow = (int) (playerY / SOIL_SIZE);
  playerMoveTimer = 0;
  playerHealth = 2;
  // Initialize soilHealth
  soilHealth = new int[SOIL_COL_COUNT][SOIL_ROW_COUNT];
  for (int i = 0; i < soilHealth.length; i++) {
    for (int j = 0; j < soilHealth[i].length; j++) {
      // 0: no soil, 15: soil only, 30: 1 stone, 45: 2 stones
      soilHealth[i][j] = 15;
      //1-8;
      int X = i;
      int Y = X;
      soilHealth[X][Y] = 30;
    }
  }
  //9-16
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
  //17-24
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
  //no soil
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
  // Initialize soidiers and their position
  soldierX = new float[6] ;
  soldierY = new float[6] ;
  for (int i = 0; i<soldierX.length; i++) {
    soldierX[i] = random(8)*SOIL_SIZE;
    soldierY[i] = (int)random(4)*SOIL_SIZE+SOIL_SIZE*i*BLOCK;
  }
  // Initialize cabbages and their position
  cabbageX = new float[6] ;
  cabbageY = new float[6] ;
  for (int i = 0; i<cabbageX.length; i++) {
    cabbageX[i] = (int)random(8)*SOIL_SIZE;
    cabbageY[i] = (int)random(4)*SOIL_SIZE+SOIL_SIZE*i*BLOCK;
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
      // Press B to toggle demo mode
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
