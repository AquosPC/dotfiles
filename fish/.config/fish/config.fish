source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# starship prompt
starship init fish | source

# Amp CLI
fish_add_path "$HOME/.local/bin"
