#!/usr/bin/env bash

# update
sudo apt update -y

# basic dev requirements
sudo apt install -y git build-essential python3-dev python3-pip tmux

# install nvidia
wget https://developer.download.nvidia.com/compute/cuda/12.0.1/local_installers/cuda_12.0.1_525.85.12_linux.run
sudo sh cuda_12.0.1_525.85.12_linux.run

# install torch
pip3 install --pre torch --index-url https://download.pytorch.org/whl/nightly/cu118

# vim from source for YCM
sudo apt autoremove -y vim vim-runtime gvim
sudo apt autoremove -y python2*
sudo apt install -y \
                 libatk1.0-dev \
                 libcairo2-dev \
                 libgtk2.0-dev \
                 liblua5.1-0-dev \
                 libncurses5-dev \
                 libperl-dev \
                 libx11-dev \
                 libxpm-dev \
                 libxt-dev▫
# clone and install vim
cd $HOME
mkdir -p src/vim
cd src/vim
git clone https://github.com/vim/vim.git
cd vim
./configure --with-features=huge \
--enable-multibyte \
--enable-rubyinterp=yes \
--enable-python3interp=yes \
--with-python3-command=python3 \
--with-python3-config-dir=$(python3-config --configdir) \
--enable-perlinterp=yes \
--enable-gui=gtk2 \
--enable-cscope \
--prefix=/usr/local

make -j$(nproc --all) && sudo make install

# verify installation
vim --version | grep +python3

# configure vim
cd $HOME
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

cat << EOF > .vim/vimrc
syntax on
filetype plugin indent on

set omnifunc=syntaxcomplete#Complete
set complete=.,w,b,u,t,i
set autoread                                                 " reload files when changed on disk, i.e. via `git checkout`
set backspace=2                                              " Fix broken backspace in some setups
set backupcopy=yes                                           " see :help crontab
set clipboard=unnamed                                        " yank and paste with the system clipboard
set directory-=.                                             " don't store swapfiles in the current directory
set encoding=utf-8
set ignorecase                                               " case-insensitive search
set background=dark
set softtabstop=2
set shiftwidth=2
set expandtab

set list
set listchars=tab:▸\ ,trail:▫

hi User1 ctermfg=green ctermbg=black
hi User2 ctermfg=yellow ctermbg=black
hi User3 ctermfg=red ctermbg=black
hi User4 ctermfg=blue ctermbg=black
hi User5 ctermfg=white ctermbg=black

set laststatus=2
set statusline=
set statusline +=%1*\ %n\ %* "buffer number
set statusline +=%5*%{&ff}%* "file format
set statusline +=%3*%y%* "file type
set statusline +=%2*%m%* "modified flag
set statusline +=%4*\ %<%F%* "full path
set statusline +=%1*%=%5l%* "current line
set statusline +=%2*/%L%* "total lines
set statusline +=%1*%4v\ %* "virtual column number

" change filetypes for common files
augroup xjdr
  au BufNewFile,BufRead *.py set filetype=python sw=2 sts=2 et
  au BufNewFile,BufRead *.cc set filetype=cpp sw=2 sts=2 et
  au BufNewFile,BufRead *.cpp set filetype=cpp sw=2 sts=2 et
  au BufNewFile,BufRead *.h set filetype=cpp sw=2 sts=2 et
  au BufNewFile,BufRead *.json setfiletype javascript
  au BufNewFile,BufRead *.md set filetype=markdown softtabstop=4 shiftwidth=4

  autocmd Filetype markdown setlocal spell textwidth=80
  autocmd Filetype gitcommit,mail setlocal spell textwidth=76 colorcolumn=77
augroup END

call plug#begin()
Plug 'ycm-core/YouCompleteMe', { 'do': 'python3 install.py --all' }
Plug 'dense-analysis/ale'
Plug 'vim-airline/vim-airline'
Plug 'arcticicestudio/nord-vim'
call plug#end()

let pipenv_venv_path = system('pipenv --venv')
let poetry_venv_path = system('poetry env info --path')
if shell_error == 0
  let venv_path = substitute(poetry_venv_path, '\n', '', '')
  let g:ycm_python_binary_path = venv_path . '/bin/python'
else
  let g:ycm_python_binary_path = 'python3'
endif
let g:ycm_clangd_uses_ycmd_caching = 0
let g:ycm_clangd_binary_path = exepath("clangd-13")

let g:ale_python_auto_pipenv = 1
let g:ale_python_auto_poetry = 1
" Check Python files with flake8 and pylint.
let b:ale_linters = ['clangd', 'clangtidy', 'pyright', 'pylint', 'mypy']
" Fix Python files with autopep8 and yapf.
let b:ale_fixers = ['clang-format', 'clangtidy', 'yapf']
" Disable warnings about trailing whitespace for Python files.
let b:ale_warn_about_trailing_whitespace = 0
let g:ale_cpp_clangd_executable = exepath("clangd-13")
let g:ale_cpp_clangtidy_executable = exepath("clang-tidy-13")


colorscheme nord
set signcolumn=number
let g:ale_sign_error = '●'
let g:ale_sign_warning = '.'
hi ALEError ctermbg=none cterm=underline
hi ALEWarning ctermbg=none cterm=underline
"hi ALEErrorSign ctermbg=bg ctermfg=red
"hi ALEWarningSign ctermbg=bg ctermfg=yellow

"highlight clear SignColumn
"highlight SignColumn ctermbg=bg
"highlight LineNr ctermfg=DarkGrey
"highlight Todo ctermbg=bg ctermfg=red
"highlight Comment ctermbg=bg ctermfg=LightBlue
"highlight Pmenu ctermbg=bg ctermfg=gray
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#ycm = 1
let g:airline_powerline_fonts = 1

EOF

# configure tmux
cd $HOME
mkdir -p .tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

cat << EOF > .tmux.conf
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin "arcticicestudio/nord-tmux"

# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'github_username/plugin_name#branch'
# set -g @plugin 'git@github.com:user/plugin'
# set -g @plugin 'git@bitbucket.com:user/plugin'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'

EOF

# install node for pyright
#curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash - &&\
#  sudo apt-get install -y nodejs
#sudo npm install -g pyright

# install poetry 
curl -sSL https://install.python-poetry.org | python3 -
