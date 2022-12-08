
// Variables
int state;
int gridSizeX = 121;
int gridSizeY = 61;
Cell[][] grid;
int nWalls = int(max(gridSizeX, gridSizeY) / 4);
ArrayList<Cell> scoreList;
Cell path;

///////////////////////////

// Setup everything
void setup() {

  // Size of 1280x640
  size(1280, 640);

  // Make the frame rate the same as the grid size
  frameRate(max(gridSizeX, gridSizeY));

  // Change the title of the window
  surface.setTitle("Dimension code #1 : Maze generator and solver");

  // Set the colors to be on the color wheel
  colorMode(HSB, 360, 255, 255);

  // Setup the grid
  setupGrid();
}

// Setup the grid
void setupGrid() {

  // Setup the grid and the score list
  grid = new Cell[gridSizeX][gridSizeY];
  scoreList = new ArrayList<Cell>();
  for (int i = 0; i < grid.length; i++) {
    for (int j = 0; j < grid[i].length; j++) {

      // A new cell with a position and a size based on the width/height and the grid size
      grid[i][j] = new Cell(new PVector(i, j), width / float(gridSizeX), height / float(gridSizeY));
    }
  }

  // Open the start cell and end cell and set the same color and id
  grid[0][1].c = grid[1][1].c;
  grid[0][1].id = grid[1][1].id;
  grid[gridSizeX - 1][gridSizeY - 2].c = grid[gridSizeX - 2][gridSizeY - 2].c;
  grid[gridSizeX - 1][gridSizeY - 2].id = grid[gridSizeX - 2][gridSizeY - 2].id;
  state = 0;
}

// Draw everything
void draw() {

  // Draw the grid
  for (int i = 0; i < grid.length; i++) {
    for (int j = 0; j < grid[i].length; j++) {
      grid[i][j].show();
    }
  }

  // First state
  if (state == 0) {

    // Delete the walls until everything is the same color
    deleteWall();
    checkIds();
  }

  // Second state
  else if (state == 1) {

    // Make everything white, break some walls to make the maze more complex
    colorWhite();
    breakWalls(nWalls);

    // Update the score of the end cell to be 0 and add it to the score list
    grid[gridSizeX - 1][gridSizeY - 2].score = 0;
    scoreList.add(grid[gridSizeX - 1][gridSizeY - 2]);

    // Go to the third state
    state = 2;
  }

  // Third state
  else if (state == 2) {

    // Calculate the score list and update it
    scoreList = calculateScore();

    // If the score list is empty
    if (scoreList.size() == 0) {

      // Start the path at the start cell and go to the fourth state
      path = grid[0][1];
      state = 3;
    }
  }

  // Fourth state
  else if (state == 3) {

    // Find the path of less score
    findPath();
  }
}

// Delete the walls
void deleteWall() {
  while (true) {

    // Take a random cell
    int x = int(random(1, gridSizeX - 1));
    int y = int(random(1, gridSizeY - 1));

    // If it's a wall
    if (grid[x][y].c == 0) {

      // Choose a random offset (horizontal or vertical)
      int offset = int(random(0, 2));

      // If it's a vertical offset
      if (offset == 0) {

        // If it's not the same id on both sides of the walls and neither are walls
        if (grid[x][y - 1].id != grid[x][y + 1].id && grid[x][y - 1].c != 0 && grid[x][y + 1].c != 0) {

          // If there is more cell of the same color on the top
          if (countColor(x, y - 1, 0) > countColor(x, y + 1, 0)) {

            // Change the color and id of the wall to the color and id of the top cell
            grid[x][y].c = grid[x][y - 1].c;
            grid[x][y].id = grid[x][y - 1].id;
          } else {

            // Else change the color and id to the color and id of the bottom cell
            grid[x][y].c = grid[x][y + 1].c;
            grid[x][y].id = grid[x][y + 1].id;
          }

          // Color all remaining cells
          colorEverything(x, y);

          // Exit while loop
          return;
        }
      }

      // Else if the offset is horizontal
      else if (offset == 1) {

        // If it's not the same id on both sides of the walls and neither are walls
        if (grid[x - 1][y].id != grid[x + 1][y].id && grid[x - 1][y].c != 0 && grid[x + 1][y].c != 0) {

          // If there is more cell of the same color on the left
          if (countColor(x - 1, y, 0) > countColor(x + 1, y, 0)) {

            // Change the color and id of the wall to the color and id of the left cell
            grid[x][y].c = grid[x - 1][y].c;
            grid[x][y].id = grid[x - 1][y].id;
          } else {

            // Else change the color and id to the color and id of the right cell
            grid[x][y].c = grid[x + 1][y].c;
            grid[x][y].id = grid[x + 1][y].id;
          }

          // Color all remaining cells
          colorEverything(x, y);

          // Exit while loop
          return;
        }
      }
    }
  }
}

