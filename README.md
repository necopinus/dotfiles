# Dotfiles

Various configuration files & scripts.

## Pop!_OS on the System76 Darter Pro 5

1. Run `./bin/darter-pro-INSTALL-1.sh`.
2. Get a full sync of OneDrive.
	```bash
	onedrive --confdir=~/.config/onedrive/EcoPunk --synchronize --verbose --resync
	onedrive --confdir=~/.config/onedrive/DelphiStrategy --synchronize --verbose --resync
	```
3. Configure KeePassXC.
4. Replace **XXX** in `~/.config/backup-password` with the **Backup File 7zip Password** from `~/OneDrive/EcoPunk/Documents/KeePass.kdbx`.
5. Run `./bin/darter-pro-INSTALL-2.sh`.
6. Finish configuring applications.

Test
