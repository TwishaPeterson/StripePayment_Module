//To get started, we would need to generate an API key from Stripe. To do this, you would need to create a Stripe account.
After this, login to your dashboard, activate Test mode for the purpose of integration and testing and go to Developers > API Keys to reveal your API keys (Publishable and Secret Keys).

dependencies:
  flutter_stripe: ^7.0.0
  
  const stripePublishableKey = ['Stripe secret key']; // Assign publishable key to flutter_stripe
  
  String? paymentIntent;
  String ephemeralKey = '';
  String customer = '';
  Map<String, dynamic>? paymentIntentData;
    
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Stripe.publishableKey = stripePublishableKey;
  }
  
  
   // call this function on click of payment button
    Future<void> payment(Event eventId, User user, int count) async {
    try {
     
     // Create Payment Intent -  We Start by creating payment intent by defining a createPaymentIntent function that takes the amount we’re paying and the currency.
      paymentIntentData = await createPaymentIntentt(); // In CreatePaymentIntent we make an api call to create a payment intent on the server side. It will return payment intent, ephemeral key and customer.

      //Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent, 
              style: ThemeMode.dark,
              merchantDisplayName: 'ANNIE',
              customerId: customer,
              customerEphemeralKeySecret: ephemeralKey,
              allowsDelayedPaymentMethods: true,
            ),
          )
          .then((value) => Stripe.instance.presentPaymentSheet())
          .then((value) 
        paymentIntentData = null; //Clear paymentIntent variable after successful payment
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET====> $error $stackTrace');
      });
    } catch (e) {
      print(e);
      print('-----error--payment');
    }
  }
  
  createPaymentIntentt() async {
    try {
    
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        "end_client": "app"
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("auth_token") ?? "";
      headers['authorization'] = token;

      var resp = await http.post(
        Uri.parse(ApiEndPoints.stripePay), // api url
        headers: headers,
        body: jsonEncode(
          {
           // pass your ammount and currency so server create paymentIntent according your body data.
          },
        ),
      );
      
      //resp return this three data which can add in stripe and continue payment
      var decodedData = jsonDecode(resp.body);
      paymentIntent = decodedData["paymentIntent"];
      ephemeralKey = decodedData["ephemeralKey"];
      customer = decodedData["customer"];

      print('paymentIntent ==> $paymentIntent');
      print('ephemeralKey ==> $ephemeralKey');
      print('customer ==> $customer');

      return jsonDecode(resp.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }