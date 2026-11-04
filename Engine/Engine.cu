#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include "Engine.cuh"

__host__ __device__ Cell* createBoard(int lines, int columns, Cell *data) {
  auto board = new Cell[lines * columns] { };
  if(data != nullptr) {
    memcpy(board, data, sizeof(Cell) * lines * columns);
  } else {
    memset(board, Dead, sizeof(Cell) * lines * columns);
  }
  return board;
}

__host__ __device__ Grid::Grid(int lines, int columns):
  lines(lines),
  columns(columns),
  isOnDevice(false)
{
  this->array = createBoard(this->lines, this->columns, nullptr);
}

__host__ __device__ Grid::Grid(int lines, int columns, bool isOnDevice):
  lines(lines),
  columns(columns),
  isOnDevice(isOnDevice)
{
  this->array = createBoard(this->lines, this->columns, nullptr);
}

__host__ __device__ Grid::Grid(int lines, int columns, bool isOnDevice, Cell* array):
  lines(lines),
  columns(columns),
  isOnDevice(isOnDevice)
{
  this->array = createBoard(this->lines, this->columns, array);
}

__host__ __device__ Grid::Grid(Grid &other):
  lines(other.lines),
  columns(other.columns),
  isOnDevice(other.isOnDevice)
{
  this->array = createBoard(this->lines, this->columns, other.array);
}

__host__ __device__ Grid::~Grid() {
  if(this->isOnDevice) {
    cudaFree(this->array);
  } else {
    delete[] this->array;
  }
}

__host__ __device__ void Grid::setCell(int x, int y, Cell c) {
  setCell1D(this->convert2Dto1D(x, y), c);
}

__host__ __device__ void Grid::setCell1D(int index, Cell c) {
  if((0 <= index) && (index < this->lines * this->columns)) {
    this->array[index] = c;
  }
}

__host__ __device__ int Grid::convert2Dto1D(int x, int y) {
  return x + this->columns * y;
}

__host__ __device__ Cell Grid::getCell(int x, int y) {
  if((0 <= x && x < this->columns) || (0 <= y && y < this->lines)) {
    return this->array[this->convert2Dto1D(x, y)];
  }

  return Dead;
}

__host__ __device__ int Grid::getLines() {
  return this->lines;
}

__host__ __device__ int Grid::getColumns() {
  return this->columns;
}

__host__ __device__ bool Grid::isCellAlive(int x, int y) {
  return this->getCell(x, y) == Alive;
}

__host__ __device__ void Grid::reviveCell(int x, int y) {
  this->setCell(x, y, Alive);
}

__host__ __device__ void Grid::killCell(int x, int y) {
  this->setCell(x, y, Dead);
}

__host__ __device__ int Grid::getNeighbors(int x, int y) {
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

void checkCUDA(cudaError err) {
  if(err != cudaSuccess) {
    printf("%s : %s\n", "CUDA error", cudaGetErrorString(err));
    exit(1);
  }
}

Grid* Grid::toGPU() {
  int sizeArray = sizeof(Cell) * this->columns * this->lines;
  Cell *gArray = nullptr;
  checkCUDA(cudaMalloc((void **)&gArray, sizeArray));
  checkCUDA(cudaMemcpy(gArray, this->array, sizeArray, cudaMemcpyHostToDevice));

  Grid* gGrid = new Grid(lines, columns, true);
  gGrid->setArray(gArray);
  return gGrid;
}

Grid* Grid::toCPU() {
  int sizeArray = sizeof(Cell) * this->columns * this->lines;
  Cell *cArray = new Cell[lines * columns] {} ;
  cudaMemcpy(cArray, this->array, sizeArray, cudaMemcpyDeviceToHost);

  Grid *cGrid = new Grid(lines, columns, false, cArray);
  return cGrid;
}

__global__ void __calculateNextState(Grid &gGrid) {
  extern __shared__ Cell array[];
  int c = blockIdx.x * blockDim.x + threadIdx.x;
  int l = blockIdx.y * blockDim.y + threadIdx.y;

  int lines = gGrid.getLines();
  int columns = gGrid.getColumns();

  if(l >= lines || c >= columns) return;
  int index = l * columns + c;
  array[c] = Dead;

  int neighbors = gGrid.getNeighbors(c, l);
  int alive = gGrid.isCellAlive(c, l);

  if(alive) {
    if(neighbors < 2 || neighbors > 3) {
      array[c] = Dead;
    } else {
      array[c] = Alive;
    }
  } else {
    if(neighbors == 3) {
      array[c] = Alive;
    } else {
      array[c] = Dead;
    }
  }
  __syncthreads();
  gGrid.setCell1D(index, array[c]);
}

void calculateNextState(Grid &gGrid) {
  int lines = gGrid.getLines();
  int columns = gGrid.getColumns();
  dim3 threadsPerBlock(columns, 1);
  dim3 numBlocks(lines / threadsPerBlock.x, lines / threadsPerBlock.y);
  __calculateNextState<<<numBlocks, threadsPerBlock, lines>>>(gGrid);
  cudaDeviceSynchronize();
}

__host__ __device__ void Grid::display() {
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