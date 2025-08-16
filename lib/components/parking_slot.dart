import 'package:another_dashed_container/another_dashed_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/colors.dart';
import '../pages/booking_page/booking_page.dart';

class ParkingSlot extends StatelessWidget {
  final bool? isParked;
  final bool? isBooked;
  final String? slotName;
  final String slotId;
  final String time;

  const ParkingSlot({
    super.key,
    this.isParked,
    this.isBooked,
    this.slotName,
    this.slotId = "0.0",
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection('slots').doc(slotId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData) {
          return const Text("No slot data available");
        }

        var slotData = snapshot.data!;
        bool isAvailable = slotData['isEmpty'] ?? true;
        bool isBooked = slotData['slotStatus'] == 'Booked';
        bool isParked = slotData['slotStatus'] == 'Parked';

        return DashedContainer(
          dashColor: Colors.blue.shade300,
          dashedLength: 10.0,
          blankLength: 9.0,
          strokeWidth: 1.0,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: 180,
            height: 120,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    time == ""
                        ? const SizedBox(width: 1)
                        : Text(time),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue.shade100,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        slotName!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (isBooked)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text("BOOKED",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isParked)
                  Expanded(
                    child: Image.asset("assets/images/car.png",
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          if (isAvailable) {
                            Get.to(() => BookingPage(
                              slotId: slotId,
                              slotName: slotName!,
                            ));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 20),
                          decoration: BoxDecoration(
                            color: isAvailable ? greenColor : blueColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isAvailable ? "BOOK" : "UNAVAILABLE",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
