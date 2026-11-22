import os

from conan import ConanFile
from conan.tools.cmake import CMake, cmake_layout
from conan.tools.build import can_run


class KeeperTestConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps", "CMakeToolchain"

    def requirements(self):
        self.requires(self.tested_reference_str)

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def layout(self):
        folder_vars = [
            "settings.arch",
            "settings.build_type",
            "settings.compiler",
            "settings.compiler.version",
            "settings.os",
            "options.shared",
        ]
        if self.settings.os == "Neutrino":
            folder_vars.append("settings.os.variant")
            folder_vars.append("settings.os.version")
        self.folders.build_folder_vars = folder_vars
        cmake_layout(self)

    def test(self):
        if can_run(self):
            cmd = os.path.join(self.cpp.build.bindir, "example")
            self.run(cmd, env="conanrun")
