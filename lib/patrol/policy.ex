defmodule Patrol.Policy do
  @moduledoc """
  Security policy for the sandbox.
  """
  @allowed_non_local [
    {Bitwise,      :all},
    {Dict,         :all},
    {Enum,         :all},
    {HashDict,     :all},
    {HashSet,      :all},
    {Keyword,      :all},
    {List,         :all},
    {ListDict,     :all},
    {Regex,        :all},
    {Set,          :all},
    {Stream,       :all},
    {String,       :all},
    {Integer,      :all},
    {Binary.Chars, [:to_binary]}, # string interpolation
    {Kernel,       :all, except: [:exit]},
    {System,       [:version]},
    {:calendar,    :all},
    {:math,        :all},
    {:os,          [:type, :version]}
  ]

  # with 0 arity
  @restricted_local [:binding, :is_alive, :make_ref, :node, :self]
  @allowed_local [:&&, :.., :<>, :access, :and, :atom_to_binary, :binary_to_atom,
    :case, :cond, :div, :elem, :if, :in, :insert_elem, :is_range, :is_record,
    :is_regex, :match?, :nil?, :or, :rem, :set_elem, :sigil_B, :sigil_C, :sigil_R,
    :sigil_W, :sigil_b, :sigil_c, :sigil_r, :sigil_w, :to_binary, :to_char_list,
    :unless, :xor, :|>, :||, :!, :!=, :!==, :*, :+, :+, :++, :-, :--, :/, :<, :<=,
    :=, :==, :===, :=~, :>, :>=, :abs, :atom_to_binary, :atom_to_list, :binary_part,
    :binary_to_atom, :binary_to_float, :binary_to_integer, :binary_to_integer,
    :binary_to_term, :bit_size, :bitstring_to_list, :byte_size,
    :float, :float_to_binary, :float_to_list, :hd, :inspect, :integer_to_binary,
    :integer_to_list, :iolist_size, :iolist_to_binary, :is_atom, :is_binary,
    :is_bitstring, :is_boolean, :is_float, :is_function, :is_integer, :is_list,
    :is_number, :is_tuple, :length, :list_to_atom, :list_to_bitstring,
    :list_to_float, :list_to_integer, :list_to_tuple, :max, :min, :not, :round, :size,
    :term_to_binary, :throw, :tl, :trunc, :tuple_size, :tuple_to_list, :fn, :->, :&,
    :__block__, :"{}", :"<<>>", :::, :for, :^, :when, :|,
    :defmodule, :def, :defp, :__aliases__]


  @doc """
  Returns the allowed local function calls
  """
  def allowed_local, do: @allowed_local

  @doc """
  Returns the allowed remote function calls
  """
  def allowed_non_local, do: @allowed_non_local

  @doc """
  Returns the allowed restricted local function calls
  """
  def restricted_local, do: @restricted_local

end