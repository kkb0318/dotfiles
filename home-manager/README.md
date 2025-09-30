

```~/.config/nix/nix.conf 
# Nix Flakesの機能を有効化
experimental-features = nix-command flakes
```

```bash
nix run home-manager/master -- init --switch
```