// Count the number of cell of same color starting at x, y recursively
int countColor(int x, int y, int made) {

  // x, y count for one
  int res = 1;

  // If there is a cell of same color on the right
  if (made != 4 && x != gridSizeX - 1 && grid[x + 1][y].c != 0) {

    // Check recursively starting from there and add it to the total
    res += countColor(x + 1, y, 2);
  }

  // If there is a cell of same color on the left
  if (made != 2 && x != 0 && grid[x - 1][y].c != 0) {

    // Check recursively starting from there and add it to the total
    res += countColor(x - 1, y, 4);
  }

  // If there is a cell of same color on the bottom
  if (made != 1 && y != gridSizeY && grid[x][y + 1].c != 0) {

    // Check recursively starting from there and add it to the total
    res += countColor(x, y + 1, 3);
  }

  // If there is a cell of same color on the top
  if (made != 3 && y != 0 && grid[x][y - 1].c != 0) {

    // Check recursively starting from there and add it to the total
    res += countColor(x, y - 1, 1);
  }

  // Return the total
  return res;
}

// Color everything starting at x, y recursively
void colorEverything(int x, int y) {
  color c = grid[x][y].c;
  int id = grid[x][y].id;

  // If the cell on the right is not the same id and not a wall
  if (x != gridSizeX - 1 && grid[x + 1][y].id != id && grid[x + 1][y].c != 0) {

    // Change id and color to be the same as x, y and check from there
    grid[x + 1][y].c = c;
    grid[x + 1][y].id = id;
    colorEverything(x + 1, y);
  }

  // If the cell on the left is not the same id and not a wall
  if (x != 0 && grid[x - 1][y].id != id && grid[x - 1][y].c != 0) {

    // Change id and color to be the same as x, y and check from there
    grid[x - 1][y].c = c;
    grid[x - 1][y].id = id;
    colorEverything(x - 1, y);
  }

  // If the cell on the bottom is not the same id and not a wall
  if (y != gridSizeY - 1 && grid[x][y + 1].id != id && grid[x][y + 1].c != 0) {

    // Change id and color to be the same as x, y and check from there
    grid[x][y + 1].c = c;
    grid[x][y + 1].id = id;
    colorEverything(x, y + 1);
  }

  // If the cell on the top is not the same id and not a wall
  if (y != 0 && grid[x][y - 1].id != id && grid[x][y - 1].c != 0) {

    // Change id and color to be the same as x, y and check from there
    grid[x][y - 1].c = c;
    grid[x][y - 1].id = id;
    colorEverything(x, y - 1);
  }
}

// Check how much id there is
void checkIds() {
  int id = grid[0][1].id;
  for (int i = 0; i < grid.length; i++) {
    for (int j = 0; j < grid[i].length; j++) {

      // If there is a id different from the start cell, exit
      if (grid[i][j].c != 0 && grid[i][j].id != id) {
        return;
      }
    }
  }

  // If everything is the same id, change to the second state and exit
  state = 1;
  return;
}

// Color everything white
void colorWhite() {

  // Color the start white and color everything white starting from there
  grid[0][1].c = color(0, 0, 255);
  grid[0][1].id = -1;
  colorEverything(0, 1);
}

// Break some random walls
void breakWalls(int n) {

  // Break n wall
  while (n > 0) {

    // Choose a random cell
    int x = int(random(1, gridSizeX - 1));
    int y = int(random(1, gridSizeY - 1));

    // If it's a wall
    if (grid[x][y].c == 0) {

      // If the top and the bottom are the same color but not walls
      if (grid[x][y - 1].c == grid[x][y + 1].c && grid[x][y - 1].c != 0 && grid[x][y + 1].c != 0) {

        // Change the wall to white
        grid[x][y].c = color(0, 0, 255);
        n -= 1;
      }

      // Else if the left and the right is the same color but not walls
      else if (grid[x - 1][y].c == grid[x + 1][y].c && grid[x - 1][y].c != 0 && grid[x + 1][y].c != 0) {

        // Change the wall to white
        grid[x][y].c = color(0, 0, 255);
        n -= 1;
      }
    }
  }
}

