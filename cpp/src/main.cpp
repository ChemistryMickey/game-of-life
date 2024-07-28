#include <filesystem>
#include <thread>

#include <board.hpp>
#include <utils.hpp>

int main()
{
    using namespace std::chrono_literals;

    std::filesystem::path board_dir{"../boards"};
    std::filesystem::path board_path = board_dir / "glider.json";

    Board board{board_path};

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