# live_sensors

## Useful links
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