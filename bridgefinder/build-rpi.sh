#!/bin/sh

clang++ -std=c++11 -fblocks -lpthread -lrt -lkqueue -lpthread -lBlocksRuntime -ldispatch -o bridgefinder bridgefinder.cpp
