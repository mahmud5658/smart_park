import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_car_parking/config/colors.dart'; // Make sure to import your primaryColor

import 'model/car_model.dart';

class ParkingController extends GetxController {
  RxList<CarModel> parkingSlotList = <CarModel>[].obs;
  TextEditingController name = TextEditingController();
  TextEditingController vehicleController = TextEditingController();
  RxDouble parkingTimeInMin = 10.0.obs;
  RxInt parkingAmount = 30.obs;
  RxString slotName = "".obs;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize slots
  Rx<CarModel> slot1 = CarModel(booked: false, isParked: false, parkingHours: "", name: "", paymentDone: false).obs;
  Rx<CarModel> slot2 = CarModel(booked: false, isParked: false, parkingHours: "", name: "", paymentDone: false).obs;
  Rx<CarModel> slot3 = CarModel(booked: false, isParked: false, parkingHours: "", name: "", paymentDone: false).obs;
  Rx<CarModel> slot4 = CarModel(booked: false, isParked: false, parkingHours: "", name: "", paymentDone: false).obs;
  Rx<CarModel> slot5 = CarModel(booked: false, isParked: false, parkingHours: "", name: "", paymentDone: false).obs;
  Rx<CarModel> slot6 = CarModel(booked: false, isParked: false, parkingHours: "", name: "", paymentDone: false).obs;
  Rx<CarModel> slot7 = CarModel(booked: false, isParked: false, parkingHours: "", name: "", paymentDone: false).obs;
  Rx<CarModel> slot8 = CarModel(booked: false, isParked: false, parkingHours: "", name: "", paymentDone: false).obs;

  // Book parking slot
  void bookParkingSlot(String slotId) async {
    slotName.value = slotId;
    print("Booking Slot ID: $slotId for ${parkingTimeInMin.value} minutes");

    await _bookSlotToFirestore(slotId);
    if (slotId == "1") slot1Controller();
    else if (slotId == "2") slot2Controller();
    else if (slotId == "3") slot3Controller();
    else if (slotId == "4") slot4Controller();
    else if (slotId == "5") slot5Controller();
    else if (slotId == "6") slot6Controller();
    else if (slotId == "7") slot7Controller();
    else if (slotId == "8") slot8Controller();

    // Show booking confirmation popup
    BookedPopup();
  }

  // Update Firestore when booking a slot
  Future<void> _bookSlotToFirestore(String slotId) async {
    try {
      // Update the slot details in Firestore
      await _firestore.collection('slots').doc(slotId).update({
        'isEmpty': false,
        'bookedBy': name.text,
        'slotStatus': 'Booked',
        'bookingTime': FieldValue.serverTimestamp(),
      });

      print("Slot $slotId updated in Firestore!");
    } catch (e) {
      print("Error updating slot in Firestore: $e");
    }
  }

  // Generic timer function to avoid repetition
  void _startParkingTimer(Rx<CarModel> slot) async {
    int parkingSeconds = (parkingTimeInMin.value * 60).toInt(); // Convert minutes to seconds for the timer

    slot.value = CarModel(
      booked: true,
      isParked: true,
      parkingHours: parkingSeconds.toString(),
      name: name.text,
      paymentDone: true,
    );

    // Countdown logic
    while (parkingSeconds > 0) {
      await Future.delayed(const Duration(seconds: 1));
      parkingSeconds--;
      slot.update((val) {
        val?.parkingHours = parkingSeconds.toString();
      });
      print("Slot ${slotName.value} Time remaining: $parkingSeconds seconds");
    }

    // Reset slot after time is up
    slot.value = CarModel(booked: false, isParked: false, parkingHours: "", name: "", paymentDone: false);
    print("Parking Time for Slot ${slotName.value} has ended.");
  }

  void slot1Controller() => _startParkingTimer(slot1);
  void slot2Controller() => _startParkingTimer(slot2);
  void slot3Controller() => _startParkingTimer(slot3);
  void slot4Controller() => _startParkingTimer(slot4);
  void slot5Controller() => _startParkingTimer(slot5);
  void slot6Controller() => _startParkingTimer(slot6);
  void slot7Controller() => _startParkingTimer(slot7);
  void slot8Controller() => _startParkingTimer(slot8);

  // Method to clear text fields and reset values
  void clearBookingDetails() {
    name.clear();
    vehicleController.clear();
    parkingTimeInMin.value = 10.0;
    parkingAmount.value = 30;
  }

  // Show booking confirmation popup
  Future<dynamic> BookedPopup() {
    return Get.defaultDialog(
      barrierDismissible: false,
      title: "SLOT BOOKED",
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: primaryColor),
      content: Column(
        children: [
          Lottie.asset('assets/animation/done1.json'),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Your Slot Booked", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: primaryColor)),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.person, "Name", name.text),
          _buildInfoRow(Icons.car_rental, "Vehicle No", vehicleController.text),
          _buildInfoRow(Icons.watch_later_outlined, "Parking Time", "${parkingTimeInMin.value.toInt()} min"),
          _buildInfoRow(Icons.solar_power_outlined, "Parking Slot", "A-${slotName.value}"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Clear the details before navigating
              clearBookingDetails();
              Get.offAllNamed('/homepage');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text("Go To Home"),
          )
        ],
      ),
    );
  }

  // Reusable info row for the popup
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text("$label : ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
        ],
      ),
    );
  }
}