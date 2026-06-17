# NixOS Test VM

This VM is used to test NixOS configuration changes and scripts incrementally.

## Managing the VM

We have created a helper script in `helpers/nixos-vm.nu` to manage the VM lifecycle and snapshots.

### Usage

Run these commands from the root of the dotfiles repository:

#### 1. Create the VM
```bash
nu helpers/nixos-vm.nu create
```
Options (with defaults):
- `--name`: Name of the VM (default: `nixos-test`)
- `--ram`: Memory in MB (default: `8192`)
- `--vcpus`: Number of CPU cores (default: `4`)
- `--disk-size`: Disk size in GB (default: `40`)
- `--iso`: Path to NixOS ISO (default: `~/Downloads/nixos-graphical-26.05.1947.a0374025a863-x86_64-linux.iso`)

#### 2. Start / Stop the VM
- **Start**: `nu helpers/nixos-vm.nu start`
- **Graceful shutdown**: `nu helpers/nixos-vm.nu stop`
- **Force stop**: `nu helpers/nixos-vm.nu destroy`

#### 3. View status
- **Status**: `nu helpers/nixos-vm.nu status`

#### 4. Snapshots
To test configurations incrementally, take snapshots before making major changes.
- **Create snapshot**: `nu helpers/nixos-vm.nu snapshot-create <name> --description "Description of state"`
- **List snapshots**: `nu helpers/nixos-vm.nu snapshot-list`
- **Restore snapshot**: `nu helpers/nixos-vm.nu snapshot-restore <name>`
- **Delete snapshot**: `nu helpers/nixos-vm.nu snapshot-delete <name>`

#### 5. Delete the VM and all its storage
- **Delete**: `nu helpers/nixos-vm.nu delete`

## Graphical Viewer
The VM runs in user space (`qemu:///session`), meaning it has access to your local home files (like the ISO) directly. Since user space is the default connection for your user profile, you can connect to the SPICE screen using:
```bash
virt-viewer nixos-test
```
or by opening `virt-manager` (which defaults to User Session).

## SSH Access
The VM uses user-space networking with port forwarding enabled. Host port `2222` is forwarded to guest port `22`.

To SSH into the VM:
1. In the VM console (via `virt-viewer`), start the SSH daemon and set a password:
   ```bash
   sudo systemctl start sshd
   sudo passwd nixos
   ```
2. From your host terminal, connect using:
   ```bash
   ssh nixos@localhost -p 2222
   ```
