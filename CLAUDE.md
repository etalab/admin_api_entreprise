# Admin API Entreprise Development Guide

## Build/Test/Lint Commands

### Testing
- Run all tests: `bundle exec rspec`
- Run single test file: `bundle exec rspec spec/path/to/file_spec.rb`
- Run specific test line: `bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`
- Run feature tests: `bundle exec rspec spec/features/`
- Run with guard (auto-test): `guard`

### Linting
- Run Rubocop: `bundle exec rubocop`
- Run Brakeman security scan: `./bin/brakeman`

### Development
- Start server: `./bin/local.sh`
- Start server with local OpenAPI: `LOAD_LOCAL_OPEN_API_DEFINITIONS=true ./bin/local.sh`
- Run with Docker: `make start`

## Code Style Guidelines

- **Ruby Style**: Follow RuboCop configuration in `.rubocop.yml`
- **String Literals**: Single quotes for regular strings, double quotes for interpolation
- **Method Length**: Keep under 15 lines when possible
- **Naming**: Use snake_case for methods and variables, CamelCase for classes
- **Testing**: RSpec, feature tests with Capybara
- **Error Handling**: Use explicit error classes and meaningful error messages
- **Database**: Follow Rails conventions, use strong_migrations for safe changes
- **Indent Style**: 2 spaces, consistent indentation for multiline
- **Comments**: DO NOT use comments
- **File Endings**: Every file should end with a newline

## Access URLs
- API Entreprise: http://entreprise.api.localtest.me:5000/
- API Particulier: http://particulier.api.localtest.me:5000/
