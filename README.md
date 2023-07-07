# live_sensors

## Useful links
-[Remote debugging on real device](https://dev.to/petrussola/how-to-debug-flutter-app-with-real-android-phone-693)


- [I’m having Trouble Getting GPS Location in the Background](https://pmatatias.medium.com/im-having-trouble-getting-the-gps-location-in-the-background-flutter-70acf559f5f4)

TLDR: 
> After explore some plugin from pub.dev, currently the best solution is using [geolocator](https://pub.dev/packages/geolocator) (v8.2 above) + [workmanager](https://pub.dev/packages/workmanager) with additional setting from [Don’t kill my app!](https://dontkillmyapp.com/)

From comments:  
```
A: geolocator v9.0.2 now has the ability to stream and listen location even in the background, just need to do some settings in the LocationSettings property.  
  
B: But once we close the app before stop the stream, we cant close the notification.  
  
A: How about using didChangeAppLifecycleState to cancel the stream when apps is not in bacground anymore?
```
- Simple official library for read other sensors [sensors_plus](https://pub.dev/packages/sensors_plus)


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