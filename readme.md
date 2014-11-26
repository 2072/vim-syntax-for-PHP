## About

This is a fork of [the official VIm syntax file for PHP](https://gitorious.org/jasonwoof/vim-syntax/commit/e22e5cbb1d8c6d90f4bbec27eeb15550c87bf6dd) (version from 2012-12-11 is bundled with VIm 7.4)

For now I just fix things I need and use daily.

See the commit log to see the changes from Jason Woofenden's version.

## Install


### Vundle
 1. Install and configure the [Vundle](https://github.com/gmarik/vundle) plug-in manager, [follow the instructions here](https://github.com/gmarik/vundle#quick-start)
 2. Add the following line to your `.vimrc`:

         Plugin '2072/vim-syntax-for-PHP.git'
 3. Source your `.vimrc` with `:so %` or otherwise reload your VIm
 4. Run the `:PluginInstall` command

### Pathogen
 1. Install the [pathogen.vim](https://github.com/tpope/vim-pathogen) plug-in, [follow the instructions here](https://github.com/tpope/vim-pathogen#installation)
 2. Clone the repository under your `~/.vim/bundle/` directory:

         cd ~/.vim/bundle
         git clone git@github.com:2072/vim-syntax-for-PHP.git
