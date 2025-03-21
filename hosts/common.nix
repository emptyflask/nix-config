{ pkgs }:

with pkgs;

{
  fonts = [
    corefonts
    dejavu_fonts
    fira
    fira-code
    fira-code-symbols
    fira-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    roboto
    ubuntu_font_family
    vistafonts
  ];

  packages = [
    arion
    bind
    binutils
    coreutils
    file
    fzf
    git
    gnupg
    gotop
    htop
    hwinfo
    lsof
    neovim
    nmap
    mkpasswd
    openssl
    p7zip
    pciutils
    ripgrep
    rsync
    trashy
    tree
    # unrar
    unzip
    usbutils
    w3m
    wget
    vim
    zip
  ];
}
