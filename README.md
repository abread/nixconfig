

This repository reuses a lot of the infrastructure setup for [RNL](https://rnl.tecnico.ulisboa.pt) (Rede das Novas Licenciaturas) using Nix[OS], a purely functional Linux distribution built on the Nix package manager.
Check out [their repository](https://gitlab.rnl.tecnico.ulisboa.pt/rnl/nixrnl/) which is bound to have a lot more machines with diverse use cases (even non-NixOS devices and potentially non-computers are in the flake).

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Goals](#goals)
- [How to add a new host?](#how-to-add-a-new-host)
- [How to deploy a new NixOS machine?](#how-to-deploy-a-new-nixos-machine)
- [How to update a machine configuration?](#how-to-update-a-machine-configuration)
- [License](#license)
- [Contact](#contact)

## Goals

- **Mono-repository**: All the infrastructure should be in a single repository.
- **Immutable**: The infrastructure should be immutable and changes should be easy to revert.
- **Versioned**: The infrastructure should be versioned and changes should be easy to track.
- **Reproducible**: The infrastructure should be reproducible and changes should be easy to test.
- **Secure**: The infrastructure should be secure and secrets should be encrypted.
- **Scalable**: The infrastructure should be scalable and easy to extend.

# How to add a new host?

To add a new host, you should create a new file in the `hosts` directory with the hostname of the machine (e.g. if the hostname is `example` the file should be named `example.nix`). \
_This file should import the `core` profile._

Try to look for an existing host with similar characteristics and copy the configuration from there. \
More information about the available profiles can be found in the profiles directory.

## How to deploy a new NixOS machine?

Start a shell with a development environment:
```bash
nix develop
```

And then run the following command to deploy a new machine:
```bash
deploy-anywhere .#<nixosConfiguration> root@<ip/hostname>
```
Description of the arguments:
- `<nixosConfiguration>`: The name of the NixOS configuration to deploy. This is the name of the nixosConfiguration output in the `flake.nix` file.
- `<ip/hostname>`: The IP address or hostname of the machine to deploy to.

After the deployment is complete, you should be able to SSH into the machine.


## How to update a machine configuration?

To deploy a new configuration to a machine, you should run the following command:
```bash
nixos-rebuild <switch/boot> --flake .#<nixosConfiguration> --target-host <ip/hostname>
```
Description of the arguments:
- `<switch/boot>`: Use `switch` to switch to the new configuration without rebooting, or `boot` to only change the configuration on the next boot.
- `<nixosConfiguration>`: The name of the NixOS configuration to deploy. This is the name of the nixosConfiguration output in the `flake.nix` file.
- `<ip/hostname>`: The IP address or hostname of the machine to deploy to.

## Contributing

If you want to contribute to this repository, you should start by creating an issue describing the changes you want to make.
After that, you should fork the repository and clone it:
```bash
git clone <your-fork-url>
```

Then you should create a new branch for your changes:
```bash
git checkout -b <issue-number>-<branch-name>
```

After making your changes, you should commit them and push them to your fork:
```bash
git add <files>
git commit -m "<commit-message>"
git push origin <branch-name>
```
The commit message should be a short description of the changes you made and should follow the convention of the repository.

Finally, you should open a pull request to the main repository.

## License

This repository is licensed under the MIT license.\
See the [LICENSE](LICENSE) file for more details.

