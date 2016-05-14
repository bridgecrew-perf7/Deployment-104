
# Daydash

## Installing Homebrew

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

## Installing Ruby

```
brew install rbenv ruby-build

# Add rbenv to bash so that it loads every time you open a terminal
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
source ~/.bash_profile

# Install Ruby
rbenv install 2.3.0
rbenv global 2.3.0
ruby -v
```

## Configuring Git

```
git config --global color.ui true
git config --global user.name "Arnon Hongklay"
git config --global user.email "arnon@hongklay.com"
ssh-keygen -t rsa -C "arnon@hongklay.com"
```

```
cat ~/.ssh/id_rsa.pub
```

```
gem install rails -v 4.2.5
```

## PostgreSQL

```
brew install postgresql

# To have launchd start postgresql at login:
ln -sfv /usr/local/opt/postgresql/*plist ~/Library/LaunchAgents

# Then to load postgresql now:
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
```
