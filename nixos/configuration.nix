# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "fabricant-vaultwarden"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.interfaces.ens18.ipv4.addresses = [
    {
      address = "132.239.95.107";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "132.239.95.1";
  networking.nameservers = [ "1.1.1.1" ];

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fabricant-admin = {
    isNormalUser = true;
    description = "Fabricant Admin";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2Z7LbaDPTNkdnuvFivXTUx8X9gU0ZyWrrYBH7KSmG3 chris@chris-laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIILwsfYNsl6DSg00wOjvTip7GwO+aANfEBn6T3YcAHNG seanh@siloenvy"
    ];
    packages = with pkgs; [];
  };

  users.users."c.crutchfield.642" = {
    isNormalUser = true;
    description = "Christopher Crutchfield";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2Z7LbaDPTNkdnuvFivXTUx8X9gU0ZyWrrYBH7KSmG3 chris@chris-laptop"
    ];
    initialHashedPassword = "$6$w2DjXVZz4/c3NRAC$bIdyTZwZ.Zm26Fh3TSHITus2OhHRweHxGBYrfWe/jGDKIV4WwGbEoycKZKiHVZ53mqUwQRLoTyKK7vWkrpmw70";
    packages = with pkgs; [];
  };

  users.users."s.perry.543" = {
    isNormalUser = true;
    description = "Sean Perry";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIILwsfYNsl6DSg00wOjvTip7GwO+aANfEBn6T3YcAHNG seanh@siloenvy"
    ];
    initialHashedPassword = "$6$rounds=656000$K2VO4J5uMFE3Eb6A$exJwg.2to2a.wP.X/8DSLKz1kJoe9hiP.SmjMg.TzFLPbxsmurhdYCbUYW.naPljdVgtAr9nlERdSR8GObOGb1";
    packages = with pkgs; [];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    tmux
  #  wget
    #ryantm/agenix
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.eable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?


  # ENABLE PODMAN
  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    oci-containers.backend = "podman";

    podman = {
      enable = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  virtualisation.oci-containers.containers = {
    traefik = {
      autoStart = true;
      image = "traefik:v3.6";
      ports = [
        "80:80"
        "443:443"
        "8080:8080"
      ];
      volumes = [
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
        "/home/fabricant-admin/fabricant-vaultwarden/traefik-data/letsencrypt:/letsencrypt:z"
      ];
      cmd = [
        "--log.level=DEBUG"
        "--api.insecure=true"
        "--providers.docker=true"
        "--providers.docker.exposedbydefault=false"
        "--entrypoints.web.address=:80"
        "--entrypoints.web.http.redirections.entryPoint.to=websecure"
        "--entrypoints.web.http.redirections.entryPoint.scheme=https"
        "--entrypoints.web.http.redirections.entryPoint.permanent=true"
        "--entrypoints.websecure.address=:443"
        "--certificatesresolvers.letsencrypt.acme.httpchallenge=true"
        "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
        "--certificatesresolvers.letsencrypt.acme.email=e4e@ucsd.edu"
        "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      #  "--certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory" # Use Let's Encrypt staging server for testing
        "--providers.docker.network=traefik_proxy"
        "--metrics.prometheus=true"
      ];
      networks = [
        "traefik_proxy"
      ];
    };
    #vault_warden = {
    #  autoStart=true;
    #  image="vaultwarden/server:1.34.3";
    #  container_name="vaultwarden";
    #  environment={
    #    SIGNUPS_ALLOWED: "true";
    #    ADMIN_TOKEN_FILE: "/run/secrets/vaultwarden_admin_token";
    #    DOMAIN: "https://vault.e4e-gateway.ucsd.edu";
    #  }
    #  volumes=[
    #    "./vaultwarden-data:/data"
    #  ];
    #  networks = [
    #    traefik_proxy
    #  ];
    #  labels={
    #    "traefik.enable"= "true";
    #    "traefik.http.routers.authentik_server.rule" = "Host(`https://vault.e4e-gateway.ucsd.edu`)";
    #    "traefik.http.routers.authentik_server.entrypoints" = "websecure";
    #    "traefik.http.routers.authentik_server.tls.certresolver" = "letsencrypt";
    #  };

    # TODO
    #secrets:
    #  - vaultwarden_admin_token
    #}
  };
}
