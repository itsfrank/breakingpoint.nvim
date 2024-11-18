#include <iostream>
#include <string>
#include <vector>

std::string concat_vec(const std::vector<std::string>& vec, const std::string& sep) {
    std::string res;
    for (size_t i = 0; i < vec.size(); ++i) {
        if (i > 0 ) res += sep;
        res += vec[i];
    }
    return res;
}

int main() {
    std::vector<std::string> in = {
        "zero",
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
    };

    std::cout << concat_vec(in, "-") << "\n";
}

