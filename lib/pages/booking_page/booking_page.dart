import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_car_parking/pages/booking_page/payment.dart';
import '../../config/colors.dart';
import '../../controller/parking_controller.dart';

class BookingPage extends StatelessWidget {
  final String slotName;
  final String slotId;
  final ParkingController parkingController = Get.put(ParkingController());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BookingPage({super.key, required this.slotId, required this.slotName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: const Text("BOOK YOUR SLOT",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Animation
                Center(
                  child: Lottie.asset(
                    'assets/animation/running_car.json',
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 180,
                  ),
                ),
                // Booking Form Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Booking Details",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryColor)),
                        const SizedBox(height: 8),
                        const Divider(thickness: 2, color: lightBg),
                        const SizedBox(height: 16),
                        _buildInputField(
                            label: "Your Name",
                            icon: Icons.person,
                            controller: parkingController.name,
                            hint: "Enter your full name"),
                        const SizedBox(height: 20),
                        _buildInputField(
                            label: "Vehicle Number",
                            icon: Icons.directions_car,
                            controller: parkingController.vehicleController,
                            hint: "WB 04 ED 0987"),
                        const SizedBox(height: 20),
                        const Text("Parking Duration",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        Obx(() => Column(
                          children: [
                            SliderTheme(
                              data: const SliderThemeData(
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 10),
                                overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 16),
                                activeTrackColor: primaryColor,
                                inactiveTrackColor: lightBg,
                                thumbColor: primaryColor,
                              ),
                              child: Slider(
                                label:
                                "${parkingController.parkingTimeInMin.value.toInt()} min",
                                value:
                                parkingController.parkingTimeInMin.value,
                                onChanged: (v) {
                                  parkingController.parkingTimeInMin.value =
                                      v;
                                  if (v <= 30) {
                                    parkingController.parkingAmount.value =
                                    30;
                                  } else {
                                    parkingController.parkingAmount.value =
                                    60;
                                  }
                                },
                                divisions: 5,
                                min: 10,
                                max: 60,
                              ),
                            ),
                            const Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("10m",
                                      style: TextStyle(fontSize: 12)),
                                  Text("20m",
                                      style: TextStyle(fontSize: 12)),
                                  Text("30m",
                                      style: TextStyle(fontSize: 12)),
                                  Text("40m",
                                      style: TextStyle(fontSize: 12)),
                                  Text("50m",
                                      style: TextStyle(fontSize: 12)),
                                  Text("60m",
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        )),
                        const SizedBox(height: 20),
                        const Text("Your Reserved Spot",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border:
                              Border.all(color: primaryColor, width: 1.5)),
                          child: Center(
                            child: Text(
                              slotName,
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: primaryColor,
                                  letterSpacing: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Payment Section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Amount",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600)),
                            Obx(() => Row(
                              children: [
                                Text(
                                  "৳ ${parkingController.parkingAmount.value}",
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: primaryColor),
                                ),
                              ],
                            )),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              Get.dialog(
                                const Center(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                      AlwaysStoppedAnimation(primaryColor),
                                    )),
                                barrierDismissible: false,
                              );

                              bool isSuccess = await DummyPaymentService()
                                  .processPayment(
                                  amount: parkingController
                                      .parkingAmount.value
                                      .toDouble());

                              // Close loading dialog
                              Get.back();

                              if (isSuccess) {
                                await _firestore
                                    .collection('slots')
                                    .doc(slotId)
                                    .update({
                                  'isEmpty': false,
                                  'bookedBy': parkingController.name.text,
                                  'slotStatus': 'Booked',
                                  'bookingTime': FieldValue.serverTimestamp(),
                                });

                                parkingController.bookParkingSlot(slotId);
                              } else {
                                Get.snackbar(
                                  "Payment Failed",
                                  "Could not process payment. Please try again.",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.redAccent,
                                  colorText: Colors.white,
                                  borderRadius: 8,
                                  margin: const EdgeInsets.all(16),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                            ),
                            child: const Text(
                              "PAY NOW",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 1.0),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Input Field Widget
  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: lightBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(icon, color: primaryColor),
            hintText: hint,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }
}