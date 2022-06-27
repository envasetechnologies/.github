import unittest

from assertpy import assert_that

import src.dummy as dummy


class TestAdd(unittest.TestCase):

    def test_unit_tests_run(self):
        assert_that(dummy.add(2, 3)).is_equal_to(5)


if __name__ == "__main__":
    unittest.main()
