import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_map_polyline/google_map_polyline.dart';

void main()=>runApp(MaterialApp(

  home: MyMap(),

));

class MyMap extends StatefulWidget {
  MyMap({Key key}) : super(key: key);

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {


 final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
List<Marker> allMarkers = [];
double distance;
Position _currentPosition;
 GoogleMapPolyline googleMapPolyline = new  GoogleMapPolyline(apiKey:  "AIzaSyCbU4tMcfPGRH6UC3Lucea0jtdwXWfcKag");
 final Set<Polyline> polyline = {};
 @override
  void initState() {
     super.initState();
      allMarkers.add(Marker(
        markerId: MarkerId('myMarker'),
        draggable: true,
        onTap: () {
          print('Marker Tapped');
        },
        position: LatLng(26.6717, 87.6680)));
      
      allMarkers.add(Marker(markerId: MarkerId("Initial"),draggable: true,position: LatLng(26.8206, 30.8025)));
  }
  
  String searchAddr;

GoogleMapController _controller;
MapType _defaultMapType = MapType.normal;

void _changeMapType() {
    setState(() {
      _defaultMapType = _defaultMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

void jumpToNew(){

  _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(26.6717, 87.6680),zoom: 12)));
  
}

void goBack(){
  _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(_currentPosition.latitude, _currentPosition.longitude),zoom: 12)));


}

void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      
    });
}

showmylocation()async{
   final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    
        geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
    

}


showdistance()async{

  double distanceInMeters = await Geolocator().distanceBetween(_currentPosition.latitude, _currentPosition.longitude,26.6717, 87.6680);
  setState(() {
    distance= distanceInMeters;
  });

}

showroute()async{
  await googleMapPolyline.getCoordinatesWithLocation(
          origin: LatLng(40.677939, -73.941755),
          destination: LatLng(40.698432, -73.924038),
          mode:  RouteMode.driving);	


}
 searchandNavigate() {
    Geolocator().placemarkFromAddress(searchAddr).then((result) async {

      _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target:
              LatLng(result[0].position.latitude, result[0].position.longitude),
          zoom: 10.0,
          
          tilt: 45)));

           double distanceInMeters = await Geolocator().distanceBetween(_currentPosition.latitude, _currentPosition.longitude,result[0].position.latitude, result[0].position.longitude);
  setState(() {
    distance= distanceInMeters/1000;
  });
  // await googleMapPolyline.getCoordinatesWithLocation(
  //         origin: LatLng(_currentPosition.latitude, _currentPosition.longitude),
  //         destination: LatLng(result[0].position.latitude, result[0].position.longitude),
  //         mode:  RouteMode.walking);	

          
    });
    
  }



@override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Maps in Flutter'),
          centerTitle: true,
          actions: <Widget>[
            FlatButton(
              child: distance!=null?Text("$distance .km"):Text("show distance"),
              color: Colors.pink,
              onPressed:showroute,
            ),
            

            
          ],
        
        
        ),
        body: Stack(
          children: <Widget>[
            
            
            GoogleMap(    
              onMapCreated: _onMapCreated,
               mapType: _defaultMapType,
               markers: Set.from(allMarkers),
               myLocationEnabled: true,
              initialCameraPosition: CameraPosition(target: _currentPosition!=null?LatLng(_currentPosition.latitude, _currentPosition.longitude):LatLng(50, 60) ),
            ),
            Container(
              margin: EdgeInsets.only(top: 80, right: 10),
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  FloatingActionButton(
                      child: Icon(Icons.layers),
                      elevation: 5,
                      backgroundColor: Colors.teal[200],
                      onPressed: () {
                        _changeMapType();
                        print('Changing the Map Type');
                      }),
                ]),
            ),
            Positioned(top: 10,left: 20,child:FlatButton.icon(onPressed: jumpToNew, icon: Icon(Icons.assignment), label: Text("Go to nepal")),),
             Positioned(top: 10,left: 180,child:FlatButton.icon(onPressed: goBack, icon: Icon(Icons.assignment), label: Text("Go to Back")),),

             Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text("Get location"),
              color: Colors.pink,
              onPressed:showmylocation,
            ),
          ],
        ),
        Positioned(
          top: 60.0,
          right: 15.0,
          left: 15.0,
          child: Container(
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0), color: Colors.white),
            child: TextField(
              decoration: InputDecoration(
                  hintText: 'Enter Address',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: searchandNavigate,
                      iconSize: 30.0)),
              onChanged: (val) {
                setState(() {
                  searchAddr = val;
                });
              },
            ),
          ),
        )
            
          ],
        ));
  }
}