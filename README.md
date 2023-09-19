# Live Sensors App

Development
----

### Dev container 
This project have config for [vscode dev container](https://code.visualstudio.com/docs/devcontainers/containers)
So in case you open project in vscode and you have docker installed in system - you just run command `Dev containers: reopen in dev container` command to get all dev environment
> Note: If you use podman an additional configuration may required
> https://jahed.dev/2023/05/27/remote-development-with-vs-code-podman/


### Devbox 
Another options is using [devbox](https://github.com/jetpack-io/devbox) tool for install unnecessary environment
```
devbox install
```


### Scripts
Repository have set of scripts that helps build, test, and release app.


Build
----
```
flutter build apk 
```

## Useful links
- [Remote debugging on real device](https://dev.to/petrussola/how-to-debug-flutter-app-with-real-android-phone-693)
- [Use a native language debugger](https://docs.flutter.dev/testing/native-debugging)


## Architecture
All top level logic described in `/main/controller.dart` module

### Initialization stage
When app booted in try to recover previous user sessions.
In case if success app goes to `setup` stage, else user redirected to login screen,
and `setup` stage will executed after successful login 

### Setup stage
During the installation process, the program requests the necessary accesses, instantiates the services

### Http client

- ApiClient - describe backend api
  - OpenIdClient - handle auth logic - login / logout / handle 401 errors / keep tokens fresh
    -  OpenIdApi - describe auth api

### Snapshot

Contain all sensors records during period of time


### Tracker 

- Listens to sensors and fills snapshots with sensor data
- listens to gps channel and create new snapshot on every position change
- Adding new snapshots to `queue`

### Sender

Sending snapshots from `queue` to backend


### Dataflow
```
Sensors + GPS ---(data)--> Tracker ---(Snapshot)--> Queue --> Sender --> Client --> Backend
```
