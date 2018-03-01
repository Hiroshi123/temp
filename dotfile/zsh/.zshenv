

export PATH=/usr/local/bin:$PATH
export PATH=/Users/hiroshi/.local/bin:$PATH
export PATH=/Users/hiroshi/.cabal/bin:$PATH
#for llvm
export PATH=/usr/local/opt/llvm/bin:$PATH
# export PATH=/usr/local/Cellar/llvm/5.0.0/bin:$PATH


export PYTHONDONTWRITEBYTECODE=1

#for tvm
export LD_LIBRARY_PATH=$HOME/git/nnvm/tvm/build:${LD_LIBRARY_PATH}

#virtualenv settings
export WORKON_HOME=$HOME/.virtualenvs

#pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

#pyvenv
eval "$(pyenv virtualenv-init -)"

alias pvlist="pyenv versions"
alias pvg="pyenv global"
alias pvswitch="pyenv global"
alias pvl="pyenv local"


