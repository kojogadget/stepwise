# Tally — Iterative Implementation Plan

## Approach and assumptions

The developer knows Python. Each iteration ends in something runnable.

## Iteration 1 — Count one file

**Milestone:** `tally notes.txt` prints a word count.

**Requirements:** CNT-01–04

### 1.1 Count words in a string

- **Status:** Done
- **Goal:** Count the words in any string.
- **Test:** Verify single words, runs of mixed whitespace, leading and trailing whitespace, and the empty string.

### 1.2 Report read failures as values

- **Status:** Todo
- **Goal:** Read a file into text, or return a failure the CLI can report.
- **Test:** Verify a readable file returns its text, a missing file returns a ReadFailure, a directory returns a ReadFailure, and nothing is printed by the files module.

## Iteration 2 — Count many files

**Milestone:** `tally a.txt b.txt` prints per-file counts and a total.

**Requirements:** SUM-01–02

### 2.1 Sum several files

- **Status:** Todo
- **Goal:** Count several files in one call and print a total.
- **Test:** Verify one line per file in argument order, a total line, and that a missing file between two good files still counts both good files and exits with status 1.

## Definition of completion

- Every requirement in SPECIFICATION.md is covered by a passing test.
