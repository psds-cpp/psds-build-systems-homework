#include <cstdlib>
#include <exception>
#include <iostream>

#include <nlohmann/json.hpp>
#include <nlohmann/json_fwd.hpp>

#include "app_arguments.hpp"
#include "hex.hpp"
#include "pbkdf2.hpp"

int run(int argc, char *argv[]) {
    AppArguments args(argc, argv);

    pbkdf2::bytes salt;
    if (!args.Salt().empty()) {
        salt = hex::from(args.Salt());
    } else {
        salt = pbkdf2::generate_salt(args.SaltSize());
    }

    auto result = pbkdf2::derive_key(args.Password(), args.KeySize(), salt, args.Iter());
    auto resultHex = hex::to(result);

    nlohmann::json output = {{"hash", resultHex}};
    if (args.Salt().empty()) {
        output["salt"] = hex::to(salt);
    }

    std::cout << output.dump(4) << std::endl;

    return EXIT_SUCCESS;
}

int main(int argc, char *argv[]) {
    try {
        return run(argc, argv);
    } catch (const std::exception &err) {
        std::cerr << "Error: " << err.what() << std::endl;
    } catch (...) {
        std::cerr << "Error: unknown" << std::endl;
    }
    return EXIT_FAILURE;
}
