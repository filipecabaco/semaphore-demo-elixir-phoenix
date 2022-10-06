# Elixir Code Security: Make it a priority using your CI with 4 tools

Security is becoming an essential concern for companies as we're seeing a rise in attacks and leaks.

As a team using Elixir how can we ensure that each release does not increase risk? We're going to use many tools from the Elixir ecosystem to increase our confidence and automated using Semaphore CI.

All the code used is based on the [Semaphore Demo Elixir Phoenix](https://github.com/semaphoreci-demos/semaphore-demo-elixir-phoenix) repository and we're adding our changes to `./semaphore.yml`

## Credo - Not only for Code Quality

Let's start with one of the more famous tools. [Credo](https://github.com/rrrene/credo) has long been one of the main tools to push for higher quality code in Elixir but it also has some important warnings for more secure code.

Check the following code:

```elixir
defmodule Demo.Demo do
 @moduledoc false
 def bad_atom(string), do: String.to_atom(string)
 def leaky(executable, arguments), do: System.cmd(executable, arguments)
 def bad_exec, do: :os.cmd("ls")
end
```

Here we have 3 potential vulnerabilities:

- `bad_atom` can blow up the Beam VM by creating too many tuples dynamically and exceeding [Beam VM limits](https://www.erlang.org/doc/efficiency_guide/advanced.html#system-limits)
- `leaky` can expose / override/ clear important environment variables from your system since this process would have the same [env as the parent](https://hexdocs.pm/elixir/System.html#cmd/3-options)
- `bad_exec` can execute unsafe code by [sending shell commands to your OS](https://www.erlang.org/doc/man/os.html#cmd-2)

With `mix credo` we will have the warnings we need to prevent us from deploying dangerous code.

Plus, Credo makes it easy to extend and add new [custom rules](https://hexdocs.pm/credo/adding_checks.html) that might deem important to increase security for your use case.

### How do we setup Credo?

1. In your `mix.exs` file, you need to add the following dependency

```elixir
{:credo, "~> 1.6", runtime: false, only: :dev},
```

2. To capture these errors you will need to adapt your `.credo.exs` file:

```elixir
%{
 #
 # You can have as many configs as you like in the `configs:` field.
 configs: [
    %{
 # ...
 checks: [
 # ...
 #
 # Controversial and experimental checks (opt-in,  replace `false` with `[]`)
 #
 # ...
        {Credo.Check.Warning.UnsafeToAtom, []},
        {Credo.Check.Warning.LeakyEnvironment, []}
 # ...
      ]
    }
  ]
}
```

3. Automate running Credo your CI:

```yml
- name: Analyze code
  task:
    # ...
    jobs:
      # ...
      - name: credo
        commands:
          - mix credo -a
```

You should end up with a failing job looking like this:
![`mix credo -a` result](./credo.png)

## Sobelow - Static analysis focused on Security

Still focused on code static analysis, we can dive a bit deeper. Credo is great but lacks some base Elixir warnings and is unaware of common mistakes from common libraries like Phoenix and Ecto.

That's where [Sobelow](https://github.com/nccgroup/sobelow) enters. This tool will comb your code to find common pitfalls.

Check the following configuration file:

```elixir
import Config

config :demo, Demo.Repo,
  database: "demo",
  username: "postgres",
  password: "UG90YXRv",
  hostname: "localhost"
```

If you committed this code to your repository, you could have leaked a secret. And this is the start for Sobelow since it supports warnings from Config files to Phoenix controller responses. Sobelow will be able to find this type of issue by running `mix sobelow`.

You can check supported checkers in the [Documentation](https://hexdocs.pm/sobelow/Sobelow.html#content).

### How to setup Sobelow

1. In your `mix.exs` file, you need to add the following dependency

```elixir
{:sobelow, "~> 0.8", only: :dev}
```

2. Automate install on your CI

```yml
- name: Set up
    task:
      jobs:
        - name: compile and build plts
          commands:
            # ...
            - mix escript.install --force hex sobelow
            # ...
```

3. Automate running Sobelow on your CI

```yml
- name: Analyze code
  task:
    # ...
    jobs:
      # ...
      - name: sobelow
        commands:
          - mix sobelow --exit medium
```

You should end up with a failing job looking like this:
![`mix sobelow --exit medium` result](./sobelow.png)

**Important**: Do note the command `mix sobelow --exit medium`. Sobelow will return an error exit code with a medium or higher vulnerability found

## mix hex.audit - Avoid unsupported packages

Now that we've improved our code we need to check the code of others. mix already has some tooling to check which dependencies are [retired](https://hexdocs.pm/hex/Mix.Tasks.Hex.Retire.html) by choice of the maintainer.

Check the following `mix.exs` dependencies:

```elixir
defp deps do
  [
    {:paginator, "~> 0.6.0"}
  ]
end
```

Paginator's a great project that you might find in several blog posts so you might copy and paste it from the article but forgot to check the latest version.

By using it, we can increase the risk of using vulnerable code. With `mix hex.audit` we will be able to detect retired libraries.

### How to setup mix hex.audit

1. Automate running hex audit on your CI

```yml
- name: Analyze code
  task:
    # ...
    jobs:
      # ...
      - name: retired packages
        commands:
          - mix hex.audit
```

You should end up with a failing job looking like this:
![`mix hex.audit` result](./hex_audit.png)

## Mix Audit - Check dependencies for CVEs

CVEs are a great tool to check what dependencies have proven vulnerabilities and now [GitHub Advisory Database has Erlang / Elixir CVEs](https://github.com/advisories?query=type%3Areviewed+ecosystem%3Aerlang) which means that have a great database at our disposal.

Check the following `mix.exs` dependencies:

```elixir
defp deps do
  [
    {:sweet_xml, "~> 0.6.0"}
  ]
end
```

Same as the example above, you might have copied a bad version of `sweet_xml` with a [known CVE](https://github.com/advisories/GHSA-qpmc-wprv-x746).

You are opening the door for a potential attack vector by not using another version and `mix hex.audit` wouldn't find it since it wasn't retired.

### How to setup mix deps.audit

1. In your `mix.exs` file, you need to add the following dependency

```elixir
{:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false}
```

2. Automate install on your CI

```yml
- name: Set up
    task:
      jobs:
        - name: compile and build plts
          commands:
            # ...
            - mix escript.install --force hex mix_audit
            # ...
```

3. Automate running Mix Audit on your CI

```yml
- name: Analyze code
  task:
    # ...
    jobs:
      # ...
      - name: audit
        commands:
          - mix deps.audit
```

You should end up with a failing job looking like this:
![`mix deps.audit` result](./deps_audit.png)

## Conclusion

With these four tools, we were able to improve both our code security and dependency checking, warning about attack vectors in an automated and actionable way that will allow your team to improve security.

Some of the tools seem to overlap but in reality, they work the best in conjunction:

- Credo will make it easy for you to add new rules if you find more patterns
- Sobelow checks for how you write your code and use your dependencies
- Hex Audit verifies errors on retired packages
- Mix Audit will ensure you actively avoid CVEs in your system
