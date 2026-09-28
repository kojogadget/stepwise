# Tally — Technical Design

## 1. Technologies

| Choice | Owner | Reason |
| --- | --- | --- |
| Python 3.12 | all | Standard library covers everything |
| pytest | tests | Fixtures and parametrization |

## 2. Organization

| Directory | Layer |
| --- | --- |
| `tally/counting.py` | counting |
| `tally/files.py` | files |
| `tally/cli.py` | cli |

## 3. Verification

| Check | Command |
| --- | --- |
| Tests | `python -m pytest` |
