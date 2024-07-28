#include <filesystem>
#include <fstream>
#include <iostream>
#include <vector>

#include <nlohmann/json.hpp>

#include <board.hpp>

using json = nlohmann::json;

Board::Board(std::filesystem::path json_path)
{
    std::ifstream f(json_path);
    json data = json::parse(f);
    this->cells = data;
}

Board::Board(size_t side_len)
{
    this->cells = std::vector<std::vector<bool>>(side_len, std::vector<bool>(side_len, false));
}

void Board::print()
{
    for (auto &row : this->cells)
    {
        for (auto val : row)
        {
            if (val)
                std::cout << "▣  ";
            else
                std::cout << ".  \033[39m";
        }
        std::cout << "\n";
    }
}

int Board::get_n_live_neighbors(int i, int j)
{
    int n_live_neighbors = 0;
    size_t n_side = this->cells.size();
    std::vector<int> steps = {-1, 0, 1};
    for (auto i_step : steps)
    {
        for (auto j_step : steps)
        {
            if ((i_step == 0) && (j_step == 0))
                continue;

            if ((i + i_step < 0) || (j + j_step < 0) || (i + i_step >= n_side) || (j + j_step >= n_side))
                continue;

            if (this->cells[i + i_step][j + j_step])
                ++n_live_neighbors;
        }
    }

    return n_live_neighbors;
}

void Board::apply_game_of_life_rules()
{
    size_t n_side = this->cells.size();
    Board life_board{n_side};
    Board death_board{n_side};

    for (size_t i = 0; i < n_side; ++i)
    {
        for (size_t j = 0; j < n_side; ++j)
        {
            int n_live_neighbors = this->get_n_live_neighbors(i, j);

            if (this->cells[i][j] && (n_live_neighbors != 2) && (n_live_neighbors != 3))
                death_board.cells[i][j] = true;
            if ((!this->cells[i][j]) && (n_live_neighbors == 3))
                life_board.cells[i][j] = true;
        }
    }

    for (size_t i = 0; i < n_side; ++i)
    {
        for (size_t j = 0; j < n_side; ++j)
        {
            if (death_board.cells[i][j])
                this->cells[i][j] = false;
            if (life_board.cells[i][j])
                this->cells[i][j] = true;
        }
    }
}