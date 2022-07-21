import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/services/location_service.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

class MapScreen extends StatefulWidget {
  final double? latLong;
  final double? latitude;
  final Function? onUpdate;

  MapScreen({this.latLong, this.latitude, this.onUpdate});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  late GoogleMapController mapController;

  String _currentAddress = '';

  final destinationAddressController = TextEditingController();
  final destinationAddressFocusNode = FocusNode();

  String _destinationAddress = '';
  double? _destinationLat;
  double? _destinationLong;

  Set<Marker> markers = {};

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    afterBuildCreated(() {
      _getCurrentLocation();
    });
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    appStore.setLoading(true);

    await getUserLocationPosition().then((position) async {
      setAddress();

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 18.0),
        ),
      );

      markers.clear();
      markers.add(Marker(
        markerId: MarkerId(_currentAddress),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(title: 'Start $_currentAddress', snippet: _destinationAddress),
        icon: BitmapDescriptor.defaultMarker,
      ));

      setState(() {});
    }).catchError((e) {
      toast(e.toString());
    });

    appStore.setLoading(false);
  }

  // Method for retrieving the address
  Future<void> setAddress() async {
    try {
      Position position = await getUserLocationPosition();

      List<Placemark> p = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = p[0];

      _currentAddress = "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
      destinationAddressController.text = _currentAddress;
      _destinationAddress = _currentAddress;

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  _handleTap(LatLng point) async {
    appStore.setLoading(true);

    markers.clear();
    markers.add(Marker(
      markerId: MarkerId(point.toString()),
      position: point,
      infoWindow: InfoWindow(),
      icon: BitmapDescriptor.defaultMarker,
    ));

    List<Placemark> placeMark = await placemarkFromCoordinates(point.latitude, point.longitude);
    Placemark place = placeMark[0];

    _destinationLat = point.latitude;
    _destinationLong = point.longitude;

    if (place.name != null) _destinationAddress = place.name.validate();
    if (!place.subLocality.isEmptyOrNull) _destinationAddress = '$_destinationAddress, ${place.street.validate()}';
    if (!place.locality.isEmptyOrNull) _destinationAddress = '$_destinationAddress, ${place.locality.validate()}';
    if (!place.administrativeArea.isEmptyOrNull) _destinationAddress = '$_destinationAddress, ${place.administrativeArea.validate()}';
    if (!place.postalCode.isEmptyOrNull) _destinationAddress = '$_destinationAddress, ${place.postalCode.validate()}';
    if (!place.country.isEmptyOrNull) _destinationAddress = '$_destinationAddress, ${place.country.validate()}';

    destinationAddressController.text = _destinationAddress;

    appStore.setLoading(false);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarWidget(language!.getLocation, backWidget: BackWidget(), color: primaryColor, elevation: 0, textColor: white),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            markers: Set<Marker>.from(markers),
            initialCameraPosition: _initialLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            onTap: _handleTap,
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ClipOval(
                  child: Material(
                    color: Colors.blue.shade100,
                    child: InkWell(
                      splashColor: Colors.blue,
                      child: SizedBox(width: 50, height: 50, child: Icon(Icons.add)),
                      onTap: () {
                        mapController.animateCamera(CameraUpdate.zoomIn());
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ClipOval(
                  child: Material(
                    color: Colors.blue.shade100,
                    child: InkWell(
                      splashColor: Colors.blue,
                      child: SizedBox(width: 50, height: 50, child: Icon(Icons.remove)),
                      onTap: () {
                        mapController.animateCamera(CameraUpdate.zoomOut());
                      },
                    ),
                  ),
                ),
              ],
            ).paddingLeft(10),
          ),
          Positioned(
            right: 0,
            left: 0,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipOval(
                  child: Material(
                    color: Colors.orange.shade100, // button color
                    child: Icon(Icons.my_location, size: 25).paddingAll(10),
                  ),
                ).paddingRight(8).onTap(() async {
                  appStore.setLoading(true);

                  await getUserLocationPosition().then((value) {
                    mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: LatLng(value.latitude, value.longitude), zoom: 18.0),
                      ),
                    );

                    _handleTap(LatLng(value.latitude, value.longitude));
                  }).catchError(onError);

                  appStore.setLoading(false);
                }),
                8.height,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppTextField(
                      textFieldType: TextFieldType.MULTILINE,
                      controller: destinationAddressController,
                      focus: destinationAddressFocusNode,
                      textStyle: primaryTextStyle(),
                      decoration: inputDecoration(context, hint: language!.hintAddress),
                    ),
                  ],
                ),
                8.height,
                AppButton(
                  width: context.width(),
                  height: 16,
                  color: primaryColor,
                  text: language!.setAddress.toUpperCase(),
                  textStyle: boldTextStyle(color: white, size: 12),
                  onTap: () {
                    if (_destinationAddress != '') {
                      destinationAddressFocusNode.unfocus();

                      setValue(LATITUDE, _destinationLat);
                      setValue(LONGITUDE, _destinationLong);
                      setValue(CURRENT_ADDRESS, _destinationAddress);

                      widget.onUpdate?.call(_destinationAddress);
                      //finish(context, _destinationAddress);
                    } else {
                      //TODO translate
                      toast('Pick address');
                    }
                  },
                ),
                8.height,
              ],
            ).paddingAll(16),
          ),
          Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
