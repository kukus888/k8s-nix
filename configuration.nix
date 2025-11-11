{ config, pkgs, ... }:

{
  # Základní kernel moduly potřebné pro CNI a overlay FS
  boot.kernelModules = [ "overlay" "br_netfilter" ];

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
  ];

  # Zapnout containerd službu (kubelet povolíme po rebuildu systémově)
  systemd.services.containerd.enable = true;
}