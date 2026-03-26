# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# sudo nix-channel --add https://channels.nixos.org/nixos-unstable nixos
# sudo nix-channel --update
# sudo nixos-rebuild switch --upgrade

{ config, pkgs, ... }:
let
    home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
    imports =
        [ # Include the results of the hardware scan.
            ./hardware-configuration.nix
            (import "${home-manager}/nixos")
        ];
    
    nix.settings.experimental-features = ["nix-command" "flakes"];


    # Computer Dependent Settings

    # Kernel
    boot.kernelPackages = pkgs.linuxPackages_latest;
    # boot.kernelPackages = pkgs.linuxPackages_zen;

    # Hostname
    # networking.hostName = "nixosdesktop" # Desktop
    networking.hostName = "nixoslaptop"; # Laptop




    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Kernel Modules
    boot.kernelModules = [ "uinput" ];

    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager = {
        enable = true;
        plugins = with pkgs; [
            networkmanager-openvpn
        ];
    };

    # Set your time zone.
    time.timeZone = "America/Toronto";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_CA.UTF-8";

    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    services.xserver.enable = false;

    # Configure keymap in X11
    services.xserver.xkb = {
        layout = "us";
        variant = "";
    };

    # Support for the xbox controller USB dongle
    hardware.xone.enable = true;

    # Hardware Acceleration
    hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
            rocmPackages.clr.icd # OpenCL
            libva # VA-API
        ];
    };
    hardware.amdgpu.opencl.enable = true;

    # Load amdgpu driver before boot
    boot.initrd.kernelModules = [ "amdgpu" ];

    # Bluetooth
    hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
            General = {
                # Shows battery charge of connected devices on supported
                # Bluetooth adapters. Defaults to 'false'.
                Experimental = true;
                # When enabled other devices can connect faster to us, however
                # the tradeoff is increased power consumption. Defaults to
                # 'false'.
                FastConnectable = false;
            };
            Policy = {
                # Enable all controllers when they are found. This includes
                # adapters present on start as well as adapters that are plugged
                # in later on. Defaults to 'true'.
                AutoEnable = true;
            };
        };
    };

    # Enable CUPS to print documents.
    services.printing = {
        enable = true;
        drivers = with pkgs; [
            cups-filters
            cups-browsed
            gutenprint
            gutenprint-bin
            foomatic-db
            foomatic-db-ppds
            foomatic-db-nonfree
            foomatic-db-ppds-withNonfreeDb
            cups-bjnp
        ];
    };
    services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
    };

    fonts.packages = with pkgs; [
        # jetbrains-mono
        # nerd-fonts.jetbrains-mono
        # ibm-plex
        # inter
        # gohufont
        # nerd-fonts.gohufont
        # ubuntu-sans
        # nerd-fonts.ubuntu
        # fantasque-sans-mono
        # nerd-fonts.fantasque-sans-mono
    ];

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        jack.enable = false;


        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Auto Mounting Drives
    # fileSystems."/run/media/guy/SSD2TB" = {
    #   device = "/dev/disk/by-uuid/860970f3-86e1-453f-a632-ae915cb62195";
    #   fsType = "btrfs";
    #   options = [ # If you don't have this options attribute, it'll default to "defaults"
    #     # boot options for fstab. Search up fstab mount options you can use
    #     "users" # Allows any user to mount and unmount
    #     "nofail" # Prevent system from failing if this drive doesn't mount
    #     "exec"
    #   ];
    # };

    # Security
    security.sudo.extraConfig = ''
    Defaults pwfeedback # Makes typed password visible as asterisks
    Defaults timestamp_timeout=120 # Only ask for password every 2h
  '';

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.guy = {
        isNormalUser = true;
        description = "Guy";
        extraGroups = [ "networkmanager" "wheel" "docker" "audio"];
        packages = with pkgs; [

        ];
    };

    home-manager.users.guy = {
        home.stateVersion = "25.11";
        home.packages = with pkgs; [  ];
        home.file = {
            bashrc = {
                enable = true;
                force = true;
                target = ".bashrc";
                text = ''
                    fastfetch
                    alias ffmpegStart='mkdir -p output && for f in *.{mkv,mp4,avi,mov,ts}; do [ -f "$f" ] || continue; ffmpeg -i "$f" -c:v libx265 -b:v 3600k -bufsize 7200k -ac 2 -b:a 128k -c:s copy -map 0 "output/$(basename "${f%.*}").mkv"; done'
                '';
            };
        };
    
    xdg.enable = true;

    xdg.configFile."niri/config.kdl".force = true;
    xdg.configFile."niri/config.kdl".text = ''
    // https://niri-wm.github.io/niri/Configuration:-Input
    input {
        keyboard {
            xkb {}
            repeat-delay 215
            repeat-rate 35
        }

        touchpad {
            // off
            tap
            // dwt
            // dwtp
            // drag false
            // drag-lock
            // natural-scroll
            // accel-speed 0.2
            // accel-profile "flat"
            // scroll-method "two-finger"
            // disabled-on-external-mouse
        }

        mouse {
            // off
            // natural-scroll
            accel-speed 0.0
            accel-profile "flat"
            // scroll-method "no-scroll"
        }
	focus-follows-mouse max-scroll-amount="0%"

        trackpoint {
            // off
            // natural-scroll
            accel-speed 0.2
            accel-profile "flat"
            // scroll-method "on-button-down"
            // scroll-button 273
            // scroll-button-lock
            // middle-emulation
        }
    }

    /-output "eDP-1" {
        // off
        mode "1920x1080@120.030" // Run `niri msg outputs` while inside a niri instance to list all outputs and their modes.
        scale 1
        transform "normal"
        position x=1280 y=0
    }

    layout {
        // Set gaps around windows in logical pixels.
        gaps 6
        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        focus-ring {
            // off
            width 2
            active-color "#b8bb26"
            inactive-color "#928374"
        }

        border {
            off
            width 4
            active-color "#ffc87f"
            inactive-color "#505050"
            urgent-color "#9b0000"
        }

        shadow {
            // on
            // draw-behind-window true
            softness 30
            spread 5
            offset x=0 y=5
            color "#0007"
        }

        struts {
            // left 64
            // right 64
            // top 64
            // bottom 64
        }
    }

    spawn-at-startup "waybar"
    spawn-at-startup "ktailctl"
    spawn-at-startup "nextcloud"

    // To run a shell command (with variables, pipes, etc.), use spawn-sh-at-startup:
    // spawn-sh-at-startup "qs -c ~/source/qs/MyAwesomeShell"

    hotkey-overlay {
        skip-at-startup
    }

    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    animations {
        // off
        // slowdown 3.0
    }

    window-rule {
        match app-id=r#"^org\.wezfurlong\.wezterm$"#
        default-column-width {}
    }

    window-rule {
        match app-id=r#"firefox$"# title="^Picture-in-Picture$"
        open-floating true
    }

    // (This example rule is commented out with a "/-" in front.)
    /-window-rule {
        match app-id=r#"^org\.keepassxc\.KeePassXC$"#
        match app-id=r#"^org\.gnome\.World\.Secrets$"#

        block-out-from "screen-capture"
    }

    window-rule {
        geometry-corner-radius 12
        clip-to-geometry true
    }

    binds {
        Mod+Shift+Slash { show-hotkey-overlay; }

        Mod+T hotkey-overlay-title="Open a Terminal: foot" { spawn "foot"; }
        Mod+D hotkey-overlay-title="Run an Application: fuzzel" { spawn "fuzzel"; }
        Super+Alt+L hotkey-overlay-title="Lock the Screen: hyprlock" { spawn "hyprlock"; }

        Super+Alt+S allow-when-locked=true hotkey-overlay-title=null { spawn-sh "pkill orca || exec orca"; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
        XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
        XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

        XF86AudioPlay        allow-when-locked=true { spawn-sh "playerctl play-pause"; }
        XF86AudioStop        allow-when-locked=true { spawn-sh "playerctl stop"; }
        XF86AudioPrev        allow-when-locked=true { spawn-sh "playerctl previous"; }
        XF86AudioNext        allow-when-locked=true { spawn-sh "playerctl next"; }

        XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }

        Mod+O repeat=false { toggle-overview; }
        Mod+Q repeat=false { close-window; }

        Mod+Left  { focus-column-left; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }
        Mod+Right { focus-column-right; }
        Mod+H     { focus-column-left; }
        Mod+J     { focus-window-down; }
        Mod+K     { focus-window-up; }
        Mod+L     { focus-column-right; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Down  { move-window-down; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+H     { move-column-left; }
        Mod+Shift+J     { move-window-down; }
        Mod+Shift+K     { move-window-up; }
        Mod+Shift+L     { move-column-right; }

        Mod+Home { focus-column-first; }
        Mod+End  { focus-column-last; }
        Mod+Shift+Home { move-column-to-first; }
        Mod+Shift+End  { move-column-to-last; }

        Mod+Ctrl+Left  { focus-monitor-left; }
        Mod+Ctrl+Down  { focus-monitor-down; }
        Mod+Ctrl+Up    { focus-monitor-up; }
        Mod+Ctrl+Right { focus-monitor-right; }
        Mod+Ctrl+H     { focus-monitor-left; }
        Mod+Ctrl+J     { focus-monitor-down; }
        Mod+Ctrl+K     { focus-monitor-up; }
        Mod+Ctrl+L     { focus-monitor-right; }

        Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
        Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }

        Mod+Page_Down      { focus-workspace-down; }
        Mod+Page_Up        { focus-workspace-up; }
        Mod+U              { focus-workspace-down; }
        Mod+I              { focus-workspace-up; }
        Mod+Shift+Page_Down { move-column-to-workspace-down; }
        Mod+Shift+Page_Up   { move-column-to-workspace-up; }
        Mod+Shift+U         { move-column-to-workspace-down; }
        Mod+Shift+I         { move-column-to-workspace-up; }

        Mod+Ctrl+Page_Down { move-workspace-down; }
        Mod+Ctrl+Page_Up   { move-workspace-up; }
        Mod+Ctrl+U         { move-workspace-down; }
        Mod+Ctrl+I         { move-workspace-up; }

        Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
        Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
        Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

        Mod+WheelScrollRight      { focus-column-right; }
        Mod+WheelScrollLeft       { focus-column-left; }
        Mod+Shift+WheelScrollRight { move-column-right; }
        Mod+Shift+WheelScrollLeft  { move-column-left; }

        Mod+Shift+WheelScrollDown      { focus-column-right; }
        Mod+Shift+WheelScrollUp        { focus-column-left; }
        Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
        Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        // Switches focus between the current and the previous workspace.
        // Mod+Tab { focus-workspace-previous; }

        Mod+BracketLeft  { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }

        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+Ctrl+R { reset-window-height; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        Mod+M { maximize-window-to-edges; }

        Mod+Ctrl+F { expand-column-to-available-width; }

        Mod+C { center-column; }

        Mod+Ctrl+C { center-visible-columns; }

        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }

        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        Mod+V       { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }

        Mod+W { toggle-column-tabbed-display; }


        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

        Mod+Shift+E { quit; }
        Ctrl+Alt+Delete { quit; }

        Mod+Shift+P { power-off-monitors; }
    }
  '';

    xdg.configFile."waybar/config.jsonc".force = true;
    # https://github.com/MBestKing/dotfiles/blob/main/waybar/config.jsonc
    xdg.configFile."waybar/config.jsonc".text = ''
    {
        "layer": "top",
        "mod": "dock",
        "exclusive": true,
        "passthrough": false,
        "gtk-layer-shell": true,
        "reload_style_on_change": true,
        "height": 30,
        "margin-left": 0,
        "margin-right": 0,
        "margin-top": 0,
        "margin-bottom": 0,
        "spacing": 0,

        "modules-left": [
            "tray"
        ],

        "modules-center": [
            "clock",
        ],

        "modules-right": [
            "network",
	    "bluetooth",
            "pulseaudio"
	],

        "tray": {
            "icon-size": 16,
            "spacing": 6
        },

        "clock": {
            "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
            "format": "{:%I:%M %p}",
            "format-alt": "{:%m-%d-%Y}"
        },

	"network": {
            "tooltip": true,
            "format-wifi": "{icon} ",
            "format-icons": ["󰤟", "󰤢", "󰤥"],
            "format-ethernet": "󰈀 ",
            "tooltip-format": "Network: <big><b>{essid}</b></big>\nSignal strength: <b>{signaldBm}dBm ({signalStrength}%)</b>\nFrequency: <b>{frequency}MHz</b>\nInterface: <b>{ifname}</b>\nIP: <b>{ipaddr}/{cidr}</b>\nGateway: <b>{gwaddr}</b>\nNetmask: <b>{netmask}</b>",
            "format-linked": "󰈀 {ifname} (No IP)",
            "format-disconnected": " ",
            "tooltip-format-disconnected": "Disconnected",
            "on-click": "foot wifitui",
            "interval": 2
        },

	"bluetooth": {
	    "format-on": "󰂯",
            "format-off": "󰂲",
            "format-disabled": "", // an empty format will hide the module
            "format-connected": "󰂱 {num_connections}",
            "tooltip-format-connected": "{device_enumerate}",
            "tooltip-format-enumerate-connected": "{device_alias}\t{device_address}",
	    "on-click": "foot bluetui"
	},

        "pulseaudio": {
            "format": "{icon}",
            "rotate": 0,
            "format-muted": "x",
            "tooltip-format": "{icon} {desc} {volume}%",
            "scroll-step": 5,
            "format-icons": {
                "headphone": "",
                "hands-free": "",
                "headset": "",
                "phone": "",
                "portable": "",
                "car": "",
                "default": ["", "", ""]
            },
	    "on-click": "foot wiremix"
        },
    };
  '';

    xdg.configFile."waybar/style.css".force = true;
    xdg.configFile."waybar/style.css".text = ''
  
    * {
      font-family: "Fantasque Sans Mono";
      font-size: 18px;
      color: #ebdbb2;
      padding: 0;
    }

    tooltip, .tooltip {
      background: #282828;
      color: #ebdbb2;
      border-radius: 0px;
      padding: 10px 12px;
      box-shadow: none;
      padding: 0;
    }

    window#waybar {
      background: #282828;
      border-radius: 0px;
      border: none;
      padding: 0;
      margin: 0;
    }

    #network, #bluetooth, #pulseaudio {
      padding: 0 10px 0 6px;
    }

  '';

    xdg.configFile."fuzzel/fuzzel.ini".force = true;
    xdg.configFile."fuzzel/fuzzel.ini".text = ''
    font='Fantasque Sans Mono'
    dpi-aware=no
    prompt=">  "
    icons-enabled=no
    fuzzy=yes
    terminal=foot
    lines=10
    width=40
    tabs=3
    horizontal-pad=4
    vertical-pad=4
    inner-pad=5

    [colors]
    background=282828ff
    text=ebdbb2ff
    prompt=98971aff
    placeholder=928374ff
    input=b8bb26ff
    match=b8bb26ff
    selection=ebdbb2ff
    selection-text=282828ff
    selection-match=98971aff
    counter=7f849cff
    border=b8bb26ff

    [border]
    width=2
    radius=2
  '';

        # Waybar Config
        programs.waybar = {
            enable = true;
        };
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        wget
        git
        curl
        bluetui
        # wifitui
        # wiremix
        # btop
        ranger
        keyd
        tldr
        ffmpeg-full
        man
        mangohud
        fastfetch
        docker
        fuse
        fuse3
        nextcloud-client
        # ktailctl
        usbutils
        evtest
        SDL2
        freerdp
        libblockdev
        libnvme
        docker
        nix-prefetch-github
        love
        protonplus
        vlc
        heroic
        kdePackages.kdenlive
        lmms
        # localsend
        keepassxc
        discord
        gearlever
        # pcsx2
        # rpcs3
        # xemu
        # dolphin-emu
        # retroarch-full
        # retroarch-assets
        # ryubing
        bottles
        faugus-launcher
        # cemu
        gimp
        onlyoffice-desktopeditors
        github-desktop
        moonlight-qt
        
        # rofi
        # fuzzel
        # hypridle
        # hyprlock
        # wlogout
        # mako
        # waybar
        # noctalia-shell

        # base16-schemes
        # nwg-look
        # kdePackages.qt6ct
        # gruvbox-gtk-theme
        # gruvbox-plus-icons
        # capitaine-cursors-themed

        gnomeExtensions.paperwm
        gnomeExtensions.appindicator
        trayscale
    ];
    
    qt = {
        enable = true;
        platformTheme = "gnome";
        style = "adwaita-dark";
    };

    # Docker
    virtualisation.docker.enable = true;
    #virtualisation.docker.storageDriver = "btrfs";
    #users.extraGroups.docker.members = [ "guy" ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    services.displayManager.ly.enable = false;
    programs.niri = {
        enable = false;
        useNautilus = true;
    };

    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    environment.gnome.excludePackages = with pkgs; [
        epiphany
    ];
    programs.dconf.profiles.user.databases = [
        {
            lockAll = true;
            settings = {
                "org/gnome/desktop/interface" = {
                        color-scheme = "prefer-dark";
                        accent-color = "yellow";
                        show-battery-percentage = true;
                };
            };
        }
    ];

    
    # Running non-nix executables
    programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
            ## Put here any library that is required when running a package
            ## ...
            ## Uncomment if you want to use the libraries provided by default in the steam distribution
            ## but this is quite far from being exhaustive
            ## https://github.com/NixOS/nixpkgs/issues/354513
            (pkgs.runCommand "steamrun-lib" {} "mkdir $out; ln -s ${pkgs.steam-run.fhsenv}/usr/lib64 $out/lib")
            icu
            libICE
            libSM
        ];
    };

    # Disable Nano
    programs.nano.enable = false;

    # Neovim / Nvim
    programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        configure = {
            customRC = ''
        " here your custom VimScript configuration goes!
        colorscheme retrobox
      '';
            customLuaRC = ''
        -- here your custom Lua configuration goes!
        vim.opt.number = true
        vim.opt.swapfile = false
        vim.opt.backup = false
        vim.opt.undofile = true
        vim.opt.tabstop = 4
        vim.opt.softtabstop = 4
        vim.opt.shiftwidth = 4
        vim.opt.expandtab = true
        vim.opt.autoindent = true
        vim.opt.smartindent = true
        vim.opt.syntax = "on"
        vim.opt.incsearch = true
        vim.opt.inccommand = "split"
        vim.opt.ignorecase = true
        vim.opt.smartcase = true
        vim.opt.termguicolors = true
        vim.opt.background = "dark"
        vim.opt.scrolloff = 8
        vim.opt.signcolumn = "yes"
        vim.opt.backspace = {"start", "eol", "indent"}
        vim.opt.splitright = true
        vim.opt.splitbelow = true
        vim.opt.updatetime = 50
        vim.opt.clipboard:append("unnamedplus")
        vim.opt.hlsearch = true
        vim.opt.mouse = "a"
        vim.g.editorconfig = true
      '';
        };
    };

    programs.foot = {
        enable = false;
        theme = "gruvbox";
        settings = {
            main = {
                font = "Fantasque Sans Mono:size=13";
            };
            scrollback = {
                lines = 1000000;
            };
        };
    }; 

    # Gamemode
    programs.gamemode.enable = true;

    # Gamescope
    programs.gamescope = {
        enable = true;
        capSysNice = true;
    };

    # AppImages
    programs.appimage.enable = true;
    programs.appimage.binfmt = true;

    # Install firefox.
    programs.firefox.enable = true;

    # Steam
    programs.steam = {
        enable = true;
        package = pkgs.steam.override {
            extraEnv = {
                MANGOHUD = "1";
                MANGOHUD_CONFIG = "read_cfg,no_display";
                PROTON_USE_NTSYNC = true;
            };
        };
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
        gamescopeSession.enable = true;
        protontricks.enable = true; # Install Protontricks
    };

    # OBS Studio
    programs.obs-studio = {
        enable = true;
        # optional Nvidia hardware acceleration
        package = (
            pkgs.obs-studio.override {
                #cudaSupport = true;
            }
        );
        plugins = with pkgs.obs-studio-plugins; [
            wlrobs
            obs-backgroundremoval
            obs-pipewire-audio-capture
            obs-vaapi #optional AMD hardware acceleration
            obs-gstreamer
            obs-vkcapture
        ];
    };

    # List services that you want to enable:

    # OpenSSH
    services.openssh.enable = true;

    # Firmware Updates
    services.fwupd.enable = true;

    # Flatpak
    services.flatpak = {
        enable = true;
    };

    # Tailscale
    services.tailscale.enable = true;

    # Imput Plumber
    services.inputplumber.enable = true;

    # Sunshine
    services.sunshine = {
        enable = false;
        autoStart = true;
        capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
        openFirewall = true;
    };

    # Keyd
    services.keyd = {
        enable = true;
        keyboards = {
            default = {
                ids = [ "0c45:767d:cb84b8cd" "0001:0001:09b4e68d"];
                settings = {
                    main = {
                        rightalt = "layer(nav)";
                    };
                    nav = {
                        h = "left";
                        j = "down";
                        k = "up";
                        l = "right";
                        q = "home";
                        e = "end";
                        backspace = "delete";
                    };
                };
            };
        };
    };



    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11"; # Did you read the comment?

}
