#include "app2.h"

std::string concatenate(std::string_view first, std::string_view second) {
    std::string result;
    result.reserve(first.size() + 1U + second.size());
    result.append(first);
    result.push_back(' ');
    result.append(second);
    return result;
}