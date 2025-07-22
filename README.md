# CoolBooter-Helper
A TUI bash script for managing partitions on iOS and streamlining the process of using CoolBooter CLI.

### Recommened Dependencies

- OpenSSH or terminal emulator, eg. WhiteTerminal or MobileTerminal (all found in BigBoss repo)
- CoolBooter CLI (http://coolbooter.com), optional if you're running the script on the dualbooted partition
- dualbootstuff (http://angeltheidiot.github.io/archive-repo) optional if you don't plan to resize partitions
- Core Utilities (from BigBoss repo)

### Features

- Streamlined experience for using CoolBooter CLI, such as booting and uninstalling
- Option to reboot device
- Resizing /private/var
- Force uninstall option for clearing broken partitions

### Usage

1. Install from http://angeltheidiot.github.io/archive-repo, and ensure you have the dependedcies installed
2. Open your terminal app (or connect via SSH) and run `cbh`. You may be prompted to enter your device's root password
3. You can now interact with the TUI interface by typing the number of the option you want
