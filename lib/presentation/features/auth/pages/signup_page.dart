import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_routes.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.06),

              // LOGO
              Container(
                height: 100,
                width: 80,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logosby.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // TITLE
              const Text(
                "Create Your Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: "Poppins",
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Join to help validate Surabaya's public information.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontFamily: "Poppins",
                ),
              ),

              const SizedBox(height: 32),

              // FULL NAME
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Full Name",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: "Enter your full name",
                      hintStyle: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF2F4F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // EMAIL
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Email Address",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.mail_outline),
                      hintText: "your.email@example.com",
                      hintStyle: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF2F4F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // PASSWORD
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      hintText: "Create a secure password",
                      hintStyle: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF2F4F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005BBB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // LOGIN TEXT
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(fontFamily: "Poppins"),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go(AppRoutes.login);
                    },
                    child: const Text(
                      "Log In",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Color(0xFF005BBB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
