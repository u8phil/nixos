{ pkgs, ... }:
let
  # Editing-only sops identity: an OpenSSH private key kept in KeePassXC and
  # fetched on demand through the browser-integration socket, so it never sits
  # on disk. Activation still decrypts with the machine key
  # (modules/nixos/sops.nix); this one just makes `sops <file>` work.
  # KeePassXC entry: group "devops", URL "devops://nixos", with an additional
  # attribute named "KPH: key" holding the private key (the "KPH: " prefix is
  # what exposes it to browser integration; the helper strips it to "key").
  kpUrl = "devops://nixos";
  kpGroup = "devops";

  helper = "${pkgs.git-credential-keepassxc}/bin/git-credential-keepassxc";

  nixos-sops-ssh-key = pkgs.writeShellApplication {
    name = "nixos-sops-ssh-key";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
    text = ''
      if ! key="$(
        printf 'url=${kpUrl}\n\n' \
          | timeout 90 ${helper} --unlock 0 --group ${kpGroup} get --advanced-fields --json \
          | jq -er '
              if (.string_fields.key | type) == "string"
                 and (.string_fields.key | length) > 0
              then .string_fields.key
              else empty
              end'
      )"; then
        printf '%s\n' 'nixos-sops-ssh-key: could not read the key from KeePassXC (is it running, unlocked, and the ${kpUrl} entry present?)' >&2
        exit 1
      fi

      case "$key" in
        '-----BEGIN OPENSSH PRIVATE KEY-----'*'-----END OPENSSH PRIVATE KEY-----'*) ;;
        *)
          printf '%s\n' 'nixos-sops-ssh-key: KeePassXC KPH: key is not an OpenSSH private key' >&2
          exit 1
          ;;
      esac

      printf '%s\n' "$key"
    '';
  };
in
{
  packages = [
    pkgs.sops
    pkgs.git-credential-keepassxc
    nixos-sops-ssh-key
  ];

  # `sops secrets.yaml` asks KeePassXC for the identity at runtime.
  # Matches the ssh-ed25519 `master` recipient in .sops.yaml.
  env.SOPS_AGE_SSH_PRIVATE_KEY_CMD = "${nixos-sops-ssh-key}/bin/nixos-sops-ssh-key";
}
