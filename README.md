# Verifying Tock with Serval

## Steps to run:

1. Clone [Tock](https://github.com/tock/tock)

2. `rustup install nightly-2019-10-17`

3. Add Tock's home dir to env under name TOCK_ROOT
    a. Add to ~/.bash_profile: 'export TOCK_ROOT="/path/to/tock/directory"'
    b. Source ~/.bash_profile

4. Clone [Serval](https://github.com/uw-unsat/serval) and install it + dependencies

5. Return to 'tock-verif' dir to run `make verify`