// Calculate the score of every cell in the score list
ArrayList<Cell> calculateScore() {
  ArrayList<Cell> newScore = new ArrayList<Cell>();

  // For every cell in the score list
  for (int i = 0; i < scoreList.size(); i++) {

    // If there is no cell left, return the new score list
    if (scoreList.get(i) == null) {
      return newScore;
    }

    // If not on the right edge
    if (int(scoreList.get(i).pos.x) < gridSizeX - 1) {

      // Get the right cell
      Cell cell1 = grid[int(scoreList.get(i).pos.x) + 1][int(scoreList.get(i).pos.y)];

      // If it's not a wall and the score is still -1 (not calculated yet)
      if (cell1.c != 0 && cell1.score == -1) {

        // Set the score to this cell to be +1 of the current cell and add it to the new score list
        cell1.score = scoreList.get(i).score + 1;
        newScore.add(cell1);
      }
    }

    // If not on the left edge
    if (int(scoreList.get(i).pos.x) > 0) {

      // Get the left cell
      Cell cell2 = grid[int(scoreList.get(i).pos.x) - 1][int(scoreList.get(i).pos.y)];

      // If it's not a wall and the score is still -1 (not calculated yet)
      if (cell2.c != 0 && cell2.score == -1) {

        // Set the score to this cell to be +1 of the current cell and add it to the new score list
        cell2.score = scoreList.get(i).score + 1;
        newScore.add(cell2);
      }
    }

    // If not on the bottom edge
    if (int(scoreList.get(i).pos.y) < gridSizeY - 1) {

      // Get the bottom cell
      Cell cell3 = grid[int(scoreList.get(i).pos.x)][int(scoreList.get(i).pos.y) + 1];

      // If it's not a wall and the score is still -1 (not calculated yet)
      if (cell3.c != 0 && cell3.score == -1) {

        // Set the score to this cell to be +1 of the current cell and add it to the new score list
        cell3.score = scoreList.get(i).score + 1;
        newScore.add(cell3);
      }
    }

    // If not on the top edge
    if (int(scoreList.get(i).pos.y) > 0) {

      // Get the top cell
      Cell cell4 = grid[int(scoreList.get(i).pos.x)][int(scoreList.get(i).pos.y) - 1];

      // If it's not a wall and the score is still -1 (not calculated yet)
      if (cell4.c != 0 && cell4.score == -1) {

        // Set the score to this cell to be +1 of the current cell and add it to the new score list
        cell4.score = scoreList.get(i).score + 1;
        newScore.add(cell4);
      }
    }
  }

  // Return the new list
  return newScore;
}

// Find the path at the end
void findPath() {

  // Set the current last cell of the path to white
  path.c = color(0, 0, 255);
  Cell newPath = path;

  // If not on the right edge
  if (int(path.pos.x) < gridSizeX - 1) {

    // Get the right cell
    Cell cell1 = grid[int(path.pos.x) + 1][int(path.pos.y)];

    // If this cell is not a wall and the score is lower than the current score (so the cell is closer to the end)
    if (cell1.score != -1 && cell1.score < path.score) {

      // Then the new cell is this one
      newPath = cell1;
    }
  }

  // If not on the left edge
  if (int(path.pos.x) > 0) {

    // Get the left cell
    Cell cell2 = grid[int(path.pos.x) - 1][int(path.pos.y)];

    // If this cell is not a wall and the score is lower than the current score (so the cell is closer to the end)
    if (cell2.score != -1 && cell2.score < path.score) {

      // Then the new cell is this one
      newPath = cell2;
    }
  }

  // If not on the bottom edge
  if (int(path.pos.y) < gridSizeY - 1) {

    // Get the bottom cell
    Cell cell3 = grid[int(path.pos.x)][int(path.pos.y) + 1];

    // If this cell is not a wall and the score is lower than the current score (so the cell is closer to the end)
    if (cell3.score != -1 && cell3.score < path.score) {

      // Then the new cell is this one
      newPath = cell3;
    }
  }

  // If not on the top edge
  if (int(path.pos.y) > 0) {

    // Get the top cell
    Cell cell4 = grid[int(path.pos.x)][int(path.pos.y) - 1];

    // If this cell is not a wall and the score is lower than the current score (so the cell is closer to the end)
    if (cell4.score != -1 && cell4.score < path.score) {

      // Then the new cell is this one
      newPath = cell4;
    }
  }

  // Set the path cell score to -1 (like a wall but means visited)
  path.score = -1;

  // If the current and new path are different
  if (path != newPath) {

    // Set the new path to be the current path
    path = newPath;
  }

  // Else set the state to be the final state (arrived at the end of the path)
  else {
    state = 4;
  }
}

// Detect when a key is released
void keyReleased() {

  // If R is pressed
  if (key == 'r' || key == 'R') {

    // Then resetup the grid back
    setupGrid();
  }
}
