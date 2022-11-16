// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:animate_do/animate_do.dart';

// // void main() {
// //   runApp(const MyApp());
// // }

// class Welcome extends StatelessWidget {
//   const Welcome({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Welcome Screen',
//       home: MainScreen(),
//     );
//   }
// }

// class MainScreen extends StatelessWidget {
//   final Duration duration = const Duration(milliseconds: 800);

//   const MainScreen({Key key}) : super(key: key);


//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 239, 239, 239),
//       body: Container(
//         margin: const EdgeInsets.all(8),
//         width: size.width,
//         height: size.height,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             /// 
//             FadeInUp(
//               duration: duration,
//               delay: const Duration(milliseconds: 2000),
//               child: Container(
//                 margin: const EdgeInsets.only(
//                   top: 50,
//                   left: 5,
//                   right: 5,
//                 ),
//                 width: size.width,
//                 height: size.height / 2,
//                 child: Lottie.asset("assets/wl.json", animate: true),
//               ),
//             ),

//             ///
//             const SizedBox(
//               height: 15,
//             ),

//             /// TITLE
//             FadeInUp(
//               duration: duration,
//               delay: const Duration(milliseconds: 1600),
//               child: const Text(
//                 "Keep",
//                 style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 25,
//                     fontWeight: FontWeight.bold),
//               ),
//             ),

//             ///
//             const SizedBox(
//               height: 10,
//             ),

//             /// SUBTITLE
//             FadeInUp(
//               duration: duration,
//               delay: const Duration(milliseconds: 1000),
//               child: const Text(
//                 "Keep various ways to contact and get in touch easily right from the app.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     height: 1.2,
//                     color: Colors.grey,
//                     fontSize: 17,
//                     fontWeight: FontWeight.w300),
//               ),
//             ),

//             ///
//             Expanded(child: Container()),

//             /// GOOGLE BTN
//             FadeInUp(
//               duration: duration,
//               delay: const Duration(milliseconds: 600),
//               child: SButton(
//                 size: size,
//                 borderColor: Colors.grey,
//                 color: Colors.white,
//                 img: 'assets/g.png',
//                 text: "Continue with Google",
//                 textStyle: null,
//               ),
//             ),

//             ///
//             const SizedBox(
//               height: 20,
//             ),

//             /// GITHUB BTN
//             FadeInUp(
//               duration: duration,
//               delay: const Duration(milliseconds: 200),
//               child: SButton(
//                 size: size,
//                 borderColor: Colors.white,
//                 color: const Color.fromARGB(255, 54, 54, 54),
//                 img: 'assets/Gt.png',
//                 text: "Sign up with GitHub",
//                 textStyle: const TextStyle(color: Colors.white),
//               ),
//             ),

//             ///
//             const SizedBox(
//               height: 40,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SButton extends StatelessWidget {
//   const SButton({
//     Key key,
//     this.size,
//     this.color,
//     this.borderColor,
//     this.img,
//     this.text,
//     this.textStyle,
//   }) : super(key: key);

//   final Size size;
//   final Color color;
//   final Color borderColor;
//   final String img;
//   final String text;
//   final TextStyle textStyle;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: ((context) => const MainScreen()),
//           ),
//         );
//       },
//       child: Container(
//         width: size.width / 1.2,
//         height: size.height / 15,
//         decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: borderColor, width: 1)),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               img,
//               height: 40,
//             ),
//             const SizedBox(
//               width: 10,
//             ),
//             Text(
//               text,
//               style: textStyle,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
 

 
class Welcome extends StatefulWidget {
  Welcome({Key key}) : super(key: key);
 
  @override
  State<Welcome> createState() => _WelcomeState();
}
 
class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text('GeeksforGeeks'),
            ),
            body: const FirstScreen()));
  }
}
 
class FirstScreen extends StatelessWidget {
  const FirstScreen({Key key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: ElevatedButton(
        // color: Colors.green,
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const NewScreen())),
        child: const Text(
          'Create Patient',
          style: TextStyle(color: Colors.white),
        ),
      )),
    );
  }
}
 
class NewScreen extends StatefulWidget {
  const NewScreen({Key key}) : super(key: key);
 
  @override
  State<NewScreen> createState() => _NewScreenState();
}
 
class _NewScreenState extends State<NewScreen> {
  TextEditingController textEditingController = TextEditingController();
 
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        backgroundColor: Colors.green,
      ),
      body: Container(
          child: Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              child: Text(
                'Display Patients List!!',
              ),
            )),
      )),
    );
  }
}
