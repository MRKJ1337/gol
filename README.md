# Game of Life - CPU vs GPU

An old school project that introduced parallel programming with graphical cards (CUDA).
The ultimate goal was to show off performance gains on the *Game of Life* by Conway with the power of GPUs in contrast to the CPU version.

Originally made in C as it is a language I'm used to work with,
this is a port in C++ in an attempt to learn the basics of the very language
such as lifetimes, references, pointers, classes and so on.

There are two branches :

- `cpu` for the CPU version
- `gpu` for the GPU version

## Build (CPU)

Those instructions are for **Linux-only** systems.
It can be built on Windows theoritically, but I didn't bother to do so on a (virtual) Windows machine.

- C++14
- cmake >= 3.14
- g++
- `build-essential` toolkit (the name might differ depending on the package manager)

### Cloning

If you are not cloned the repo yet :
```
$ git clone --recurse-submodules https://github.com/MRKJ1337/gol
```

Otherwise :
```
$ git clone https://github.com/MRKJ1337/gol
$ cd gol
$ git submodule update --init --recursive
```

Thuse submodules contain a fixed version of the following frameworks :
- SDL3
- SDL_TTF
- Google Test

## Compiling

By default :
```
$ cd gol
$ cmake -S . -B build CMakeLists.txt
```

Or if you want to enable Google Test :
```
$ cd gol
$ cmake -DENABLE_GTEST=ON -S . -B build CMakeLists.txt
```

## Build (GPU)

Those instructions are for **Linux-only** systems.
It can be built on Windows theoritically, but I didn't bother to do so on a (virtual) Windows machine.

- C++14
- cmake >= 3.14
- g++
- CUDA toolkit
- `build-essential` toolkit (the name might differ depending on the package manager)

The remaining steps are the same as before.

## Known issues

- The optimization from the GPU version makes the program no longer work when
    the dimension `N` is too "high". Around 150 or 200, the program gets completely black
    because of the GPU lacking capacity.