{ config, pkgs, system, inputs, ... }: {
    imports = [
        inputs.zen-browser.homeModules.beta
        # or inputs.zen-browser.homeModules.twilight
        # or inputs.zen-browser.homeModules.twilight-official

        inputs.nixcord.homeModules.nixcord
    ];

    home.username = "caro";
    home.homeDirectory = "/home/caro";

    # Packages that should be installed to the user profile.
    home.packages = with pkgs; [
        # cli utilities
        zip
        xz
        unzip
        p7zip
        oh-my-zsh
        oh-my-posh

        # game managers
        prismlauncher
        steam

        # gui tools
        gimp
        blender
        openscad

        # media
        jellyfin-desktop

        # messaging
        # discord
        # betterdiscordctl
    ];

    # basic configuration of git, please change to your own
    programs.git = {
        enable = true;
        userName = "DrunkSatyr";
        userEmail = "caro@drunksatyr.dev";
        extraConfig = {
            init.defaultBranch = "main";
        };
    };

    programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;
    };

    programs.nixcord = {
        enable = true;

        # Choose your Discord mod client (enable at most one of these two)
        discord.vencord.enable = true;      # Standard Vencord
        # discord.equicord.enable = true;   # Equicord (has more plugins)

        # Or these
        vesktop.enable = true;
        # dorion.enable = true;
        # legcord.enable = true;

        # Theming
        quickCss = "/* css goes here */";
        config = {
            useQuickCss = true;
            themeLinks = [
                # "https://raw.githubusercontent.com/PL7963/Discord-Mica/refs/heads/main/discord-mica.theme.css"
            ];
            frameless = true;

            plugins = {
                hideMedia.enable = true;
                ignoreActivities = {
                    enable = true;
                    ignorePlaying = true;
#                     ignoredActivities = [
#                         { id = "game-id"; name = "League of Legends"; type = 0; }
#                     ];
                };
            };
        };
    };

    # This value determines the home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update home Manager without changing this value. See
    # the home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "26.05";

    # Let home Manager install and manage itself.
    programs.home-manager.enable = true;
}
