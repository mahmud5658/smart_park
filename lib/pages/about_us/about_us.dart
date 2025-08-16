import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_car_parking/config/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Data.dart';
class AboutUs extends StatelessWidget {
  const AboutUs({super.key});
  void _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: primaryColor,
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon: Icon(Icons.arrow_back_ios)),
        title: Text(
          "About Us",
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(context),
            const SizedBox(height: 30),
            _buildTeamSection(),
          ],
        ),
      ),
    );
  }
  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          _buildProjectOverview(),
          const SizedBox(height: 30),
          _buildConnectWithUs(context),
        ],
      ),
    );
  }
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [primaryColor, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: ClipOval(
              child: Image.network(
                "https://avatars.githubusercontent.com/u/104672914?v=4",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          LeaderName,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          bio,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 17,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }
  Widget _buildProjectOverview() {
    return Column(
      children: [
        _buildSectionTitle(icon: Icons.lightbulb_outline, title: "System Overview"),
        const SizedBox(height: 12),
        Text(
          "Smart Car Parking System is an IoT solution that helps drivers find available parking spots quickly, reducing traffic and saving time. It integrates Arduino sensors, Firebase real-time database and Cloud Storage, and a mobile app with Google Maps. The system provides live updates on parking slot status and allows users to book slots remotely.",
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.black87,
            height: 1.6,
          ),
        ),
      ],
    );
  }
  Widget _buildConnectWithUs(BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle(icon: Icons.connect_without_contact, title: "Connect With Us"),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: FontAwesomeIcons.github,
              color: const Color(0xFF333333),
              onPressed: () => _launchURL(context, "https://github.com/mahmud5658"),
            ),
            const SizedBox(width: 20),
            _buildSocialButton(
              icon: FontAwesomeIcons.linkedinIn,
              color: const Color(0xFF0A66C2),
              onPressed: () => _launchURL(context, "https://www.linkedin.com/in/mahmud5658/"),
            ),
            const SizedBox(width: 20),
            _buildSocialButton(
              icon: FontAwesomeIcons.facebook,
              color: Colors.blue,
              onPressed: () => _launchURL(context, "https://www.facebook.com/abdullahalmahmud5658/"),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildTeamSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: _buildSectionTitle(icon: Icons.group, title: "Our Team"),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildTeamMember("Abdullah Al Mahmud", "221-15-5658","https://avatars.githubusercontent.com/u/104672914?v=4"),
              _buildTeamMember("Nafiur Rahman Sabbir", "221-15-5871","https://avatars.githubusercontent.com/u/93787418?v=4"),
              _buildTeamMember("Fahim Al-Amin Auntu", "221-15-4672","https://avatars.githubusercontent.com/u/123312309?v=4"),
              _buildTeamMember("Tanhatul Tasnim", "221-15-5626","https://avatars.githubusercontent.com/u/123645381?v=4"),
              _buildTeamMember("Mst. Kanij Fatima", "221-15-5702","https://avatars.githubusercontent.com/u/123966715?v=4"),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 22),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
            )
          ],
        ),
        child: Icon(icon, size: 28, color: color),
      ),
    );
  }

  Widget _buildTeamMember(String name, String id,String? profile) {
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue.shade100, // Shows while the image loads
          backgroundImage: NetworkImage(profile!),
        ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  id,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}