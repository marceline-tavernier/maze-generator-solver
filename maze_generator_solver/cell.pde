
// The cell class
class Cell {

  // Each cell has a position, size, color, score and id
  PVector pos = new PVector(0, 0);
  float sizeX = 1, sizeY = 1;
  color c = 0;
  int score = -1;
  int id = -1;

  // Initialise each parameter with a given position and size
  Cell(PVector position, float sX, float sY) {
    sizeX = sX;
    sizeY = sY;
    pos = position;

    // Set unique id
    id = int(position.x + position.y * sizeX * width);

    // If on a even position, it's a wall so color it black
    if (pos.x % 2 == 0 || pos.y % 2 == 0) {
      c = 0;
    }

    // Else color it randomly set
    else {
      c = color(int(random(0, 360)), int(random(0, 255)), 255);
    }
  }

  // Draw the cell
  void show() {

    // If the score is not calculated yet, use the color
    if (score == -1) {
      fill(c);
      stroke(c);
    }

    // Else use the score to display the color
    else {
      fill(score % 360, 255, 255);
      stroke(score % 360, 255, 255);
    }

    // Draw a rectangle for the cell
    rect(pos.x * sizeX, pos.y * sizeY, sizeX, sizeY);
  }
}
