#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef GTEST
#include <gtest/gtest.h>
#endif
#include "UI/UI.cuh"

int main(int argc, char **argv) {
  #ifdef GTEST
  testing::InitGoogleTest(&argc, argv);

  if(argc < 2) {
    help:
    printf("Usage : %s -t/--test | <size of grid> <FPS>\n", argv[0]);
    exit(1);
  }
  if((strcmp("-t", argv[1]) == 0) || (strcmp("--test", argv[1]) == 0)) {
    return RUN_ALL_TESTS();
  }
  #else
  if(argc < 3) {
    help:
    printf("Usage : %s <size of grid> <FPS>\n", argv[0]);
    exit(1);
  }
  #endif

  #ifdef GTEST
  if(argc < 3) {
    goto help;
  }
  #endif

  int lines = (int) strtol(argv[1], NULL, 10);
  int columns = lines;
  int fps = (int) strtol(argv[2], NULL, 10);

  Grid grid(lines, columns);
  for (size_t i = 0; i < lines; i++) {
    for (size_t j = 0; j < columns; j++) {
      if (rand() % 2 == 0) {
        grid.reviveCell(j, i);
      }
    }
  }
  
  runUI(grid, 2, fps);

  return 0;
}