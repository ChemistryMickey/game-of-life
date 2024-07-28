#pragma once

#include <vector>

class Board
{
  private:
    std::vector<std::vector<bool>> cells;

  public:
    Board() = default;
    Board(std::filesystem::path json_path);
    Board(size_t side_length);
    void print();
    int get_n_live_neighbors(int, int);
    Board interactive_create();

    void apply_game_of_life_rules();
};
