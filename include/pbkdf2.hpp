#pragma once

#include <cstddef>
#include <string_view>
#include <vector>

#include <pbkdf2/compatibility.hpp>

namespace pbkdf2 {

using bytes = std::vector<unsigned char>;

PBKDF2_API std::string_view version();

PBKDF2_API bytes generate_salt(const std::size_t size);

PBKDF2_API bytes derive_key(std::string_view key, const std::size_t keySize, const bytes &salt,
                 const std::size_t iter);

} // namespace pbkdf2
