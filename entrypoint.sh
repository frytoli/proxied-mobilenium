#!/bin/bash

# Start tor
service tor start
# Run given python program
python $1
