{
  lib,
  config,
  ...
}: {
  programs.starship = {
    enable = true;

    # TODO: Unify if/then/else blocks once the Android Terminal supports
    # custom fonts

    settings = {
      # Define schema (helps with auto-completion in some editors)
      #
      "$schema" = "https://starship.rs/config-schema.json";

      # Actual prompt
      #
      format = lib.concatStrings [
        (
          if ("${config.home.username}" == "droid")
          then "[ ](fg:color_orange)"
          else "[](fg:color_orange)"
        )
        "$os"
        (
          if ("${config.home.username}" == "droid")
          then "[ ](fg:color_orange bg:color_yellow)"
          else "[](fg:color_orange bg:color_yellow)"
        )
        "$directory"
        (
          if ("${config.home.username}" == "droid")
          then "[ ](fg:color_yellow bg:color_cyan)"
          else "[](fg:color_yellow bg:color_cyan)"
        )
        "$git_branch"
        "$git_status"
        (
          if ("${config.home.username}" == "droid")
          then "[ ](fg:color_cyan bg:color_blue)"
          else "[](fg:color_cyan bg:color_blue)"
        )
        "$nix_shell"
        "$python"
        (
          if ("${config.home.username}" == "droid")
          then "[ ](fg:color_blue bg:color_bg3)"
          else "[](fg:color_blue bg:color_bg3)"
        )
        "$cmd_duration"
        (
          if ("${config.home.username}" == "droid")
          then "[ ](fg:color_bg3 bg:color_bg1)"
          else "[](fg:color_bg3 bg:color_bg1)"
        )
        "$time"
        (
          if ("${config.home.username}" == "droid")
          then "[ ](fg:color_bg1)"
          else "[](fg:color_bg1)"
        )
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
          AlmaLinux =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Alpine =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Amazon =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Android =
            if ("${config.home.username}" == "droid")
            then "◔"
            else "";
          Arch =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Artix =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          CentOS =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Debian =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          EndeavourOS =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Fedora =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          FreeBSD =
            if ("${config.home.username}" == "droid")
            then "◔"
            else "";
          Garuda =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Gentoo =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Illumos =
            if ("${config.home.username}" == "droid")
            then "◔"
            else "";
          Kali =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Linux =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Macos =
            if ("${config.home.username}" == "droid")
            then "◔"
            else "";
          Manjaro =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Mint =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "󰣭";
          NixOS =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Nobara =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          OpenBSD =
            if ("${config.home.username}" == "droid")
            then "◔"
            else "";
          Pop =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Raspbian =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Redhat =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          RedHatEnterprise =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          RockyLinux =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          SUSE =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Solus =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Ubuntu =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "󰕈";
          Unknown =
            if ("${config.home.username}" == "droid")
            then "◔"
            else "";
          Void =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
          Windows =
            if ("${config.home.username}" == "droid")
            then "◔"
            else "";
          openSUSE =
            if ("${config.home.username}" == "droid")
            then "◕"
            else "";
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
        symbol =
          if ("${config.home.username}" == "droid")
          then "⌥"
          else "";
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
        symbol =
          if ("${config.home.username}" == "droid")
          then "꩜"
          else "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version)( $virtualenv) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      #### Light Gray ######################################################

      cmd_duration = {
        disabled = false;
        style = "bg:color_bg3";
        format =
          if ("${config.home.username}" == "droid")
          then "[[ ⧗ $duration ](fg:color_fg0 bg:color_bg3)]($style)"
          else "[[  $duration ](fg:color_fg0 bg:color_bg3)]($style)";
      };

      #### Dark Gray #######################################################

      time = {
        disabled = false;
        time_format = "%T";
        style = "bg:color_bg1";
        format =
          if ("${config.home.username}" == "droid")
          then "[[ ⏲ $time ](fg:color_fg0 bg:color_bg1)]($style)"
          else "[[  $time ](fg:color_fg0 bg:color_bg1)]($style)";
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
