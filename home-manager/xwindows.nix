# X Windows additional configuration dependent on home-manager
{ config, lib, pkgs, ... }: {
  xdg.configFile."i3/config".text = builtins.readFile ../dotfiles/i3;
  xdg.configFile."discord/settings.json".text = ''
    {
      "BACKGROUND_COLOR": "#202225",
      "SKIP_HOST_UPDATE": true
    }
  '';

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })

    firefox
    vlc
    i3lock-fancy
    ungoogled-chromium
    gwenview # image viewer & editor (crop, resize)
    helvum # pipewire patch bay gui
    iwgtk # iwd gui
    libnotify # required by dunst
    pavucontrol # pulseaudio gui
    qalculate-gtk # calculator
    rofi-power-menu # doesn't work as extra package
  ];

  home.pointerCursor = {
    x11.enable = true;
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    # size = 64;
  };

  programs.i3status.enable = lib.mkDefault true;

  programs.kitty = {
    enable = true;
    font.name = "Hack Nerd Font";
    settings = { enable_audio_bell = false; };
    extraConfig = ''
      map ctrl+shift+enter new_window_with_cwd
    '';
  };

  programs.rofi = {
    package = lib.mkDefault pkgs.rofi;
    enable = true;
    font = "Hack Nerd Font 14";
    plugins = with pkgs; [ rofi-calc rofi-emoji rofi-power-menu ];
  };

  services.dunst = { enable = true; };

  services.flameshot = { enable = true; };

  services.redshift = {
    enable = true;
    dawnTime = "07:00";
    duskTime = "18:00";
    tray = true;
  };

  services.screen-locker = {
    enable = true;
    inactiveInterval = 10; # minutes
    lockCmd =
      "${pkgs.i3lock-fancy}/bin/i3lock-fancy & sleep 5 && xset dpms force off";
    # disable xautolock when mouse in bottom right corner
    xautolock.extraOptions = [ "-corners" "000-" ];
  };

  xsession = {
    enable = true;
    numlock.enable = true;
    initExtra = ''
      # enable gnome-keyring for ssh
      eval $(/run/wrappers/bin/gnome-keyring-daemon --start --daemonize)
      export SSH_AUTH_SOCK

      # https://www.reddit.com/r/swaywm/comments/i6qlos/how_do_i_use_an_ime_with_sway/g1lk4xh?utm_source=share&utm_medium=web2x&context=3
      export GLFW_IM_MODULE=ibus
      export INPUT_METHOD=ibus
      export QT_IM_MODULE=ibus
      export GTK_IM_MODULE=ibus
      export XMODIFIERS=@im=ibus
      export XIM_SERVERS=ibus
    '';
  };
}

