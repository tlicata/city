This is an Erlang project.

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
