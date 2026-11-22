#include <CLI/CLI.hpp>

#include "app_arguments.hpp"

AppArguments::AppArguments(int argc, char *argv[]) {
    CLI::App app{"PKCS5 PBKDF2 HMAC key derivation app"};
    try {
        argv = app.ensure_utf8(argv);

        // clang-format off
        app.set_version_flag("--version,-v", PBKDF2_VERSION);
        app.add_option("password",         password_, "Password to derive key from")->required();
        app.add_option("--salt,-s",        salt_,     "Salt");
        app.add_option("--iter,-i",        iter_,     "Iterations number")->default_val(10);
        app.add_option("--saltsize,--ss",  saltSize_, "generated salt size, bytes")->default_val(64);
        app.add_option("--keysize,--ks",   keySize_,  "key size, bytes")->default_val(64);
        // clang-format no

        app.parse(argc, argv);
    } catch (const CLI::ParseError& e) {
        std::exit(app.exit(e));
    }
}

const std::string& AppArguments::Password() const { return password_; }

const std::string& AppArguments::Salt() const { return salt_; }

std::size_t AppArguments::Iter() const { return iter_; }

std::size_t AppArguments::KeySize() const { return keySize_; }

std::size_t AppArguments::SaltSize() const { return saltSize_; }
