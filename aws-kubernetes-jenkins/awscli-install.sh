#!/usr/bin/env bash
PLATFORM="$(uname -s)"
BOX_NAME="$(uname -n)"
PYTHON_VERSION=$1
PYTHON_DEPS=(python3-pip python3-dev build-essential libssl-dev libffi-dev)


python_dependencies () {
    sudo apt-get -qqy update
    sudo apt-get -qqy --no-install-recommends install ${PYTHON_DEPS[@]}
    sudo ln -fs /usr/bin/$PYTHON_VERSION /usr/bin/python
    pip3 install --upgrade pip
}

# Checking Vagrant Boxes
if [ $PLATFORM=="Linux" ] && [ $BOX_NAME=="ubuntu-xenial" ]; then
    echo "You are using ubuntu/xenial64 Vagrant Box"
    # If not exist, Installing Python3
    if command -v $PYTHON_VERSION &>/dev/null; then
        echo "$PYTHON_VERSION is installed"
        echo "Python dependencies are installing"
        python_dependencies
    else
        echo "$PYTHON_VERSION is not installed"
        echo "$PYTHON_VERSION is installing"
        #sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt-get -qqy install $PYTHON_VERSION
        echo "Python dependencies are installing"
        python_dependencies
    fi
else
    echo "Please change Vagrant Boxes to ubuntu/xenial64"
    echo "Exiting .........."
	exit 1;
fi

# Installing AWS via Pip3
pip -V
echo "Installing AWS CLI"
pip install awscli --upgrade --user
echo "Installed AWS CLI Version"
aws --version

# Copy .aws to /home/vagrant/.aws
sudo cp -R /vagrant/.aws /home/vagrant/.aws
