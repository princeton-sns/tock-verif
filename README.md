# Verifying Tock with Serval

## Setting up

1. Clone [Serval](https://github.com/uw-unsat/serval) and install

<!--2. Clone [Tock](https://github.com/tock/tock)-->

2. `rustup install nightly-2019-10-17`

3. `make verify`

<!--
4. Add Tock's root directory to your environment under the name TOCK_ROOT: 

    a. `echo 'export TOCK_ROOT="/path/to/tock/directory"' >> ~/.bash_profile`

    b. `source ~/.bash_profile`

5. Create a library package for the respective files in Tock that we want to 
   verify so that we can import them into our harness. The following are the 
   instructions for creating a library package from `list.rs`: 

    a. From TOCK_ROOT: `cd kernel/src/common`

    b. `cargo new list_lib -lib`

    c. `cp list.rs list_lib/src/lib.rs`

    d. Can now import into harness with: 

        extern crate list_lib;
        use list_lib::{List, ListLink, ListNode};


6. Return to the 'tock-verif' directory to run. Currently, the harness works 
   best with: 

        cargo build
        cargo run
-->
