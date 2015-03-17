#!/bin/bash

set -e
set -x

sudo sh -c "cat > /etc/sudoers.d/secure_path" <<'EOF'
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/vagrant/vendor/elixir/bin/"
EOF
