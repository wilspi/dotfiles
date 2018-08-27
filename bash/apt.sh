
# Update pkg lists information from repositories, and update pkgs
sudo apt-get update
sudo apt-get upgrade

# Install packages
sudo apt-get install -y chromium-browser build-essential python-pip python3-pip curl

# Remove Libreoffice, we have google-docs
sudo apt-get remove --purge libreoffice*
sudo apt-get clean
sudo apt-get autoremove

# Install atom 
sudo add-apt-repository ppa:webupd8team/atom -y
sudo apt-get update
sudo apt-get install -y atom

# For React Native dev
#######################
# Install nodejs and Update npm to recent version
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install watchmen, check the latest stable version
# Read https://facebook.github.io/watchman/docs/install.html#installing-from-source
# Might have to install following
# sudo apt-get install pkg-config libtool libssl-dev autoconf automake python-pip
git clone https://github.com/facebook/watchman.git
cd watchman
git checkout v4.9.0 # the latest stable release
./autogen.sh
./configure
make
sudo make install

# Install React Native
sudo npm install -g react-native-cli

########################

# Set bash history to unlimited
# https://stackoverflow.com/a/19533853


# Install Dropbox
sudo apt install nautilus-dropbox

# Terminator
sudo apt-get install terminator