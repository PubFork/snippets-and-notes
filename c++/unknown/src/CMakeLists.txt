cmake_minimum_required(VERSION 2.8)

# settings
set(CMAKE_BINARY_DIR ${CMAKE_SOURCE_DIR}/../build CACHE PATH "Build Directory" FORCE)
set(CMAKE_CXX_STANDARD 14 CACHE STRING "C++14 Standard" FORCE)

# include dirs
include_directories(${CMAKE_SOURCE_DIR}/../include)

# subdirs to build out
add_subdirectory(addon)
add_subdirectory(configure)
add_subdirectory(infrastructure)
add_subdirectory(platform)
add_subdirectory(provision)
add_subdirectory(role)
add_subdirectory(validate)

# executable and libs to link
add_executable(unknown.xx main.cpp)

target_link_libraries(unknown.xx
  libaddon.so
  libconfigure.so
  libinfrastructure.so
  libplatform.so
  libprovision.so
  librole.so
  libvalidate.so
)
