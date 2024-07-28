#include <utils.hpp>

void clear_terminal()
{
    std::cout << "\x1b[H\x1b[2J";
}

void trim_whitespace(std::string &str_in)
{
    str_in.erase(std::remove_if(str_in.begin(), str_in.end(), ::isspace), str_in.end());
}
