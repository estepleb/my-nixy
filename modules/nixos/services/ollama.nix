{ config, lib, pkgs, ... }:
let
  ollamaPort = 11434;
  openWebUiPort = 8083;
  domain = "open-webui.${config.var.tailnet}";
in
{
  config = {
    var.ollamaUrl = "http://127.0.0.1:${toString ollamaPort}";

    environment.systemPackages = with pkgs; [ ollama open-webui ];

    services = {
      ollama = {
        package = pkgs.ollama-vulkan;
        enable = true;
        host = "127.0.0.1";
        port = ollamaPort;
        loadModels = [ 
        "llama3.2:3b" 
        "deepseek-r1:1.5b" 
        "MedAIBase/PaddleOCR-VL:0.9b" 
        "qwen3.5" 
        "gemma4" 
        ];
      };
      open-webui = {
        enable = true;
        port = openWebUiPort;
        environment = {
          ANONYMIZED_TELEMETRY = "False";
          DO_NOT_TRACK = "True";
          SCARF_NO_ANALYTICS = "True";
          OLLAMA_API_BASE_URL = config.var.ollamaUrl;
          WEBUI_AUTH = "False";
        };
      };
      caddy.virtualHosts."${domain}" = {
        extraConfig = ''
          bind tailscale/open-webui
          reverse_proxy 127.0.0.1:${toString openWebUiPort}
        '';
      };
    };
  };
}
