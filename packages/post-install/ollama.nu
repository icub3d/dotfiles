do -i {
# ollama
  if (not ("/usr/local/bin/ollama" | path exists)) {
    http get https://ollama.ai/install.sh | sh
    ollama pull codellama
    ollama pull llama2
    ollama pull zephyr
  }

}
