{
  config,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;

    # Disable bash and zsh integration, as these shells (generally) get
    # used in terminals for which I can't set the color scheme
    #
    enableBashIntegration = false;
    enableZshIntegration = false;

    settings = {
      # Define schema (helps with auto-completion in some editors)
      #
      "$schema" = "https://starship.rs/config-schema.json";

      # Actual prompt
      #
      format = lib.concatStrings [
        "[](color_orange)"
        "$os"
        "$username"
        "[](bg:color_yellow fg:color_orange)"
        "$directory"
        "[](fg:color_yellow bg:color_cyan)"
        "$git_branch"
        "$git_status"
        "[](fg:color_cyan bg:color_blue)"
        "$c"
        "$cpp"
        "$golang"
        "$haskell"
        "$java"
        "$kotlin"
        "$lua"
        "$nodejs"
        "$perl"
        "$php"
        "$python"
        "$ruby"
        "$rust"
        "$solidity"
        "$swift"
        "[](fg:color_blue bg:color_bg3)"
        "$cmake"
        "$conda"
        "$docker_context"
        "$gradle"
        "$nix_shell"
        "$pixi"
        "$cmd_duration"
        "[](fg:color_bg3 bg:color_bg1)"
        "$time"
        "[](fg:color_bg1)"
        "$line_break"
        "$character"
      ];

      add_newline = false;

      # Define colors
      #
      palette = "gruvbox_light";

      palettes = {
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
        style = "bg:color_orange fg:color_fg0";
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
          Nobara = "";
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
      };

      username = {
        show_always = true;
        style_user = "bg:color_orange fg:color_fg0";
        style_root = "bg:color_orange fg:color_fg0";
        format = "[ $user ]($style)";
      };

      #### Yellow ##########################################################

      directory = {
        style = "fg:color_fg0 bg:color_yellow";
        format = "[ $path ]($style)";
        truncation_length = 3;
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

      c = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      cmake = {
        disabled = true;
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      cpp = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      docker_context = {
        disabled = true;
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $context) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      gradle = {
        disabled = true;
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      haskell = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      java = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      kotlin = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      lua = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      nix_shell = {
        disabled = false;
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $state)( $name) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      nodejs = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      perl = {
        disabled = true;
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      php = {
        disabled = true;
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      python = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version)( $virtualenv) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      ruby = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      solidity = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      swift = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      #### Light Gray ######################################################

      cmd_duration = {
        disabled = false;
        style = "bg:color_bg3";
        format = "[[  $duration ](fg:color_fg0 bg:color_bg3 bold)]($style)";
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
        success_symbol = "[](bold fg:color_green)";
        error_symbol = "[](bold fg:color_red)";
        vimcmd_symbol = "[](bold fg:color_green)";
        vimcmd_replace_one_symbol = "[](bold fg:color_purple)";
        vimcmd_replace_symbol = "[](bold fg:color_purple)";
        vimcmd_visual_symbol = "[](bold fg:color_yellow)";
      };
    };
  };
  home.sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";
}
