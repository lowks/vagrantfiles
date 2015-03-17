#!/bin/bash -ex
ERL_TOP=/home/vagrant/.kerl/installs/current
ERL_BUILD_DIR=/home/vagrant/.kerl/installs/17.4
ERL_VERSION=17.4
ERL_BUILD=17.4
ELIXIR_VER=1.0.3

# language
echo -e 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale

# update
apt-get update -yq > /dev/null

# install dependencies
apt-get install wget build-essential openssl git libncurses5-dev autoconf \
    linux-headers-$(uname -r) m4 curl libssl-dev unixodbc-dev flex -y

# clean
apt-get clean
apt-get autoremove -y
apt-get install -y unzip

# install kerl
curl -O https://raw.githubusercontent.com/spawngrid/kerl/master/kerl

mv kerl /usr/local/bin/
chmod 775 /usr/local/bin/kerl

# bash_completion kerl
curl -O https://raw.githubusercontent.com/spawngrid/kerl/master/bash_completion/kerl
mv kerl /etc/bash_completion.d/

# create file configure kerl
cat > /home/vagrant/.kerlrc <<EOF
    KERL_INSTALL_MANPAGES=yes
    KERL_CONFIGURE_OPTIONS="--enable-threads --enable-smp-support\
--enable-kernel-poll --enable-hipe --enable-shared-zlib\
--enable-dynamic-ssl-lib --with-ssl"
EOF

# install erlang
sudo -Hu vagrant /usr/local/bin/kerl update releases

(sudo -Hu vagrant /usr/local/bin/kerl list builds | grep 17.4) || (echo "I should not be doing this!"; export MAKEFLAGS='-j3'; sudo -Hu vagrant /usr/local/bin/kerl build $ERL_VERSION $ERL_BUILD;)

(sudo -Hu vagrant /usr/local/bin/kerl list installations | grep 17.4) || (sudo -Hu vagrant /usr/local/bin/kerl install $ERL_BUILD $ERL_BUILD_DIR)


# sudo -Hu vagrant /usr/local/bin/kerl build $ERL_VERSION $ERL_BUILD
# sudo -Hu vagrant /usr/local/bin/kerl install $ERL_BUILD $ERL_BUILD_DIR

# link build in current
if ! [ -L $ERL_TOP ]; then
ln -s $ERL_BUILD_DIR $ERL_TOP
fi

# install rebar
wget https://raw.github.com/wiki/rebar/rebar/rebar && chmod 775 rebar
mv rebar /usr/local/bin

# activate erlang version
echo -e  ". /home/vagrant/.kerl/installs/current/activate" > .bash_profile

# Elixir's turn
rm -rf /home/vagrant/vendor/elixir
mkdir -p /home/vagrant/vendor/elixir
wget --no-clobber -q https://github.com/elixir-lang/elixir/releases/download/v$ELIXIR_VER/precompiled.zip
unzip -o -qq precompiled.zip -d /home/vagrant/vendor/elixir
base_usr_dir="/usr/bin"

for script in iex mix elixirc elixir
do
if ! [ -L $base_usr_dir/$script ]; then
   ln -s /home/vagrant/vendor/elixir/bin/$script $base_usr_dir/$script
fi
done

