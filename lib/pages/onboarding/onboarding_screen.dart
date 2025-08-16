import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_car_parking/config/colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../MapPage.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingData = [
    OnboardingItem(
      lottieAsset: 'assets/animation/running_car.json',
      title: 'Find Parking Easily',
      description: 'Locate available parking spots in real-time with our smart detection system',
      color: primaryColor!,
    ),
    OnboardingItem(
      lottieAsset: 'assets/animation/payment.json',
      title: 'Secure Payment',
      description: 'Pay seamlessly through our secure in-app payment system',
      color: Colors.deepPurple[700]!,
    ),
    OnboardingItem(
      lottieAsset: 'assets/animation/navigation.json',
      title: 'Smart Navigation',
      description: 'Get guided directly to your parking spot with optimized routes',
      color: Colors.teal[700]!,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _onboardingData[_currentPage].color.withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Main content
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final item = _onboardingData[index];
              return SingleOnboardingPage(item: item);
            },
          ),

          // Bottom controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _onboardingData.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: _onboardingData[_currentPage].color,
                    dotColor: Colors.grey.shade300,
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 8,
                  ),
                ),

                const SizedBox(height: 40),

                // Next button
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _onboardingData.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>MapPage()));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _onboardingData[_currentPage].color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: _onboardingData[_currentPage].color.withOpacity(0.4),
                    ),
                    child: Text(
                      _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Skip button
                if (_currentPage != _onboardingData.length - 1)
                  TextButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        _onboardingData.length - 1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SingleOnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const SingleOnboardingPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation
          Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 30),
            child: Lottie.asset(
              item.lottieAsset,
              fit: BoxFit.contain,
            ),
          ),
          Stack(
            children: [
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: item.color,
                  letterSpacing: 0.5,
                ),
              ),
              Positioned(
                bottom: -5,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        item.color.withOpacity(0.2),
                        item.color,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
class OnboardingItem {
  final String lottieAsset;
  final String title;
  final String description;
  final Color color;

  OnboardingItem({
    required this.lottieAsset,
    required this.title,
    required this.description,
    required this.color,
  });
}