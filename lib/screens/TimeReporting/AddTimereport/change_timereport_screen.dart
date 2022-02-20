import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:uuid/uuid.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/network/firebase_timereport_manager.dart';
import 'package:zimple/screens/Calendar/Notes/add_notes_screen.dart/add_notes_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/image/preview_image_row.dart';
import 'package:zimple/widgets/select_images_widget.dart';
import 'package:zimple/widgets/snackbar/snackbar_widget.dart';
import 'package:zimple/widgets/start_end_date_selector.dart';
import 'package:zimple/widgets/widgets.dart';

class ChangeTimereportScreen extends StatefulWidget {
  final TimeReport timereport;

  final Event event;

  final bool isChangingTimereport;

  const ChangeTimereportScreen({
    Key? key,
    required this.timereport,
    required this.event,
    required this.isChangingTimereport,
  }) : super(key: key);

  @override
  _ChangeTimereportScreenState createState() => _ChangeTimereportScreenState();
}

class _ChangeTimereportScreenState extends State<ChangeTimereportScreen> {
  late DateSelectorController startDateSelectorController = DateSelectorController()..initialDate = widget.timereport.startDate;

  late DateSelectorController endDateSelectorController = DateSelectorController()..initialDate = widget.timereport.endDate;

  late TextEditingController noteController = TextEditingController(text: widget.timereport.comment);

  late TextEditingController breakController;

  GlobalKey<SelectImagesWidgetState> selectImageKey = GlobalKey<SelectImagesWidgetState>();

  List<File> selectedImages = [];

  @override
  initState() {
    int breakTime = widget.timereport.breakTime;
    String initialBreakTime = breakTime == 0 ? "" : breakTime.toString();
    breakController = TextEditingController(text: initialBreakTime);
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(appBarHeight), child: StandardAppBar("Ändra tidrapport")),
      body: _body(),
    );
  }

  Widget _body() {
    return SelectImagesWidget(
      selectImageKey: selectImageKey,
      didPickImage: (image) => setState(() => selectedImages.add(image)),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                ListedTitle(text: "TID"),
                StartEndDateSelector(
                  startDateSelectorController: startDateSelectorController,
                  endDateSelectorController: endDateSelectorController,
                  onChangeStart: (_) {},
                  onChangeEnd: (_) {},
                ),
                ListedView(
                  items: [
                    ListedTextField(
                      placeholder: 'Rast',
                      leadingIcon: FontAwesome.coffee,
                      controller: breakController,
                      inputType: TextInputType.number,
                    )
                  ],
                ),
                const SizedBox(height: 24),
                ListedTitle(text: "INFORMATION"),
                ListedView(
                  items: [
                    ListedItem(
                        text: 'Lägg till bilder',
                        leadingIcon: Icons.image,
                        onTap: () => selectImageKey.currentState?.pickImage(),
                        trailingWidget: PreviewImageRow(selectedImages: selectedImages)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListedNotefield(
                      context: context,
                      numberOfLines: 8,
                      item: ListedTextField(placeholder: 'Anteckningar', isMultipleLine: true, controller: noteController)),
                ),
              ],
            ),
          ),
          _buildSaveButton()
        ],
      ),
    );
  }

  SliverFillRemaining _buildSaveButton() {
    return SliverFillRemaining(
      hasScrollBody: false,
      fillOverscroll: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RectangularButton(
            onTap: () => _saveTimereport(context),
            text: "Spara tidrapport",
          ),
        ],
      ),
    );
  }

  void _saveTimereport(BuildContext context) {
    setLoading(true);
    FirebaseTimeReportManager firebaseTimeReportManager = ManagerProvider.of(context).firebaseTimereportManager;
    DateTime startDate = startDateSelectorController.getDate();
    DateTime endDate = endDateSelectorController.getDate();
    UserParameters user = ManagerProvider.of(context).user;
    int breakTime = getBreakTime();
    TimeReport newTimereport = widget.timereport.copyWith(
      startDate: startDate,
      endDate: endDate,
      breakTime: breakTime,
      totalTime: endDate.difference(startDate).inMinutes,
      comment: noteController.text,
      userId: user.token,
    );

    if (widget.isChangingTimereport) {
      firebaseTimeReportManager.changeTimereport(newTimereport).then((value) async {
        await uploadTimereportImages(firebaseTimeReportManager, newTimereport.id, newTimereport);
        await setEventTimereported(newTimereport.id, user);
        Navigator.of(context).pop();
        onAdded();
      });
    } else {
      firebaseTimeReportManager.addTimeReport(newTimereport, ManagerProvider.of(context).user).then((value) async {
        await uploadTimereportImages(firebaseTimeReportManager, value, newTimereport);
        await setEventTimereported(value, user);
        Navigator.of(context).pop();
        onAdded();
      });
    }
  }

  Future<void> setEventTimereported(String timereportKey, UserParameters user) async {
    Map<String, String> timereports = Map.from(widget.event.timereports);
    timereports[user.token] = timereportKey;
    Event newEvent = widget.event.copyWith(timereports: timereports);
    return ManagerProvider.of(context).firebaseEventManager.changeEvent(newEvent);
  }

  void setLoading(bool loading) => loading ? context.loaderOverlay.show() : context.loaderOverlay.hide();

  Future<void> uploadTimereportImages(
      FirebaseTimeReportManager firebaseTimeReportManager, String key, TimeReport timereport) async {
    if (selectedImages.length == 0 || selectedImages.length == timereport.imageStoragePaths?.length) return;
    var filenames = selectedImages.map((_) => Uuid().v4().toString()).toList();
    timereport.setImagesStoragePaths(timereport.id, filenames);
    await _uploadTimereportImages(filenames, key);
    await firebaseTimeReportManager.changeTimereport(timereport);
  }

  Future<void> _uploadTimereportImages(List<String> filenames, String? key) async {
    if (key == null) return;
    FirebaseStorageManager firebaseStorageManager = FirebaseStorageManager(company: ManagerProvider.of(context).user.company);
    filenames.asMap().forEach((index, filename) async {
      print("Uploading $filename for timereport $key");
      var file = selectedImages[index];
      await firebaseStorageManager.uploadTimereportImage(key, file, filename);
    });
  }

  void onAdded() {
    setLoading(false);
    Future.delayed(Duration(milliseconds: 300), () {
      String message = widget.isChangingTimereport ? "Tidrapport ändrad" : "Tidrapport tillagd!";
      showSnackbar(context: context, isSuccess: true, message: message);
    });
  }

  int getBreakTime() {
    if (breakController.text.isEmpty) return 0;
    try {
      int breakTime = int.parse(breakController.text);
      return breakTime;
    } catch (error) {
      return 0;
    }
  }
}
