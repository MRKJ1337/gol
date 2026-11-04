#include "UI.cuh"
#include <stdio.h>
#include <signal.h>
#include "../SDL/include/SDL3/SDL_pixels.h"
#include "../SDL/include/SDL3/SDL_render.h"
#include "../SDL/include/SDL3/SDL_timer.h"

// Used to catch SIGINT signals
static volatile int running = 1;

void sigint_handler(int dummy) {
  running = 0;
}

Framework::Framework(int height_, int width_) : height(height_), width(width_) {
  this->renderer = NULL;
  this->window   = NULL;

  // Initializing SDL as Video
  SDL_Init(SDL_INIT_VIDEO);
  TTF_Init();

  SDL_CreateWindowAndRenderer("Game of Life", this->width, this->height, SDL_WINDOW_RESIZABLE, &this->window, &this->renderer);

  this->font = TTF_OpenFont("Roboto-Regular.ttf", 24);
  if (!font) {
    printf("TTF_OpenFont error: %s\n", SDL_GetError());
    SDL_DestroyRenderer(this->renderer);
    SDL_DestroyWindow(this->window);
    TTF_Quit();
    SDL_Quit();
    exit(1);
  }

  // Setting draw color
  SDL_SetRenderDrawColor(this->renderer, 0, 0, 0, 0);

  // Clear the newly created window
  SDL_RenderClear(this->renderer);

  // Reflects the changes done in the window.
  this->refresh();
}

Framework::~Framework() {
  SDL_DestroyRenderer(this->renderer);
  SDL_DestroyWindow(this->window);
  TTF_Quit();
  SDL_Quit();
}

void Framework::refresh() {
  SDL_RenderPresent(this->renderer);
}

void Framework::drawSquare(int x, int y, int l, const struct SDL_Color &color) {
  SDL_SetRenderDrawColor(this->renderer, color.r, color.g, color.b, color.a);
  const SDL_FRect rect = { (float)x, (float)y, (float)l, (float)l };
  
  SDL_RenderFillRect(this->renderer, &rect);
}

void Framework::displayFPS(int fps) {
  char str[20] = { 0 };
  sprintf(str, "FPS : %5d", fps);
  SDL_Color textColor = {255, 0, 0, 255}; // White text
  SDL_Surface* textSurface = TTF_RenderText_Solid(this->font, str, 11, textColor);
  SDL_Texture* textTexture = SDL_CreateTextureFromSurface(renderer, textSurface);
  SDL_DestroySurface(textSurface);

  float textWidth = 111, textHeight = 29;
  SDL_FRect textRect = {(float)this->width - textWidth, textHeight, textWidth, textHeight};

  SDL_RenderTexture(this->renderer, textTexture, NULL, &textRect);
}

void runUI(Grid &grid, int pixels_per_cell, int fps) {
  // Catch SIGINT signals
  signal(SIGINT, sigint_handler);

  // Creating the object by passing Height and Width value.
  Framework fw(
    grid.getLines() * pixels_per_cell,
    grid.getColumns() * pixels_per_cell
  );

  // Event variable
  SDL_Event event;
  SDL_zero( event );

  // Below while loop checks if the window has terminated
  // using close in the corner.
  struct SDL_Color color_alive;
  color_alive.a = 255;
  color_alive.r = 255;
  color_alive.g = 255;
  color_alive.b = 0;

  // Should be the same as the background
  struct SDL_Color color_dead;
  color_dead.a = 255;
  color_dead.r = 0;
  color_dead.g = 0;
  color_dead.b = 0;

  uint32_t frameDelay = 1000/fps;
  uint32_t frameStart;
  uint32_t frameTime;
  int      estimated_fps;

  Grid *gGrid = grid.toGPU();
  Grid *cGrid = new Grid(grid);

  while (!(event.type == SDL_EVENT_QUIT) && running) {
    frameStart = SDL_GetTicks();

    for(int l = 0; l < cGrid->getLines(); l++) {
      for(int c = 0; c < cGrid->getColumns(); c++) {
        struct SDL_Color *color = cGrid->isCellAlive(l, c) ? &color_alive : &color_dead;
        fw.drawSquare(pixels_per_cell * l, pixels_per_cell * c, pixels_per_cell, *color);
      }
    }
    fw.displayFPS(estimated_fps);
    fw.refresh();

    calculateNextState(*gGrid);
    delete cGrid;
    cGrid = gGrid->toCPU();

    // Cap FPS
    frameTime = SDL_GetTicks() - frameStart;
    if(frameDelay > frameTime) {
      SDL_Delay(frameDelay - frameTime);

      // Display FPS
      // ! Note that the frame time has to be recalculated
      // ! after the delay
      frameTime = SDL_GetTicks() - frameStart;
    }
    estimated_fps = 1000.0f / (frameTime);

    // Catching the poll event.
    SDL_PollEvent(&event);
    while (SDL_PollEvent(&event)) {
      if (event.type == SDL_EVENT_QUIT) {
          running = 0;
      }
    }
  }
}
