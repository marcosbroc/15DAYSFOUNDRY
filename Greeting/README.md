## Greeting


### Build

```shell
$ forge build
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge create Greeting --private-key <your private key> --broadcast
```

### Cast call

```shell
$ cast call <contract address> "getGreeting(string)" <name of person>
```
### Cast to ASCII
```shell
$ cast to-ascii <hex returned>
```

### Set greeting
```shell
$ cast send <contract address> "setGreeting(string)" <greeting> --private-key <your private key> 
```

