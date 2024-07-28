#pragma once

#include <iostream>

void clear_terminal()
{
    std::cout << "\x1b[H\x1b[2J";
}