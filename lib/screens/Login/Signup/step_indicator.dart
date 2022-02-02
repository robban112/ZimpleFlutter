import 'package:flutter/material.dart';

class StepIndicator extends StatefulWidget {
  final int numSteps;

  final int currentStep;
  const StepIndicator({
    Key? key,
    required this.numSteps,
    required this.currentStep,
  }) : super(key: key);

  @override
  _StepIndicatorState createState() => _StepIndicatorState();
}

class _StepIndicatorState extends State<StepIndicator> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 65,
      child: Center(
        child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return _step(index + 1);
          },
          separatorBuilder: (context, index) {
            return Center(
              child: Container(
                width: 40,
                height: 4,
                color: widget.currentStep > index ? Colors.green.withOpacity(0.85) : Colors.white.withOpacity(0.25),
              ),
            );
          },
          itemCount: widget.numSteps,
        ),
      ),
    );
  }

  Widget _step(int num) {
    return _stepContainer(num);
  }

  Container _stepContainer(int num) {
    return Container(
      height: isCurrentStep(num) ? 45 : 40,
      width: isCurrentStep(num) ? 45 : 40,
      decoration: BoxDecoration(
        color: getStepColor(num),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          num.toString(),
          style: TextStyle(
            fontSize: isCurrentStep(num) ? 25 : 20,
            fontWeight: FontWeight.bold,
            color: getTextColor(num),
          ),
        ),
      ),
    );
  }

  bool isCurrentStep(int step) => (step - 1) == widget.currentStep;

  bool hasCompletedStep(int step) => widget.currentStep >= step - 1;

  Color getTextColor(int num) {
    if (hasCompletedStep(num)) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  Color getStepColor(int num) {
    if (isCurrentStep(num)) {
      return Colors.white.withOpacity(0.85);
    }
    if (hasCompletedStep(num))
      return Colors.green.withOpacity(1);
    else
      return Colors.white.withOpacity(0.15);
  }

  String getStepSubtitle(int num) {
    if (num == 0) return "Info";
    if (num == 1) return "Konto";
    if (num == 2) return "Medarbetare";
    if (num == 3) return "Villkor";
    return "";
  }
}
