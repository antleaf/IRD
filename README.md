# IRD

## Running locally
### Requirements
1. Local Postgres Server, with a user account capable of creating databases
2. Local Opensearch server
2. Ruby environment (tested with 3.4.4)

### Process
(from this directory)
1. `bundle install`
2. Copy the `template.env` file and name this copy `.env.development` (or `.env.production` for production environment)
3. Edit the ENV variables in the file `.env.development` appropriately
4. `rails db:create`
5. `rails db:migrate`
6. `rails db:seed`
7. `rails server`

## Reindexing
`bundle exec thor index:reindex`

## Running
`rails server`

## Tests

### To run all tests
`bundle exec rspec`

### To run just system tests
`bundle exec rspec spec/system/*`
