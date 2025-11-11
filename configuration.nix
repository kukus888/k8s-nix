{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];
  boot.kernelModules = [ "overlay" "br_netfilter" ];

  boot.loader.grub.device = "/dev/nvme0n1";

  networking.hostName = "nixos-k8s-cp";

  users.users.kukus888 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  time.timeZone = "Europe/Prague"; 

  # Enable wayland
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Sysctl pro Kubernetes
  networking.sysctl = {
    "net.bridge.bridge-nf-call-iptables"  = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
    "net.ipv4.ip_forward"                 = 1;
  };

  # Vypnout swap deklarativně (pokud máš swap partition nastavenu v configu, vymaž ji)
  swapDevices = [];

  # Nainstalujeme potřebné balíčky (kubeadm/kubelet/kubectl/containerd) do systémového profilu
  environment.systemPackages = with pkgs; [
    containerd
    kubeadm
    kubelet
    kubectl
    curl
    openssl
    # doporučené pro ladění eBPF/Cilium
    bpftool
    # tools
    tmux
    git
    vim
  ];

  # Zapnout containerd službu (kubelet povolíme po rebuildu systémově)
  systemd.services.containerd.enable = true;
}