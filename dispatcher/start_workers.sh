#!/bin/sh
for i in $(seq $1); do
    ruby dispatcher/worker.rb &
done
