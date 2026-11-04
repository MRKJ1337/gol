#include <stdlib.h>
#include <stdio.h>
#include "Engine.cuh"

Grid::Grid(int lines, int columns) {
  this->lines = lines;
  this->columns = columns;
  this->array = std::vector<Cell>(lines * columns);
}

Grid::Grid(int lines, int columns, std::vector<Cell> &array) {
  this->lines = lines;
  this->columns = columns;
  this->array = std::vector<Cell>(array);
}

Grid::~Grid() {
}

Grid Grid::clone() {
  Grid grid(this->lines, this->columns, this->array);
  return grid;
}

void Grid::setCell(int x, int y, Cell c) {
  setCell1D(this->convert2Dto1D(x, y), c);
}

void Grid::setCell1D(int index, Cell c) {
  if((0 <= index) && (index < this->lines * this->columns)) {
    this->array[index] = c;
  }
}

int Grid::convert2Dto1D(int x, int y) {
  return x + this->columns * y;
}

Cell Grid::getCell(int x, int y) {
  if((0 <= x && x < this->columns) || (0 <= y && y < this->lines)) {
    return this->array[this->convert2Dto1D(x, y)];
  }

  return Dead;
}

int Grid::getLines() {
  return this->lines;
}

int Grid::getColumns() {
  return this->columns;
}

bool Grid::isCellAlive(int x, int y) {
  return this->getCell(x, y) == Alive;
}

void Grid::reviveCell(int x, int y) {
  this->setCell(x, y, Alive);
}

void Grid::killCell(int x, int y) {
  this->setCell(x, y, Dead);
}

int Grid::getNeighbors(int x, int y) {
  int n = 0;

  int initial_x = x - 1;
  int initial_y = y - 1;
  for(int i = 0; i < 9; i++) {
    int ny = initial_y + (int)(i / 3); 
    int nx = initial_x + (int)(i % 3); 

    if(nx == x && ny == y) {
      continue;
    }

    int inbound_x = nx >= 0 && (nx < this->columns);
    int inbound_y = ny >= 0 && (ny < this->lines);

    if(!(inbound_x && inbound_y)) {
      continue;
    }

    int alive = this->isCellAlive(nx, ny);
    if(alive) {
      n++;      
    }
  }

  return n;
}

Grid Grid::calculateNextState() {
  Grid newGrid = this->clone();

  for(int l = 0; l < this->lines; l++) {
    for(int c = 0; c < this->columns; c++) {
      int neighbors = this->getNeighbors(c, l);
      int alive = isCellAlive(c, l);
      if(alive) {
        if(neighbors < 2 || neighbors > 3) {
          
          newGrid.killCell(c, l);
        } else {
          newGrid.reviveCell(c, l);
        }
      } else {
        if(neighbors == 3) {
          newGrid.reviveCell(c, l);
        } else {
          newGrid.killCell(c, l);
        }
      }
    }
  }

  return newGrid;
}

void Grid::display() {
  char *msg = (char *)malloc(sizeof(char) * (2 * 2 * this->columns + 2 * 2 + 2 * this->columns * this->lines + this->lines * 2 + 1));

  int i = 0;
  for(int c = 0; c < this->columns; c++) {
    msg[i++] = '-';
    msg[i++] = '-';
  }
  msg[i++] = '-';
  msg[i++] = '\n';
  for(int l = 0; l < this->lines; l++) {
    for(int c = 0; c < this->columns; c++) {
      msg[i++] = '|';
      msg[i++] = this->isCellAlive(c, l) ? '*' : ' ';
    }
    msg[i++] = '|';
    msg[i++] = '\n';
  }
  for(int c = 0; c < this->columns; c++) {
    msg[i++] = '-';
    msg[i++] = '-';
  }
  msg[i++] = '-';
  msg[i++] = '\n';
  msg[i] = 0;

  printf("%s", msg);
  free(msg);
}