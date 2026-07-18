####################################
export ZDOTDIR=$HOME/.config/zsh
####################################

export EDITOR=vim
export VISUAL=vim

# Другие полезные переменные окружения
export OLLAMA_HOST="http://localhost:11111"
export OLLAMA_API_URL="http://localhost:11111/api/chat/"

# Расширяем PATH
export PATH="$HOME/.local/bin:$PATH"

# Для правильной работы цветов в micro/терминале
export COLORTERM=truecolor
export GGUF_PATH=~/.MODELS/gemma4-coding-q4_k_m.gguf


# Load private tokens/envs if the file exists
if [[ -f "$HOME/.zshenv.secrets" ]]; then
    source "$HOME/.zshenv.secrets"
fi
