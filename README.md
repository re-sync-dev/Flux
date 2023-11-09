# Flux
DataStore wrapper with a focus on extensibility and easy modification to fit developer needs.

## Why make another DataStore wrapper?
Well to put it simply I want to make the Roblox resource pool look exactly like the npm site (a very large cluttered mess of the same thing). Jokes aside, this DataStore wrapper is actually not just a wrapper, it includes more than just Roblox's DataStoreService, it can introduces the concept of "Provider" which is a way to store data on other platforms such as MongoDB, MySQL, etc. With this in mind, you can easily switch between services without having to change your code a huge amount. Oh and this includes pretty much all of the standard features from other DataStore wrappers such as session locking, caching, global updates, etc etc.

## Planned Features
- [ ] Schema verification
- [ ] Data persistence between places
- [ ] Downtime protection (Mostly for providers but can be used in junction with DataStoreService)
- [x] GDPR compliance
- [ ] Configurable statistics
- [ ] OrderedDataStore support
- [ ] Data Sharding (Pretty much how DataStore2 does it)
- [x] Mocking (For offline use & unit testing)
- [ ] Less boilerplate code
- [ ] More native available providers
- [ ] Version control
- [x] Data reconciliation
- [ ] Internal rate Limiting

## Features
- [x] Session Locking
- [x] Internal Data caching
- [ ] Global updates
- [ ] Provider support
- [ ] Unit testing
- [ ] Documentation

## TODO
Prioritized list of things [TODO](TODO.md)

## Example Usage
A basic example can be found [here](https://github.com/re-sync-dev/Flux/server/init.server.lua)

## Documentation
Documentation can be found [here](https://re-sync-dev.github.io/Flux/)

## Bugs
Any bugs that are found should be reported to the [issue tracker](https://github.com/re-sync-dev/Flux/issues)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for more details