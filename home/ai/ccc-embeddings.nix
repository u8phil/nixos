{
  config,
  ...
}:
{
  # Mistral API key for ccc / LiteLLM code embeddings (codestral-embed-2505).
  # Lives only in secrets/work-vpn.yaml under the `mistral-api-key` key.
  sops.secrets.mistral-api-key = { };

  # Declarative ccc global settings, rendered by sops directly to a 0400 user
  # file. The API key therefore never lands in systemd environment.d
  # (session-wide) nor in the world-readable Nix store; it lives only in this
  # file's `envs:` block, which the ccc daemon (spawned under opencode) injects
  # into its own process. Pre-seeding this file also lets `ccc init` run
  # non-interactively: ccc only prompts for a provider when global settings are
  # missing, which would fail here (no TTY, and the sentence-transformers extra
  # is intentionally not installed). Code embeddings are routed through LiteLLM
  # to Mistral's code-specialized codestral-embed-2505. Changing the model later
  # means editing this file and re-indexing (`ccc reset && ccc index`) because
  # the vector dimensions change.
  sops.templates."cocoindex-global-settings" = {
    path = "/home/phil/.cocoindex_code/global_settings.yml";
    content = ''
      # CocoIndex Code - global settings (managed by Home Manager; do not edit).
      embedding:
        provider: litellm
        model: mistral/codestral-embed-2505
        min_interval_ms: 300
      envs:
        MISTRAL_API_KEY: "${config.sops.placeholder.mistral-api-key}"
    '';
  };
}
