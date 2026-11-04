cmake_minimum_required(VERSION 3.20)

project(gol LANGUAGES CUDA CXX)

set(EXECUTABLE_NAME gol)

set(CMAKE_BUILD_TYPE Debug)

# Disabled by default
# because Windows will run tests no matter what
OPTION(ENABLE_GTEST "Compile Google Test as well." OFF)

# C++14 is needed for Google Test
set(CMAKE_CXX_STANDARD 17)

set(
    SRCS
    main.cu
    Engine/Engine.cu
    UI/UI.cu
)

if(ENABLE_GTEST)
set(
    SRCS
    ${SRCS}
    Engine/EngineTest.cu
)
endif(ENABLE_GTEST)

set(
    HEADERS
    Engine/Engine.cuh
    UI/UI.cuh
)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
set(USE_CUDA ON)
set(CMAKE_CUDA_ARCHITECTURES native)
set_source_files_properties(${SRCS} PROPERTIES LANGUAGE CUDA)

# Avoid creating products into useless separate folders like "Debug" or "Release"
# but inside the same directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

IF(ENABLE_GTEST)
    add_compile_definitions(GTEST)
ENDIF(ENABLE_GTEST)

add_executable(${EXECUTABLE_NAME} ${SRCS} ${HEADERS})

# Include SDL3
add_subdirectory(SDL EXCLUDE_FROM_ALL)
add_subdirectory(SDL_ttf EXCLUDE_FROM_ALL)

# Copy .ttf
configure_file(Roboto-Regular.ttf ${CMAKE_BINARY_DIR}/Roboto-Regular.ttf COPYONLY)

IF(ENABLE_GTEST)
    add_subdirectory(googletest EXCLUDE_FROM_ALL)
ENDIF(ENABLE_GTEST)

# Linking SDL3 library and Google Test with our project.
IF(ENABLE_GTEST)
    target_link_libraries(${EXECUTABLE_NAME} PRIVATE SDL3_ttf::SDL3_ttf SDL3::SDL3 GTest::gtest_main)
ELSE()
    target_link_libraries(${EXECUTABLE_NAME} PRIVATE SDL3_ttf::SDL3_ttf SDL3::SDL3)
ENDIF(ENABLE_GTEST)
