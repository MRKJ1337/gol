#include <vector>

/// A cell is either :
/// - alive
/// - dead
///
/// This is translated as either 0 and 1.
enum Cell { Dead, Alive };

class Grid {
public:
  explicit Grid(int lines, int columns);
  explicit Grid(int lines, int columns, std::vector<Cell> &array);

  ~Grid();

  int getLines();
  int getColumns();

  int getNeighbors(int x, int y);
  bool isCellAlive(int x, int y);
  void reviveCell(int x, int y);
  void killCell(int x, int y);

  Cell getCell(int x, int y);
  void setCell(int x, int y, Cell value);
  void setCell1D(int index, Cell value);
  int convert2Dto1D(int x, int y);

  Grid calculateNextState();

  void display();

private:
  Grid clone();

  int lines;
  int columns;
  std::vector<Cell> array;
};