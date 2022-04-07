import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zimple/widgets/button/close_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
  );

  late Animation<Color?> animation1 =
      ColorTween(begin: Color.fromARGB(255, 61, 150, 222), end: Color.fromARGB(255, 60, 202, 124)).animate(_controller)
        ..addListener(() {
          setState(() {});
        });

  int page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation1.value,
      body: SafeArea(
        child: Stack(
          children: [
            _buildCloseButton(),
            _buildNextButton(),
            Align(alignment: Alignment.topRight, child: ZCloseButton(color: Colors.white)),
            Column(
              children: [
                const SizedBox(height: 32),
                Flexible(
                  flex: 5,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      if (page > this.page)
                        _controller.forward();
                      else
                        _controller.reverse();
                      setState(() {
                        this.page = page;
                      });
                    },
                    itemCount: 4,
                    itemBuilder: ((context, index) {
                      return _page(index);
                    }),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: 4,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Colors.white,
                      dotColor: Colors.white.withOpacity(0.5),
                      dotWidth: 16,
                      dotHeight: 7,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    if (page == 3) return Container();
    return Align(
      alignment: Alignment.bottomCenter,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _pageController.animateToPage(
          page + 1,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        ),
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
                child: Text(
              "Nästa",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'FiraSans'),
            ))),
      ),
    );
  }

  Widget _buildCloseButton() {
    if (page != 3) return Container();
    return Align(
      alignment: Alignment.bottomCenter,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.of(context).pop(),
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
                child: Text(
              "Stäng",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'FiraSans'),
            ))),
      ),
    );
  }

  Widget _page(int index) {
    if (index == 0) {
      return OnboardingPage(
          title: "Planering 📅",
          description:
              "Med zimple går det enkelt att planera. Lägg upp arbetsordrar och synka med alla dina kollegor. Varje arbetsorder går sedan direkt att tidrapportera för uppföljning",
          image: "images/onboarding_1.svg");
    } else if (index == 1) {
      return OnboardingPage(
          title: "Tidrapportering 🕚",
          description:
              "Rapportera alla arbetade tider enkelt & smidigt. Med översikten får du full koll hur många timmar alla jobbat en månad. Det går även att exportera tidrapporterna till excel",
          image: "images/onboarding_2.svg");
    } else if (index == 2) {
      return OnboardingPage(
          title: "Offert & Faktura 💲",
          description:
              "Skapa faktura & offerter direkt i Zimple. Spara produkter med pris och titel för att slippa skriva in samma saker flera gånger. Dela sedan fakturan / offerten direkt via mobilen",
          image: "images/onboarding_3.svg");
    } else {
      return OnboardingPage(
          title: "Välkommen ❤️ ",
          description:
              "Vi hoppas att du får en bra upplevelse med Zimple. Vi släpper konstant ny funktionalitet & förbättringar till appen. Har du några frågor eller funderingar är det bara att skriva till vår support support@zimple.se",
          image: "images/onboarding_4.svg");
    }
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final bool hasCloseButton;
  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    this.hasCloseButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 60),
          SizedBox(height: 300, width: 200, child: SvgPicture.asset(image)),
          const SizedBox(height: 48),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
