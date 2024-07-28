#pragma once

#include <filesystem>
#include <vector>

class Board
{
  public:
    std::vector<std::vector<bool>> cells;
    Board() = default;
    Board(std::filesystem::path json_path);
    Board(size_t side_length);
    void print();
    int get_n_live_neighbors(int, int);

    void apply_game_of_life_rules();
};

Board interactive_create_board();