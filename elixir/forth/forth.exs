defmodule Forth do

  def new() do
    {[], %{}}
  end

  def eval(ev, s) do
    s
    |> String.replace(~r/[^\w+-\\*\/]| /, " ")
    |> String.split()
    |> Enum.map(&token_type/1)
    |> eval_tokens(ev)
  end

  defp token_type("+"), do: &Kernel.+/2
  defp token_type("-"), do: &Kernel.-/2
  defp token_type("*"), do: &Kernel.*/2
  defp token_type("/"), do: &forth_div/2
  defp token_type(symbol) do
    case Integer.parse(symbol) do
      {int, ""} -> int
      _         -> String.downcase(symbol)
    end
  end

  defp forth_div(_, 0), do: raise Forth.DivisionByZero
  defp forth_div(x, y), do: Kernel.div(x, y)

  defp eval_tokens([], {stack, words}) do
    {Enum.reverse(stack), words}
  end

  defp eval_tokens([operator | tokens], {[y, x | stack], words})
    when is_function(operator) do
    result = operator.(x, y)
    eval_tokens(tokens, {[result | stack], words})
  end

  defp eval_tokens([":", word | _], _) when is_integer(word) do
    raise Forth.InvalidWord
  end

  defp eval_tokens([":", word | tokens], {stack, words}) do
    {word_tokens, [";" | rem_tokens]} = Enum.split_while(tokens, &(&1 != ";"))
    eval_tokens(rem_tokens, {stack, Map.put(words, word, word_tokens)})
  end

  defp eval_tokens(all_tokens = [word | tokens], ev = {_, words})
    when is_binary(word) do
    case Map.fetch(words, word) do
      {:ok, word_tokens} -> eval_tokens(word_tokens ++ tokens, ev)
      :error             -> eval_built_in(all_tokens, ev)
    end
  end

  defp eval_tokens([token | tokens], {stack, words}) do
    eval_tokens(tokens, {[token | stack], words})
  end

  defp eval_built_in([op | _], {[], _}) when op in ["dup", "drop", "swap", "over"] do
    raise Forth.StackUnderflow
  end

  defp eval_built_in([op | _], {[_], _}) when op in ["swap", "over"] do
    raise Forth.StackUnderflow
  end

  defp eval_built_in(["dup" | tokens], {[x | stack], words}) do
    eval_tokens(tokens, {[x, x | stack], words})
  end

  defp eval_built_in(["drop" | tokens], {[_ | stack], words}) do
    eval_tokens(tokens, {stack, words})
  end

  defp eval_built_in(["swap" | tokens], {[x, y | stack], words}) do
    eval_tokens(tokens, {[y, x | stack], words})
  end

  defp eval_built_in(["over" | tokens], {[x, y | stack], words}) do
    eval_tokens(tokens, {[y, x, y | stack], words})
  end

  defp eval_built_in(_, _) do
    raise Forth.UnknownWord
  end

  def format_stack({stack, _}) do
    Enum.join(stack, " ")
  end

  defmodule StackUnderflow do
    defexception []
    def message(_), do: "stack underflow"
  end

  defmodule InvalidWord do
    defexception [word: nil]
    def message(e), do: "invalid word: #{inspect e.word}"
  end

  defmodule UnknownWord do
    defexception [word: nil]
    def message(e), do: "unknown word: #{inspect e.word}"
  end

  defmodule DivisionByZero do
    defexception []
    def message(_), do: "division by zero"
  end
end
