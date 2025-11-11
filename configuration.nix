{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];
  boot.kernelModules = [ "overlay" "br_netfilter" ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/nvme0n1p1";

  networking.hostName = "nixos-k8s-cp";

  users.users.kukus888 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  time.timeZone = "Europe/Prague"; 

  # set language
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable gui
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma6.enable = true;

  # Sysctl pro Kubernetes
  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-iptables"  = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
    "net.ipv4.ip_forward"                 = 1;
  };

  system.stateVersion = "25.05";

  # Turn off swap (kubeadm requirement)
  swapDevices = [];

  environment.systemPackages = with pkgs; [
    containerd
    kubernetes
    curl
    openssl
    # for debugging eBPF/Cilium
    bpftools
    # tools
    tmux
    git
    vim
  ];

  # Zapnout containerd službu (kubelet povolíme po rebuildu systémově)
  systemd.services.containerd.enable = true;
}