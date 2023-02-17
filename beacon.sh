#!/bin/sh

license() {
    echo "beacon - Backup Encrypt Archive (restore) CONfiguration"
    echo ""
    echo "Copyright (C) 2020 anamulbahar"
    echo "GitHub: https://github.com/anamulbahar/beacon"
    echo ""
    echo "MIT License"
    echo ""
    echo "Permission is hereby granted, free of charge, to any person obtaining a copy"
    echo "of this software and associated documentation files (the \"Software\"), to deal"
    echo "in the Software without restriction, including without limitation the rights"
    echo "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell"
    echo "copies of the Software, and to permit persons to whom the Software is"
    echo "furnished to do so, subject to the following conditions:"
    echo ""
    echo "The above copyright notice and this permission notice shall be included in all"
    echo "copies or substantial portions of the Software."
    echo ""
    echo "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR"
    echo "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,"
    echo "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE"
    echo "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER"
    echo "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,"
    echo "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE"
    echo "SOFTWARE."
    echo ""
}

usage() {
    echo "Usage:"
    echo "    beacon <options> if already installed"
    echo "    ./beacon.sh <options> if not installed and in the same directory"
    echo ""
    echo "Options:"
    echo "    --h    show help"
    echo "    --i    install beacon"
    echo "    --b    backup configuration"
    echo "    --r    restore configuration"
    echo "    --l    show license"
    echo "    --v    show version"
    echo ""
}

version() {
    echo "beacon 1.0.0"
}

# show usage if no arguments are passed
if [ $# -eq 0 ]; then
    usage
    exit 1

# show usage if --h or --help is passed
elif [ "$1" = "--h" ] || [ "$1" = "--help" ]; then
    usage
    exit 1

# show license if --l is passed
elif [ "$1" = "--l" ]; then
    echo "beacon is licensed under the MIT License"
    echo ""
    license


# show version if --v or --version is passed
elif [ "$1" = "--v" ] || [ "$1" = "--version" ]; then
    version
    exit 1

# backup configuration if --b is passed
elif [ "$1" = "--b" ]; then
    echo "Backing up..."
    # create a folder at ~/.beacon
    mkdir -p ~/.beacon
    # create a gzip file of .config folder at ~/.beacon/config.tar.gz
    tar -czf ~/.beacon/config.tar.gz -C ~/.config .
    # encrypt the config.tar.gz file with openssl with user asking password
    openssl enc -aes-256-cbc -salt -in ~/.beacon/config.tar.gz -out ~/.beacon/config.tar.gz.enc
    # remove the config.tar.gz file
    rm ~/.beacon/config.tar.gz
    echo "Backup complete!"

# restore configuration if --r is passed
elif [ "$1" = "--r" ]; then
    echo "Restoring..."
    # if no config.tar.gz.enc file exists, then print no backup found and exit
    if [ ! -f ~/.beacon/config.tar.gz.enc ]; then
        echo "No backup found!"
        exit 1
    fi
    # decrypt the config.tar.gz.enc file with openssl with user asking password
    openssl enc -aes-256-cbc -d -salt -in ~/.beacon/config.tar.gz.enc -out ~/.beacon/config.tar.gz
    # extract the config.tar.gz file in ~/.beacon/config folder
    mkdir -p ~/.beacon/config
    tar -pxzf ~/.beacon/config.tar.gz -C ~/.beacon/config
    # remove the config.tar.gz file
    rm ~/.beacon/config.tar.gz
    # ask user if they want to copy the config folder to ~/.config
    # if yes, then copy the config folder to ~/.config
    # if no, then exit
    # if invalid option, then ask again
    # show warning if ~/.config already exists
    if [ -d ~/.config ]; then
        echo "WARNING: ~/.config already exists!"
        echo "If you continue, the contents of ~/.config will be deleted!"
        # ask user if they want to keep old config folder as ~/.config.old
        # if yes, then rename ~/.config to ~/.config.old
        # if no, then delete ~/.config
        # if invalid option, then ask again
        while true; do
            read -p "Do you want to keep the old config folder as ~/.config.old? [y/n] " yn
            case $yn in
                [Yy]* ) mv ~/.config ~/.config.old; break;;
                [Nn]* ) rm -rf ~/.config; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
    while true; do
        read -p "Do you want to copy the config folder to ~/.config? [y/n] " yn
        case $yn in
            [Yy]* ) mkdir -p ~/.config; cp -r ~/.beacon/config/* ~/.config; break;;
            [Nn]* ) break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    echo "Restore complete!"

# install beacon if --i is passed
elif [ "$1" = "--i" ]; then
    cp beacon.sh /usr/local/bin/beacon;
    chmod +x /usr/local/bin/beacon;
    echo "beacon installed!"

# uninstall beacon if --u is passed
elif [ "$1" = "--u" ]; then
    rm /usr/local/bin/beacon;
    echo "beacon uninstalled!"

else
    echo "Invalid option"
    #show usage
    usage
    exit 1
fi

