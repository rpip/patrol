[![Build status](https://travis-ci.org/mawuli-ypa/mpower-python.svg "Build status")](https://travis-ci.org/mawuli-ypa/mpower-python.svg)

Patrol
======

> Security depends not so much upon how much you have, as upon how
> much you can do without. - [Joseph Wood Krutch]

Patrol is a set of helpers for creating a sandbox environment for
safely executing untrusted Elixir code.

## Why?

Well, the short answer is, I was bored and wanted something fun to do.

## Default security policy

By default, the untrusted code is executed in a process with the following limits:

* timeout = 5 seconds
* memory limit = 5MB
* stdin, stdout and stderr are redirected to /dev/null (or :NUL on Windows)
* Deny access to the file system
* Deny exiting Elixir
* Deny some builtin module calls binding, node, make_ref etc

You can enable all of these features by setting the sandbox configuration.

## Example 1: (self-contained sandbox environment)

```elixir
iex> use Patrol
iex> sb = Patrol.create_sandbox()
iex> sb.("File.mkdir_p('/media/foo')")
** (Patrol.PermissionError) You tripped the alarm! File.mkdir_p('/media/foo') is not allowed
```

## Example 2: evaluate code in multiple sandbox environments

```elixir

allowed_non_local = [
  {Keyword,      :all},
  {List,         :all},
  {Regex,        :all},
  {Set,          :all},
  {Stream,       :all},
  {String,       :all},
  {Kernel,       {:all, except: [:exit]}},
  {IO,           [:puts]},
  {System,       [:version]},
  {:os,          [:type, :version]}
]

allowed_local = [:&&, :.., :<>, :access, :and, :atom_to_binary, :binary_to_atom,
   :case, :cond, :div, :elem, :if, :in, :is_regex, :match?, :nil?, :or, :rem, :set_elem,
   :sigil_B, :sigil_C, :sigil_R, :sigil_W, :sigil_b, :sigil_c, :sigil_r, :sigil_w]

policy = %Policy{allowed_local: allowed_local, allowed_non_local: allowed_non_local}

# redirect all eval IO to the file
redirect_io = File.open!("sandboxio.txt")
sandbox = %Sandbox{policy: policy, io: sandboxio, timeout: 2000}
Patrol.eval("IO.puts System.version", sandbox)

# use default security policy: directs all IO to /dev/null
Patrol.eval("1 + 3")

# You can also pass quoted expressions!
Patrol.eval(quote do: :os.type)
```

## Credits

This was inspired by two Clojure Sandbox libraries:

* [Clojail]
* [TryElixir]

Initial work of the evaluator was based on the code evaluator used in [TryElixir].

## License

Distributed under the MIT LICENSE.

## Warning

Use at your own risk ;)

[Clojail]: https://github.com/Raynes/clojail
[Clj-Sandbox]: https://github.com/Licenser/clj-sandbox
[TryElixir]: https://github.com/tryelixir/tryelixir
[Joseph Wood Krutch]: http://en.wikipedia.org/wiki/Joseph_Wood_Krutch
