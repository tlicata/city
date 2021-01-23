This is an experimental project trying to simulate _something_ about a city.

Some ideas and explanations are in [wat.org](wat.org).

To get it running:

1. Install Erlang.
    Perhaps with [kerl](https://github.com/kerl/kerl).
2. Install Rebar3.
    Perhaps by following the instructions on [Adopting Erlang](https://adoptingerlang.org/docs/development/setup/).
3. Run the project and open a shell:
    ```sh
    $ rebar3 shell
    1> city:list_streets().
     ```
4. Erlang and rebar3 also support the concept of releases:
    ```sh
    $ rebar3 release
    $ ./_build/default/rel/city/bin/city foreground
    ```

