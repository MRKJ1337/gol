#include <cuda_runtime.h>
#include <vector>

/// A cell is either :
/// - alive
/// - dead
///
/// This is translated as either 0 and 1.
enum Cell { Dead, Alive };

__host__ __device__ Cell* createBoard(int lines, int columns, Cell *data);

class Grid {
public:
  explicit __host__ __device__ Grid(int lines, int columns);
  explicit __host__ __device__ Grid(int lines, int columns, bool isOnDevice);
  explicit __host__ __device__ Grid(int lines, int columns, bool isOnDevice, Cell* array);
  explicit __host__ __device__ Grid(Grid &grid);

  __host__ __device__ ~Grid();

  __host__ __device__ int getLines();
  __host__ __device__ int getColumns();

  __host__ __device__ int getNeighbors(int x, int y);
  __host__ __device__ bool isCellAlive(int x, int y);
  __host__ __device__ void reviveCell(int x, int y);
  __host__ __device__ void killCell(int x, int y);

  __host__ __device__ Cell getCell(int x, int y);
  __host__ __device__ void setCell(int x, int y, Cell value);
  __host__ __device__ void setCell1D(int index, Cell value);
  __host__ __device__ int convert2Dto1D(int x, int y);

  __host__ __device__ void display();

  Grid* toGPU();
  Grid* toCPU();

  void setArray(Cell *array) {
    delete[] this->array;
    this->array = array;
  }

protected:
  int lines;
  int columns;
  bool isOnDevice;
  Cell* array;
};

void calculateNextState(Grid &gGrid);