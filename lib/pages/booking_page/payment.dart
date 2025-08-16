import 'dart:async';
import 'dart:math';

class DummyPaymentService {
  Future<bool> processPayment({required double amount}) async {
    print('Connecting to payment gateway...');
    print('Processing payment of \$$amount...');

    await Future.delayed(const Duration(seconds: 3));  // Simulate payment delay

    final isSuccess = true;

    if (isSuccess) {
      print('Payment Successful!');
      return true;
    } else {
      print('Payment Failed.');
      return false;
    }
  }
}
