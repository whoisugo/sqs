from typing import Iterable, Optional


def second_largest(numbers: Iterable[int]) -> Optional[int]:
    """Return the second largest distinct integer in ``numbers``.

    Args:
        numbers: An iterable of integers.

    Returns:
        The second largest distinct integer if it exists, otherwise ``None``.
    """
    largest: Optional[int] = None
    second: Optional[int] = None

    for value in numbers:
        if largest is None or value > largest:
            if largest is not None and value != largest:
                second = largest
            largest = value
        elif value != largest and (second is None or value > second):
            second = value

    return second
