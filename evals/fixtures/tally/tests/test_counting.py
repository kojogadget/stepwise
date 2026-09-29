import pytest

from tally.counting import count_words


@pytest.mark.parametrize(
    ("text", "word_count"),
    [
        ("word", 1),
        ("one \t two\n\nthree", 3),
        ("  padded words  \n", 2),
        ("", 0),
    ],
    ids=["single-word", "mixed-whitespace", "leading-trailing", "empty"],
)
def test_count_words(text, word_count):
    assert count_words(text) == word_count
