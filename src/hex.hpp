#pragma once

#include <cstdint>
#include <string>
#include <string_view>
#include <vector>

namespace hex {

std::string to(const std::vector<uint8_t> &data);
std::vector<uint8_t> from(std::string_view hex);

} // namespace hex
