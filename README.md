This is an experimental project trying to simulate _something_ about a city.

Some ideas and explanations are in [wat.org](wat.org).

To get it running:

1. Install Erlang.
    Perhaps with [kerl](https://github.com/kerl/kerl).
2. Run Erlang.
    ```sh
    $ erl
     ```
3. Compile the city module.
    ```sh
    1> c(city).
    ```
4. Start the simulation, passing it an OARS city identifier.
    ```sh
    2> city:start(cityoflockport).
    ```

I'm working on converting this project to standard OTP structure and to use the
`rebar3` build tool. The additional instructions might include:

2. Install Rebar3.
    Perhaps by following the instructions on [Adopting Erlang](https://adoptingerlang.org/docs/development/setup/).
3. Build the release.
    ```sh
    $ rebar3 release
    ```
4. Run it.
   ```sh
   ./_build/default/rel/city/bin/city foreground
   ```

It also seems like the release process can be skipped for development purposes:

```sh
$ rebar3 shell
1> city:list_streets().
6
```
