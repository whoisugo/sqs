from __future__ import annotations


def reverse_words(sentence: str) -> str:
    """
    Return the sentence with the order of words reversed while keeping the letters
    within each word unchanged.

    The function collapses consecutive whitespace in the input to single spaces in
    the output, matching the conventional definition of "words" in such problems.
    """
    words = sentence.split()
    return " ".join(reversed(words))
