# Verifying Tock with Serval

## Steps to run:

1. Clone [Tock](link)

2. `rustup install nightly-2019-10-17`

3. Add Tock's home dir to env under name TOCK_ROOT

    a. Add 'export TOCK_ROOT="/path/to/tock/directory"' to ~/.bash_profile

    b. `source ~/.bash_profile`

4. Clone [Serval](link) and install it + dependencies

5. Return to 'tock-verif' dir to run `make verify`
