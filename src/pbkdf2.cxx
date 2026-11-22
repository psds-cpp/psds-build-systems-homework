#include <cstddef>
#include <stdexcept>
#include <string_view>

#include <openssl/err.h>
#include <openssl/evp.h>
#include <openssl/rand.h>

#include "pbkdf2.hpp"

namespace pbkdf2 {

std::string_view version() { return PBKDF2_VERSION; }

bytes generate_salt(const std::size_t size) {
    bytes result(size);
    if (RAND_bytes(result.data(), static_cast<int>(result.size())) != 1) {
        throw std::runtime_error(ERR_error_string(ERR_get_error(), NULL));
    }
    return result;
}

bytes derive_key(std::string_view key, const std::size_t keySize, const bytes &salt,
                 const std::size_t iter) {
    bytes result(keySize);
    if (PKCS5_PBKDF2_HMAC(key.data(), static_cast<int>(key.size()), salt.data(), salt.size(), iter,
                          EVP_sha512(), static_cast<int>(result.size()), result.data()) != 1) {
        throw std::runtime_error(ERR_error_string(ERR_get_error(), NULL));
    }
    return result;
}

} // namespace pbkdf2
