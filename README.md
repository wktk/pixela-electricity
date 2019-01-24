# pixela-electricity

syncronize electricity usage from econo-crea to [pixela](https://pixe.la)

## setting up

```sh
# clone source code
git clone git@github.com:wktk/pixela-electricity.git
cd pixela-electricity

# install dependencies
bundle install
brew install geckodriver

# configure environmental variables
cp .rbenv-vars.example .rbenv-vars
vim .rbenv-vars
```

## update pixels

### last 31 days

```sh
bundle exec ruby app.rb
```

### specify duration

```sh
bundle exec ruby app.rb --after 2018/01/01
bundle exec ruby app.rb --before 2018/12/31
bundle exec ruby app.rb --after 2018/01/01 --before 2018/12/31
```

## lisence

MIT

## author

[wktk](https://github.com/wktk)
