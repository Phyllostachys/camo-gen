cmake_minimum_required(VERSION 3.30)
cmake_policy(VERSION 3.30)

project(camo-generator)

include_directories(src)

find_package(SDL2 CONFIG REQUIRED)

add_executable(camo-generator src/main.cpp src/texture.cpp)
target_link_libraries(camo-generator
    PRIVATE
    $<TARGET_NAME_IF_EXISTS:SDL2::SDL2main>
    $<IF:$<TARGET_EXISTS:SDL2::SDL2>,SDL2::SDL2,SDL2::SDL2-static>)