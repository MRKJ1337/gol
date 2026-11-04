#include "../Engine/Engine.cuh"
#include "../SDL/include/SDL3/SDL_render.h"
#include "../SDL/include/SDL3/SDL.h"
#include "../SDL/include/SDL3/SDL_pixels.h"
#include "../SDL_ttf/include/SDL3_ttf/SDL_ttf.h"

class Framework {
public:
  // Contructor which initialize the parameters.
  Framework(int height_, int width_);

  // Draw a square from the top-left corner.
  // Does NOT render immediately. You have to do it yourself.
  void drawSquare(int x, int y, int l, const struct SDL_Color &color);
  // Update render.
  void refresh();
  // Show FPS on-screen.
  // Render it manually afterwards.
  void displayFPS(int fps);

  // Destructor
  ~Framework();

private:
  int height;             // Height of the window
  int width;              // Width of the window
  SDL_Renderer *renderer; // Pointer for the renderer
  SDL_Window *window;     // Pointer for the window
  TTF_Font* font;
};

void runUI(Grid &grid, int pixels_per_cell, int fps);