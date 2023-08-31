# Live Sensors App

Development
----

### Dev container 
This project have config for [vscode dev container](https://code.visualstudio.com/docs/devcontainers/containers)
So in case you open project in vscode and you have docker installed in system - you just run command `Dev containers: reopen in dev container` command to get all dev environment
> Note: Podman not supported


### Devbox 
Another options is using [devbox](https://github.com/jetpack-io/devbox) tool for install unnecessary environment
```
devbox install
```
```

Build
----
```
flutter build apk 
```


## Useful links
- [Remote debugging on real device](https://dev.to/petrussola/how-to-debug-flutter-app-with-real-android-phone-693)


Auto scrolling
```
class _HomePageState extends State<HomePage> {
  ScrollController scrollController = ScrollController(); // 👈 Define scrollController 
  List<String> assets = [...] // String of images to be displayed in listview

  @override
  void initState() { // 👈 create animation in initState
    Future.delayed(const Duration(seconds: 1), () {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: Duration(seconds: asset.length * 10), curve: Curves.linear);
    });

   //👉 If you want infinite scrolling use the following code 
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        // Scroll has reached the end, reset the position to the beginning.
        scrollController.jumpTo(scrollController.position.minScrollExtent);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: ListView.builder(
                  controller: scrollController, // 👈 assign scrollController here
                  ....
                  // display your images here
               ),
             ),
       );
  }
```   

```
## Architecture

  ╭ SnapshotError
  │  temporaryError
  │  type: Network | Backend | Device | Unknown
  │  message
  ╰

  ╭ Snapshot
  │  SnapshotError
  │  position
  │  startDateTime
  │  endDateTime
  │  measurements
  │  user
  │  addMeasurement:
  │  seal(Position):
  │  attachError:
  ╰

  ╭ Tracker
  │  Snapshot ──┬┬┬──┬──→ Sender.addToQueue
  │  Sensors:   │││  │
  │    Sensor_A ┘││  │
  │    Sensor_B ─┘│  │
  │    Sensor_N ──┘  │
  │  GeoPosition ────┘ 
  ╰

  ╭ Sender
  │  Queue
  │  Storage
  │   
  │  init:
  │    sendSnapshotsFromQueue()
  │    sendSnapshotsFromStorage()
  │
  │  addToQueue:
  │    Snapshot -> Queue.add
  │
  │  sendSnapshotsFromQueue:
  │    while(true):
  │      Queue.next
  │         Api.send
  │          then:
  │            Queue.remove(Snapshot)
  │          catch(e):
  │            Snapshot.attachError(e)
  │            Storage.save(Snapshot)
  │            Queue.skip(Snapshot)
  │
  │  sendSnapshotsFromStorage:
  │    while(true):
  │      Storage.next
  │         Api.send
  │          then:
  │            Storage.delete(Snapshot)
  ╰

  ╭ Queue
  │  _queue
  │  add:
  │  remove:
  │  skip:
  │  persist:
  │  next: 
  ╰ 

  ╭ Storage
  │  save:
  │  delete:
  │  next: // Cycled over file, but on second cycle takes only snapshots with 
  ╰ 


  ### Environment variables
  https://itnext.io/secure-your-flutter-project-the-right-way-to-set-environment-variables-with-compile-time-variables-67c3163ff9f4


  https://github.com/Baseflow/flutter-geolocator/issues/1212
