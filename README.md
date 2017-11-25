[![Build Status](https://travis-ci.org/bengoodwyn/aoc-2017-dlang.svg?branch=master)](https://travis-ci.org/bengoodwyn/aoc-2017-dlang)

# Advent of Code

http://adventofcode.com

# Running Unit Tests

```
$ dub test --coverage && tail -qn1 source-*.lst
Generating test runner configuration 'aoc-2017-dlang-test-library' for 'library' (library).
Performing "unittest-cov" build using dmd for x86_64.
aoc-2017-dlang ~master: building configuration "aoc-2017-dlang-test-library"...
Linking...
Running ./aoc-2017-dlang-test-library 
All unit tests have been run successfully.
source/day1.d is 100% covered
source/day10.d is 100% covered
source/day11.d is 100% covered
source/day12.d is 100% covered
source/day13.d is 100% covered
source/day14.d is 100% covered
source/day15.d is 100% covered
source/day16.d is 100% covered
source/day17.d is 100% covered
source/day18.d is 100% covered
source/day19.d is 100% covered
source/day2.d is 100% covered
source/day20.d is 100% covered
source/day21.d is 100% covered
source/day22.d is 100% covered
source/day23.d is 100% covered
source/day24.d is 100% covered
source/day25.d is 100% covered
source/day3.d is 100% covered
source/day4.d is 100% covered
source/day5.d is 100% covered
source/day6.d is 100% covered
source/day7.d is 100% covered
source/day8.d is 100% covered
source/day9.d is 100% covered
```

# Running Application

```
$ dub run
Performing "debug" build using dmd for x86_64.
aoc-2017-dlang ~master: target for configuration "application" is up to date.
To force a rebuild of up-to-date targets, run again with --force.
Running ./aoc-2017-dlang 
Day 1 Part 1: ...
```
