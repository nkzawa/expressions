#!/bin/bash

cd $(dirname $0)
source ../assert.sh

data="Lorem ipsum dolor sit amet"

assert "node huffman-coding.js" "$data" "$data"
assert "runhaskell huffman-coding.hs" "$data" "$data"

g++ -Wall -std=c++11 huffman-coding.cpp
assert "./a.out" "$data" "$data"

assert_end "huffman-coding"
