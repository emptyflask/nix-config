{config, ...}: {
  age.secrets.hister-env = {
    file = ../../../secrets/hister.env.age;
    owner = "hister";
    group = "hister";
  };

  services.hister = {
    enable = true;
    environmentFile = config.age.secrets.hister-env.path;
    settings = {
      server.base_url = "https://hister.newton.lan";
      semantic_search = {
        enable = true;
        embedding_endpoint = "https://openrouter.ai/api/v1/embeddings";
        embedding_model = "qwen/qwen3-embedding-4b";
        embedding_timeout = 300;
        dimensions = 2560;
        max_context_length = 512;
        chunk_overlap = 50;
        max_embedding_batch_size = 8;
        query_prefix = "query: ";
        document_prefix = "";
        similarity_threshold = 0.5;
        result_limit = 10;
        semantic_weight = 0.4;
        max_embedding_concurrency = 2;
      };
    };
  };
}
