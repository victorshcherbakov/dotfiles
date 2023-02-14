# .dotfiles collection

fish:
sudo add-apt-repository ppa:fish-shell/release-3

# Change your default shell:
[ -x /usr/bin/fish ] && SHELL=/usr/bin/fish exec /usr/bin/fish

https://github.com/oh-my-fish/oh-my-fish
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
omf install bobthefish
omf theme bobthefish
deb http://ppa.launchpad.net/fish-shell/release-3/ubuntu focal main

# lua-language-server
1. Download the latest release:
https://github.com/sumneko/lua-language-server/releases
2. Unpack it to somewhere, e.g. /home/victor/apps/lua-language-server-3.5.6-linux-x64
3. in fish type the following line:
  set -U SUMNEKO_LUA_PATH /home/victor/apps/lua-language-server-3.5.6-linux-x64/
4. Restart your terminal/fish

fzf:
https://github.com/PatrickF1/fzf.fish#installation
https://github.com/sharkdp/fd#installation
https://github.com/sharkdp/bat

git:
# add-apt-repository ppa:git-core/ppa # apt update; apt install git

cmake
pip install cmake --upgrade

alacritty
sudo add-apt-repository ppa:aslatter/ppa
sudo apt update

subversion

nvim:
https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb