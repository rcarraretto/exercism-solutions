if !System.get_env("EXERCISM_TEST_EXAMPLES") do
  Code.load_file("ocr_numbers.exs", __DIR__)
end

ExUnit.start
ExUnit.configure exclude: :pending, trace: true

defmodule OCRNumbersTest do
  use ExUnit.Case

  # @tag :pending
  test "Recognizes 0" do
    number = OCRNumbers.convert(
      [
        " _ ",
        "| |",
        "|_|",
        "   "
      ]
    )
    assert number == {:ok, "0"}
  end

  test "Recognizes 1" do
    number = OCRNumbers.convert(
      [
        "   ",
        "  |",
        "  |",
        "   "
      ]
    )
    assert number == {:ok, "1"}
  end

  test "Unreadable but correctly sized inputs return ?" do
    number = OCRNumbers.convert(
      [
        "   ",
        "  _",
        "  |",
        "   "
      ]
    )
    assert number == {:ok, "?"}
  end

  test "Input with a number of lines that is not a multiple of four raises an error" do
    number = OCRNumbers.convert(
      [
        " _ ",
        "| |",
        "   "
      ]
    )
    assert number == {:error, 'invalid line count'}
  end

  test "Input with a number of columns that is not a multiple of three raises an error" do
    number = OCRNumbers.convert(
      [
        "    ",
        "   |",
        "   |",
        "    "
      ]
    )
    assert number == {:error, 'invalid column count'}
  end

  test "Recognizes 110101100" do
    number = OCRNumbers.convert(
      [
        "       _     _        _  _ ",
        "  |  || |  || |  |  || || |",
        "  |  ||_|  ||_|  |  ||_||_|",
        "                           "
      ]
    )
    assert number == {:ok, "110101100"}
  end

  test "Garbled numbers in a string are replaced with ?" do
    number = OCRNumbers.convert(
      [
        "       _     _           _ ",
        "  |  || |  || |     || || |",
        "  |  | _|  ||_|  |  ||_||_|",
        "                           "
      ]
    )
    assert number == {:ok, "11?10?1?0"}
  end

  @tag :pending
  test "Recognizes 2" do
    number = OCRNumbers.convert(
      [
        " _ ",
        " _|",
        "|_ ",
        "   "
      ]
    )

    assert number == {:ok, "2"}
  end

  @tag :pending
  test "Recognizes 3" do
    number = OCRNumbers.convert(
      [
        " _ ",
        " _|",
        " _|",
        "   "
      ]
    )

    assert number == {:ok, "3"}
  end

  @tag :pending
  test "Recognizes 4" do
    number = OCRNumbers.convert(
      [
        "   ",
        "|_|",
        "  |",
        "   "
      ]
    )

    assert number == {:ok, "4"}
  end

  @tag :pending
  test "Recognizes 5" do
    number = OCRNumbers.convert(
      [
        " _ ",
        "|_ ",
        " _|",
        "   "
      ]
    )

    assert number == {:ok, "5"}
  end

  @tag :pending
  test "Recognizes 6" do
    number = OCRNumbers.convert(
      [
        " _ ",
        "|_ ",
        "|_|",
        "   "
      ]
    )

    assert number == {:ok, "6"}
  end

  @tag :pending
  test "Regonizes 7" do
    number = OCRNumbers.convert(
      [
        " _ ",
        "  |",
        "  |",
        "   "
      ]
    )

    assert number == {:ok, "7"}
  end

  @tag :pending
  test "Recognizes 8" do
    number = OCRNumbers.convert(
      [
        " _ ",
        "|_|",
        "|_|",
        "   "
      ]
    )

    assert number == {:ok, "8"}
  end

  @tag :pending
  test "Recognizes 9" do
    number = OCRNumbers.convert(
      [
        " _ ",
        "|_|",
        " _|",
        "   "
      ]
    )

    assert number == {:ok, "9"}
  end

  @tag :pending
  test "Recognizes string of decimal numbers" do
    number = OCRNumbers.convert(
      [
        "    _  _     _  _  _  _  _  _ ",
        "  | _| _||_||_ |_   ||_||_|| |",
        "  ||_  _|  | _||_|  ||_| _||_|",
        "                              "
      ]
    )

    assert number == {:ok, "1234567890"}
  end

  @tag :pending
  test "Numbers separated by empty lines are recognized. Lines are joined by commas." do
    number = OCRNumbers.convert(
      [
        "    _  _ ",
        "  | _| _|",
        "  ||_  _|",
        "         ",
        "    _  _ ",
        "|_||_ |_ ",
        "  | _||_|",
        "         ",
        " _  _  _ ",
        "  ||_||_|",
        "  ||_| _|",
        "         "
      ]
    )

    assert number == {:ok, "123,456,789"}
  end
end
