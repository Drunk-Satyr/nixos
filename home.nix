{ config, pkgs, system, inputs, ... }:

{
    imports = [
        inputs.zen-browser.homeModules.beta
        # or inputs.zen-browser.homeModules.twilight
        # or inputs.zen-browser.homeModules.twilight-official
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
