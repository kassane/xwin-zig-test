#include <iostream>
#include <chrono>
#include <thread>
#include <vector>

void sleepSort(const std::vector<int>& numbers) {
    std::vector<std::thread> threads;

    for (const auto& num : numbers) {
        threads.emplace_back([num]() {
            std::this_thread::sleep_for(std::chrono::milliseconds(num));
            std::cout << num << " ";
        });
    }

    for (auto& thread : threads) {
        thread.join();
    }

    std::cout << std::endl;
}

int main() {
    std::cout << "Sleep sorting\n";

    std::vector<int> numbers = {9, 40, 10, 1, 6, 45, 23, 50};

    for (const auto& num : numbers) {
        std::cout << num << " ";
    }

    std::cout << "\nSorted numbers: ";
    sleepSort(numbers);

    return 0;
}