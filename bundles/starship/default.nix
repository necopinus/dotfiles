{lib, ...}: {
  programs.starship = {
    enable = true;

    settings = {
      # Define schema (helps with auto-completion in some editors)
      #
      "$schema" = "https://starship.rs/config-schema.json";

      # Actual prompt
      #
      format = lib.concatStrings [
        "[](fg:color_orange)"
        "$os"
        "[](fg:color_orange bg:color_yellow)"
        "$directory"
        "[](fg:color_yellow bg:color_cyan)"
        "$git_branch"
        "$git_status"
        "[](fg:color_cyan bg:color_blue)"
        "$nix_shell"
        "$python"
        "[](fg:color_blue bg:color_bg3)"
        "$cmd_duration"
        "[](fg:color_bg3 bg:color_bg1)"
        "$time"
        "[](fg:color_bg1)"
        "$line_break"
        "$character"
      ];

      add_newline = true;

      # Avoid timeouts in some more complex situations
      #
      scan_timeout = 500; # Default: 30
      command_timeout = 750; # Default: 500

      # Define colors
      #
      palette = "gruvbox_light";

      palettes = {
        gruvbox_dark = {
          color_fg0 = "#fbf1c7";
          color_bg1 = "#3c3836";
          color_bg3 = "#665c54";
          color_blue = "#458588";
          color_cyan = "#689d6a";
          color_green = "#98971a";
          color_orange = "#d65d0e";
          color_purple = "#b16286";
          color_red = "#cc241d";
          color_yellow = "#d79921";
        };
        gruvbox_light = {
          color_fg0 = "#fbf1c7";
          color_bg1 = "#928374";
          color_bg3 = "#665c54";
          color_blue = "#458588";
          color_cyan = "#689d6a";
          color_green = "#98971a";
          color_orange = "#d65d0e";
          color_purple = "#b16286";
          color_red = "#cc241d";
          color_yellow = "#d79921";
        };
      };

      #### Orange ##########################################################

      os = {
        disabled = false;
        symbols = {
          AlmaLinux = "";
          Alpine = "";
          Amazon = "";
          Android = "";
          Arch = "";
          Artix = "";
          CentOS = "";
          Debian = "";
          EndeavourOS = "";
          Fedora = "";
          FreeBSD = "";
          Garuda = "";
          Gentoo = "";
          Illumos = "";
          Kali = "";
          Linux = "";
          Macos = "";
          Manjaro = "";
          Mint = "󰣭";
          NixOS = "";
          Nobara = ""; # Should be "", but Termius' bundle NerdFont isn't sufficiently up-to-date
          OpenBSD = "";
          Pop = "";
          Raspbian = "";
          Redhat = "";
          RedHatEnterprise = "";
          RockyLinux = "";
          SUSE = "";
          Solus = "";
          Ubuntu = "󰕈";
          Unknown = "";
          Void = "";
          Windows = "";
          openSUSE = "";
        };
        style = "bg:color_orange fg:color_fg0";
        format = "[ $symbol $name ]($style)";
      };

      #### Yellow ##########################################################

      directory = {
        style = "fg:color_fg0 bg:color_yellow";
        format = "[ $path ]($style)";
        truncation_length = 4;
        truncation_symbol = "…/";
      };

      #### Cyan ############################################################

      git_branch = {
        symbol = "";
        style = "bg:color_cyan";
        format = "[[ $symbol $branch ](fg:color_fg0 bg:color_cyan)]($style)";
      };

      git_status = {
        style = "bg:color_cyan";
        format = "[[($all_status$ahead_behind )](fg:color_fg0 bg:color_cyan)]($style)";
      };

      #### Blue ############################################################

      nix_shell = {
        disabled = false;
        symbol = "❄"; # TODO: Change to "" once Termius updates the built-in Nerd Fonts to support this character
        style = "bg:color_blue";
        format = "[[ $symbol( $state)( $name) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      python = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version)( $virtualenv) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      #### Light Gray ######################################################

      cmd_duration = {
        disabled = false;
        style = "bg:color_bg3";
        format = "[[  $duration ](fg:color_fg0 bg:color_bg3)]($style)";
      };

      #### Dark Gray #######################################################

      time = {
        disabled = false;
        time_format = "%T";
        style = "bg:color_bg1";
        format = "[[  $time ](fg:color_fg0 bg:color_bg1)]($style)";
      };

      #### Second Line #####################################################

      line_break = {
        disabled = false;
      };

      character = {
        disabled = false;
        success_symbol = "[→](fg:color_green)";
        error_symbol = "[→](fg:color_red)";
        vimcmd_symbol = "[←](fg:color_green)";
        vimcmd_replace_one_symbol = "[←](fg:color_purple)";
        vimcmd_replace_symbol = "[←](fg:color_purple)";
        vimcmd_visual_symbol = "[←](fg:color_yellow)";
      };
    };
  };
}
