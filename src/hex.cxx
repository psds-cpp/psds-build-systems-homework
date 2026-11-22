#include <cstdint>
#include <stdexcept>
#include <string>
#include <string_view>
#include <vector>

namespace hex {

std::string to(const std::vector<uint8_t> &data) {
    static constexpr char hex_chars[] = "0123456789abcdef";
    std::string out;
    out.reserve(data.size() * 2);
    for (uint8_t byte : data) {
        out.push_back(hex_chars[byte >> 4]);
        out.push_back(hex_chars[byte & 0x0F]);
    }
    return out;
}

std::vector<uint8_t> from(std::string_view hex) {
    if (hex.size() % 2 != 0) {
        throw std::invalid_argument("Hex string must have even length");
    }
    auto nibble = [](char c) -> uint8_t {
        if (c >= '0' && c <= '9')
            return static_cast<uint8_t>(c - '0');
        if (c >= 'a' && c <= 'f')
            return static_cast<uint8_t>(c - 'a' + 10);
        if (c >= 'A' && c <= 'F')
            return static_cast<uint8_t>(c - 'A' + 10);
        throw std::invalid_argument("Invalid hex character");
    };

    std::vector<uint8_t> out;
    out.reserve(hex.size() / 2);
    for (size_t i = 0; i < hex.size(); i += 2) {
        out.push_back(static_cast<uint8_t>((nibble(hex[i]) << 4) | nibble(hex[i + 1])));
    }
    return out;
}

} // namespace hex
