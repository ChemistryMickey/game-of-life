#include <array>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include <nlohmann/json.hpp>

#include <board.hpp>
#include <utils.hpp>

using json = nlohmann::json;

Board::Board(std::filesystem::path json_path)
{
    std::ifstream f(json_path);
    if (!f.is_open())
    {
        std::cout << "Failed to open " << json_path << "!\n";
        exit(1);
    }

    json data = json::parse(f);
    this->cells = data;

    // ifstream closes when f goes out of scope
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

std::array<size_t, 2> parse_addresses(std::string &in_line)
{
    std::array<size_t, 2> addrs{0, 0};
    size_t pos = in_line.find(',');
    if (pos == std::string::npos)
    {
        std::cerr << "Too few addresses!\n";
        return {SIZE_MAX, SIZE_MAX};
    }

    try
    {
        addrs[0] = stoi(in_line.substr(0, pos));
    }
    catch (const std::exception &err)
    {
        std::cerr << err.what() << std::endl;
        std::cerr << in_line << " is not a valid integer!\n";
        std::exit(1);
    }
    in_line.erase(0, pos + 1);
    try
    {
        addrs[1] = stoi(in_line);
    }
    catch (const std::exception &err)
    {
        std::cerr << err.what() << std::endl;
        std::cerr << in_line << " is not a valid integer!\n";
        std::exit(1);
    }

    return addrs;
}

Board interactive_create_board()
{
    std::string in_line;

    std::cout << "How many lines on each side is this board: ";
    getline(std::cin, in_line);
    size_t n_side = 0;
    try
    {
        n_side = stoi(in_line);
    }
    catch (const std::exception &err)
    {
        std::cerr << err.what() << std::endl;
        std::cerr << in_line << " is not a valid integer!\n";
        std::exit(1);
    }

    Board board(n_side);

    std::cout << "Add 'live' cell addresses in the form 'a, b' in the range " << n_side << "x" << n_side
              << " (non-inclusive)\n(Enter -1 or a blank to continue)\n";
    std::array<size_t, 2> addrs{0, 0};
    while (true)
    {
        in_line.clear();
#ifdef DEBUG_PRINT
        std::cout << "Top of the loop: " << in_line << "\n";
#endif
        getline(std::cin, in_line);
#ifdef DEBUG_PRINT
        std::cout << "Read line: " << in_line << "\n";
#endif
        trim_whitespace(in_line);
#ifdef DEBUG_PRINT
        std::cout << "Trimmed line: " << in_line << "\n";
#endif
        if (!in_line.compare("-1") || !in_line.compare(""))
        {
            std::cout << "Breaking!\n";
            break;
        }

        // Get addresses
        addrs = parse_addresses(in_line);
#ifdef DEBUG_PRINT
        std::cout << "Addresses: [" << addrs[0] << ", " << addrs[1] << "]\n";
#endif
        if (addrs[0] == SIZE_MAX)
            continue;

        for (auto addr : addrs)
        {
            if (addr >= n_side)
            {
                std::cerr << "Addresses must be in the range [0, " << n_side << " - 1]!\n";
                continue;
            }
        }

        board.cells[addrs[0]][addrs[1]] = true;
        board.print();
    }

    std::cout << "TODO: output JSON file\n";
    // std::string save_path = "";
    // getline(std::cin, save_path);
    // if (!save_path.compare(""))
    // {
    //     std::cout << "TODO: output JSON file\n";
    // }

    return board;
}