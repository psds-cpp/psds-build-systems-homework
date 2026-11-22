cmake_minimum_required(VERSION 3.25 FATAL_ERROR)
project(keeper_test_package)

find_package(pbkdf2 REQUIRED)

add_executable(example)
target_sources(example
  PRIVATE
     example.cxx
)
target_link_libraries(example PRIVATE pbkdf2::pbkdf2)
