#pragma once

#include <cstddef>
#include <string>

class AppArguments {
public:
    AppArguments(int argc, char *argv[]);
    const std::string &Password() const;
    const std::string &Salt() const;
    std::size_t Iter() const;
    std::size_t KeySize() const;
    std::size_t SaltSize() const;

private:
    std::string password_;
    std::string salt_;
    std::size_t iter_;
    std::size_t keySize_;
    std::size_t saltSize_;
};
