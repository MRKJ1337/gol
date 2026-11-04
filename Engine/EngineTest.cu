#include "../googletest/googletest/include/gtest/gtest.h"
#include "Engine.cuh"

TEST(EngineTest, 2Dto1D) {
  int lines = 5;
  int columns = 5;
  Grid grid(lines, columns);
  EXPECT_EQ(0, grid.convert2Dto1D(0, 0));
  EXPECT_EQ(5, grid.convert2Dto1D(0, 1));
  EXPECT_EQ(11, grid.convert2Dto1D(1, 2));
  EXPECT_EQ(22, grid.convert2Dto1D(2, 4));
}

TEST(EngineTest, SetCell1D) {
  int lines = 5;
  int columns = 5;
  Grid grid(lines, columns);
  grid.setCell1D(0, Alive);
  grid.setCell1D(5, Alive);
  EXPECT_EQ(Alive, grid.getCell(0, 0));
  EXPECT_EQ(Alive, grid.getCell(0, 1));
}

TEST(EngineTest, Neighbors) {
  int lines = 5;
  int columns = 5;
  Grid grid(lines, columns);

  grid.reviveCell(0, 0);
  grid.reviveCell(1, 0);
  grid.reviveCell(2, 0);

  int neighbors1 = grid.getNeighbors(0, 0);
  int neighbors2 = grid.getNeighbors(1, 0);
  int neighbors3 = grid.getNeighbors(2, 0);
  int neighborsb = grid.getNeighbors(1, 1);
  int neighborsn = grid.getNeighbors(3, 3);

  EXPECT_EQ(1, neighbors1);
  EXPECT_EQ(2, neighbors2);
  EXPECT_EQ(1, neighbors3);
  EXPECT_EQ(3, neighborsb);
  EXPECT_EQ(0, neighborsn);
}

TEST(EngineTest, Engine) {
  int lines = 5;
  int columns = 5;
  Grid grid(lines, columns);
  grid.reviveCell(0, 1);
  grid.reviveCell(1, 1);
  grid.reviveCell(2, 1);

  grid = grid.calculateNextState();
  int alive = 0;
  alive += grid.isCellAlive(0, 1);
  alive += grid.isCellAlive(2, 1);

  alive += grid.isCellAlive(1, 0);
  alive += grid.isCellAlive(1, 1);
  alive += grid.isCellAlive(1, 2);

  EXPECT_EQ(3, alive);
}
