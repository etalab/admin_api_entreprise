#!/bin/bash

psql -f postgresql_setup.txt
npm install -g mjml
bundle install
bin/rails db:schema:load RAILS_ENV=test
bin/rails db:seed:replant
