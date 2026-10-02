{config, ...}: {
  # Admin password created with:
  #   echo '<password>' | agenix -e secrets/paperless-admin-pass.age
  age.secrets.paperless-admin-pass.file = ../../../secrets/paperless-admin-pass.age;
  # OpenRouter API key (PAPERLESS_AI_LLM_API_KEY=<key>), created with:
  #   echo '<key>' | agenix -i ~/.ssh/id_agenix -e secrets/paperless-ai.env.age
  age.secrets.paperless-ai-env.file = ../../../secrets/paperless-ai.env.age;

  services.paperless = {
    enable = true;
    address = "127.0.0.1";
    port = 28981;
    database.createLocally = true;
    configureTika = true;
    passwordFile = config.age.secrets.paperless-admin-pass.path;
    environmentFile = config.age.secrets.paperless-ai-env.path;
    settings = {
      PAPERLESS_URL = "https://paperless.newton.lan";
      PAPERLESS_OCR_LANGUAGE = "eng";
      # Per-user FTP scan dirs (see ./scan-ftp.nix): consume/<name>/... gets
      # picked up recursively and each person's scans auto-tagged with <name>.
      PAPERLESS_CONSUMER_RECURSIVE = true;
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;

      # AI (via OpenRouter, OpenAI-compatible API). API key lives in
      # paperless-ai-env above (PAPERLESS_AI_LLM_API_KEY).
      PAPERLESS_AI_ENABLED = true;
      PAPERLESS_AI_LLM_BACKEND = "openai-like";
      PAPERLESS_AI_LLM_MODEL = "deepseek/deepseek-v4-flash-0731";
      PAPERLESS_AI_LLM_ENDPOINT = "https://openrouter.ai/api/v1";
      PAPERLESS_AI_LLM_EMBEDDING_BACKEND = "openai-like";
      PAPERLESS_AI_LLM_EMBEDDING_MODEL = "qwen/qwen3-embedding-8b";
      # DeepSeek V4 Flash 0731 has a ~1.3M-token context window; the 8192
      # default only exists to keep Ollama from loading local models at full
      # size and needlessly throttles RAG chat context for this backend.
      PAPERLESS_AI_LLM_CONTEXT_SIZE = 32768;
    };
  };
}
