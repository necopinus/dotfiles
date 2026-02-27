{
  config,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;

    # Move the Starship config into a subdirectory of XDG_CONFIG_HOME
    # so as to make sandboxing easier
    #
    configPath = "${config.xdg.configHome}/starship/starship.toml";

    settings = {
      # Define schema (helps with auto-completion in some editors)
      #
      "$schema" = "https://starship.rs/config-schema.json";

      # Actual prompt
      #
      format = lib.concatStrings [
        "[](fg:color_orange)" # TODO: Replace with "[](fg:color_orange)" once the Android Terminal supports custom fonts
        "$os"
        "$shell"
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
        "[](fg:color_bg1)" # TODO: Replace with "[](fg:color_bg1)" once the Android Terminal supports custom fonts
        "$line_break"
        "$character"
      ];

      add_newline = true;

      # Android VM startup takes longer than the default scan scan
      # timeout
      #
      scan_timeout = 100;

      # Define colors
      #
      palette = "term_dark"; # TODO: Change to "gruvbox_light" once the Android Terminal supports custom themes

      palettes = {
        term_dark = {
          color_fg0 = "bright-white";
          color_fg1 = "white";
          color_bg1 = "bright-black";
          color_bg3 = "blue";
          color_blue = "cyan";
          color_cyan = "green";
          color_green = "bright-green";
          color_orange = "red";
          color_purple = "purple";
          color_red = "bright-red";
          color_yellow = "yellow";
        };
        gruvbox_light = {
          color_fg0 = "#fbf1c7";
          color_fg1 = "#ebdbb2";
          color_bg1 = "#3c3836";
          color_bg3 = "#7c6f64";
          color_blue = "#076678";
          color_cyan = "#427b58";
          color_green = "#79740e";
          color_orange = "#af3a03";
          color_purple = "#8f3f71";
          color_red = "#9d0006";
          color_yellow = "#b57614";
        };
        gruvbox_material_light_hard = {
          color_fg0 = "#f9f5d7";
          color_fg1 = "#f3eac7";
          color_bg1 = "#654735";
          color_bg3 = "#7c6f64";
          color_blue = "#45707a";
          color_cyan = "#4c7a5d";
          color_green = "#6c782e";
          color_orange = "#c35e0a";
          color_purple = "#945e80";
          color_red = "#c14a4a";
          color_yellow = "#b47109";
        };
      };

      #### Orange ##########################################################

      os = {
        disabled = false;
        symbols = {
          AlmaLinux = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Alpine = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Amazon = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Android = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Arch = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Artix = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          CentOS = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Debian = "◕"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          EndeavourOS = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Fedora = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          FreeBSD = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Garuda = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Gentoo = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Illumos = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Kali = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Linux = "◕"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Macos = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Manjaro = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Mint = "◔"; # TODO: Replace with "󰣭" once the Android Terminal supports custom fonts
          NixOS = "◕"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Nobara = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          OpenBSD = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Pop = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Raspbian = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Redhat = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          RedHatEnterprise = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          RockyLinux = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          SUSE = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Solus = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Ubuntu = "◔"; # TODO: Replace with "󰕈" once the Android Terminal supports custom fonts
          Unknown = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Void = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          Windows = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
          openSUSE = "◔"; # TODO: Replace with "" once the Android Terminal supports custom fonts
        };
        style = "bg:color_orange fg:color_fg0";
        format = "[ $symbol]($style)";
      };

      shell = {
        disabled = false;
        bash_indicator = "bash";
        fish_indicator = "fish";
        zsh_indicator = "zsh";
        powershell_indicator = "pwsh";
        ion_indicator = "ion";
        elvish_indicator = "elvish";
        tcsh_indicator = "tcsh";
        xonsh_indicator = "xonsh";
        cmd_indicator = "cmd";
        nu_indicator = "nu";
        unknown_indicator = "----";
        style = "bg:color_orange fg:color_fg0";
        format = "[ $indicator ]($style)";
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
        symbol = "⌥"; # TODO: Replace with "" once the Android Terminal supports custom fonts
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
        symbol = "❄"; # TODO: Replace with "" once the Android Terminal supports custom fonts
        style = "bg:color_blue";
        format = "[[ $symbol( $state)( $name) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      python = {
        symbol = "꩜"; # TODO: Replace with "" once the Android Terminal supports custom fonts
        style = "bg:color_blue";
        format = "[[ $symbol( $version)( $virtualenv) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      #### Light Gray ######################################################

      cmd_duration = {
        disabled = false;
        style = "bg:color_bg3";
        format = "[[ ⧗ $duration ](fg:color_fg0 bg:color_bg3 bold)]($style)"; # TODO: Replace with "[[  $duration ](fg:color_fg0 bg:color_bg3 bold)]($style)" once the Android Terminal supports custom fonts
      };

      #### Dark Gray #######################################################

      time = {
        disabled = false;
        time_format = "%T";
        style = "bg:color_bg1";
        format = "[[ ⏲ $time ](fg:color_fg0 bg:color_bg1)]($style)"; # TODO: Replace with "[[  $time ](fg:color_fg0 bg:color_bg1)]($style)" once the Android Terminal supports custom fonts
      };

      #### Second Line #####################################################

      line_break = {
        disabled = false;
      };

      character = {
        disabled = false;
        success_symbol = "[→](bold fg:color_green)"; # TODO: Replace with "[](bold fg:color_green)" once the Android Terminal supports custom fonts
        error_symbol = "[→](bold fg:color_red)"; # TODO: Replace with "[](bold fg:color_red)" once the Android Terminal supports custom fonts
        vimcmd_symbol = "[→](bold fg:color_green)"; # TODO: Replace with "[](bold fg:color_green)" once the Android Terminal supports custom fonts
        vimcmd_replace_one_symbol = "[→](bold fg:color_purple)"; # TODO: Replace with "[](bold fg:color_purple)" once the Android Terminal supports custom fonts
        vimcmd_replace_symbol = "[→](bold fg:color_purple)"; # TODO: Replace with "[](bold fg:color_purple)" once the Android Terminal supports custom fonts
        vimcmd_visual_symbol = "[→](bold fg:color_yellow)"; # TODO: Replace with "[](bold fg:color_yellow)" once the Android Terminal supports custom fonts
      };
    };
  };

  home.sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";
}
