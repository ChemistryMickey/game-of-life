#include <filesystem>
#include <thread>

#include <argparse/argparse.hpp>

#include <board.hpp>
#include <utils.hpp>

using namespace std::chrono_literals;

void parse_args(argparse::ArgumentParser *program, int argc, char **argv);
int main(int argc, char **argv)
{
    argparse::ArgumentParser program("main");
    parse_args(&program, argc, argv);

    Board board;
    if (program.get<bool>("--create_board"))
        board = board.interactive_create();
    else
        board = Board{program.get<std::filesystem::path>("--board_json")};

    const auto TIME_PER_FRAME = 0.1s; //[seconds]
    while (true)
    {
        clear_terminal();
        board.print();

        board.apply_game_of_life_rules();

        std::this_thread::sleep_for(TIME_PER_FRAME);
    }

    return 0; // this is technically unnecessary but it feels icky without it
}

void parse_args(argparse::ArgumentParser *program, int argc, char **argv)
{
    program->add_argument("--create_board").help("Interactively create a board.").flag();
    program->add_argument("--board_json")
        .help("Path to a JSON defining a board.")
        .default_value(std::filesystem::path("../boards/glider.json"))
        .nargs(1);

    try
    {
        program->parse_args(argc, argv);
    }
    catch (const std::exception &err)
    {
        std::cerr << err.what() << std::endl;
        std::cerr << program;
        std::exit(1);
    }
}