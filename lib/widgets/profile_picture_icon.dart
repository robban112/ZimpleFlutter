import 'package:flutter/material.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/widgets.dart';

class ProfilePictureIcon extends StatefulWidget {
  final Person? person;

  final bool isLoggedInPerson;

  final Size size;

  final double fontSize;

  const ProfilePictureIcon({
    Key? key,
    this.size = const Size(20, 20),
    this.fontSize = 11,
    this.isLoggedInPerson = false,
    this.person,
  }) : super(key: key);

  @override
  State<ProfilePictureIcon> createState() => _ProfilePictureIconState();
}

class _ProfilePictureIconState extends State<ProfilePictureIcon> {
  Image? image;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Person? person = widget.person;
      if (widget.isLoggedInPerson) {
        Person? _person = ManagerProvider.of(context).getLoggedInPerson();
        if (_person != null) person = _person;
      }
      this.image = ManagerProvider.of(context).getPersonImage(person);
      setState(() => {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeNotifier.of(context).textColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Container(
        height: widget.size.height,
        width: widget.size.width,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.person?.color.withOpacity(0.3) ?? ThemeNotifier.of(context).textColor.withOpacity(0.2),
        ),
        child: _buildChild(context),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    if (image != null)
      return Container(
        child: ClipRRect(
          child: image!,
          borderRadius: BorderRadius.circular(30),
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
      );
    return _buildLetterChild(context, widget.person?.name.characters.first ?? "P");
  }

  Widget _buildLetterChild(BuildContext context, String letter) {
    return Center(
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: widget.fontSize),
      ),
    );
  }
}
