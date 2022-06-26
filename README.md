# Dotfiles

Dotfiles contains and updated configuration for the vim editor

## Installation

### Intall basic dependencies

```bash
apt-get install git make -y
```

### Install required dependencies on the host machine

```bash
sudo make install -e USER=$USER -e HOME=$HOME
```

### Build the image
This will take a while :)
```bash
make build
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
