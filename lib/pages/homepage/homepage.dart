import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/floot_selector.dart';
import '../../components/parking_slot.dart';
import '../../config/colors.dart';
import '../../controller/parking_controller.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    ParkingController parkingController = Get.put(ParkingController());
    final List<Map<String, dynamic>> parkingSlots = [
      {
        'name': 'A-1',
        'id': 'slot1',
        'controller': parkingController.slot1,
      },
      {
        'name': 'A-2',
        'id': 'slot2',
        'controller': parkingController.slot2,
      },
      {
        'name': 'A-3',
        'id': 'slot3',
        'controller': parkingController.slot3,
      },
      {
        'name': 'A-4',
        'id': 'slot4',
        'controller': parkingController.slot4,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/white_logo.png",
              width: 36,
              height: 36,
            ),
            const SizedBox(width: 12),
            const Text(
              "Smart Park",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed("/about-us");
            },
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildLegend(),
              const SizedBox(height: 20),
              _buildParkingLot(parkingSlots),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      color: const Color.fromARGB(255, 236, 240, 241),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Text(
              "Parking Availability",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select a floor to view slots",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            const FloorSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Card(
      elevation: 2,
      color: const Color.fromARGB(255, 236, 240, 241),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Legend",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _LegendItem(color: greenColor, text: "Available"),
                _LegendItem(color: yellowColor, text: "Booked"),
                _LegendItem(color: redColor, text: "Parked"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingLot(List<Map<String, dynamic>> slots) {
    return Card(
      elevation: 2,
      color: const Color.fromARGB(255, 236, 240, 241),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGate("ENTRY", Icons.arrow_downward),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slots.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) {
                final slot = slots[index];
                return Obx(() => ParkingSlot(
                  isBooked: slot['controller'].value.booked,
                  isParked: slot['controller'].value.isParked,
                  slotName: slot['name'],
                  slotId: slot['id'],
                  time: slot['controller'].value.parkingHours.toString(),
                ));
              },
            ),
            const SizedBox(height: 20),
            _buildGate("EXIT", Icons.arrow_downward),
          ],
        ),
      ),
    );
  }

  Widget _buildGate(String label, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black26),
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
