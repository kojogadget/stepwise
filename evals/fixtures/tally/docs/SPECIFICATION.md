# Tally — Product Specification

Tally is a command-line tool that counts words in text files for writers.

## 1. Product and scope

| ID | Requirement |
| --- | --- |
| CNT-01 | `tally <file>` prints the number of words in the file. |
| CNT-02 | Words are separated by any run of whitespace. |
| CNT-03 | An empty file prints `0`. |
| CNT-04 | A missing or unreadable file prints an error and exits with status 1. |
| SUM-01 | `tally <file>...` prints one line per file and a total line. |
| SUM-02 | A failing file does not stop the other files from being counted. |

## 2. Later goals

- Character and line counts.
